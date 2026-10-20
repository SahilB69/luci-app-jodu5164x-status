#!/bin/sh
# Prompt-aware Telnet helper for the JODU5164x ODU.
# Supports no login, password-only login, and username/password login.
# ODU_ERR: unreachable | auth | nodata | tools
PATH=$PATH:/sbin:/usr/sbin
ODU_DIR=${ODU_TMPDIR:-/tmp}
_now() { read -r _up _ < /proc/uptime; _NOW=${_up%%.*}; }
_nap() { sleep 0.2 2>/dev/null || sleep 1; }
_clean() { tr -cd '\11\12\40-\176' < "$_OUT"; }
_wait() {
    _now; _end=$((_NOW + $2))
    while :; do
        _clean | grep -qE "$1" && return 0
        kill -0 "$_NC" 2>/dev/null || return 1
        _now; [ "$_NOW" -ge "$_end" ] && return 1
        _nap
    done
}
odu_config() {
    ODU_IP=$(uci -q get jodu5164x.main.ip)
    [ -n "$ODU_IP" ] || ODU_IP=$(uci -q get jodu5164x.main.host)
    [ -n "$ODU_IP" ] || ODU_IP=192.168.225.1
    ODU_PORT=$(uci -q get jodu5164x.main.telnet_port)
    [ -n "$ODU_PORT" ] || ODU_PORT=23
    ODU_USER=$(uci -q get jodu5164x.main.user)
    [ -n "$ODU_USER" ] || ODU_USER=$(uci -q get jodu5164x.main.telnet_username)
    ODU_PASS=$(uci -q get jodu5164x.main.pass)
    [ -n "$ODU_PASS" ] || ODU_PASS=$(uci -q get jodu5164x.main.telnet_password)
    [ "$ODU_USER" = none ] && ODU_USER=
}
odu_err_text() {
    case "$ODU_ERR" in
        unreachable) echo "Cannot reach the ODU at $ODU_IP:$ODU_PORT (check the address and that telnet is enabled)." ;;
        auth) echo "Telnet login failed. Check the telnet username and password under Config." ;;
        nodata) echo "The ODU answered but did not behave like a telnet shell." ;;
        tools) echo "The router is missing nc or mkfifo." ;;
        *) echo "Telnet error (${ODU_ERR:-unknown})." ;;
    esac
}
odu_send() { printf '%s\r\n' "$1" >&3; }
odu_open() {
    ODU_ERR=; _NC=; _SEQ=0
    command -v nc >/dev/null 2>&1 && command -v mkfifo >/dev/null 2>&1 || { ODU_ERR=tools; return 1; }
    _IN=$ODU_DIR/odu_in.$$
    _OUT=$ODU_DIR/odu_out.$$
    mkfifo "$_IN" 2>/dev/null || { ODU_ERR=tools; return 1; }
    : > "$_OUT"
    exec 3<> "$_IN"
    nc "$ODU_IP" "$ODU_PORT" < "$_IN" >> "$_OUT" 2>/dev/null &
    _NC=$!
    _any='ogin:|assword:|[#$] *$'
    if ! _wait "$_any" 3; then
        odu_send ''
        _wait "$_any" 4 || { if [ -s "$_OUT" ]; then ODU_ERR=nodata; else ODU_ERR=unreachable; fi; odu_close; return 1; }
    fi
    if _clean | grep -qE 'ogin:'; then
        : > "$_OUT"
        odu_send "${ODU_USER:-root}"
        _wait 'assword:|ogin:|[#$] *$' 4 || true
    fi
    if _clean | grep -qE 'assword:'; then
        : > "$_OUT"
        odu_send "$ODU_PASS"
        _wait '[#$] *$|ogin:|assword:' 6 || true
    fi
    if _clean | grep -qE 'ogin:|assword:|incorrect'; then ODU_ERR=auth; odu_close; return 1; fi
    _clean | grep -qE '[#$] *$' || { ODU_ERR=auth; odu_close; return 1; }
    return 0
}
odu_cmd() {
    _SEQ=$((_SEQ + 1)); _m="ODU_DONE_$$_$_SEQ"
    : > "$_OUT"; odu_send "$1; echo $_m"
    if _wait "$_m" "${2:-10}"; then _rc=0; else _rc=1; fi
    ODU_OUT=$(_clean | awk -v m="$_m" 'index($0, m) && $0 != m { next } $0 == m { exit } { print }')
    return $_rc
}
odu_close() {
    [ -n "$_NC" ] || return 0
    odu_send exit 2>/dev/null; _nap
    exec 3>&-
    kill "$_NC" 2>/dev/null; wait "$_NC" 2>/dev/null
    rm -f "$_IN" "$_OUT"; _NC=
}
