#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
command -v python3 >/dev/null 2>&1 || { echo "python3 is required" >&2; exit 77; }
command -v busybox >/dev/null 2>&1 || { echo "busybox is required" >&2; exit 77; }
TMP=$(mktemp -d)
PID=
cleanup() {
    [ -z "$PID" ] || kill "$PID" 2>/dev/null || true
    rm -rf "$TMP"
}
trap cleanup EXIT INT TERM
export PATH="$ROOT/tests/bin:$PATH"
export ODU_LIB="$ROOT/root/usr/libexec/jodu5164x-telnet.sh"
export ODU_TMPDIR="$TMP"
export TEST_ODU_IP=127.0.0.1
export TEST_ODU_PORT=2323
export TEST_ODU_USER=root
export TEST_ODU_PASS=secret

run_case() {
    mode="$1"
    python3 "$ROOT/tests/odu_mock.py" --mode "$mode" --port "$TEST_ODU_PORT" &
    PID=$!
    sleep 1
    if [ "$mode" = wrongpass ]; then
        if busybox sh -c '. "$ODU_LIB"; odu_config; odu_open'; then
            echo "expected wrong-password case to fail" >&2
            exit 1
        fi
    else
        busybox sh -c '. "$ODU_LIB"; odu_config; odu_open && odu_cmd "echo test" 3 && echo "$ODU_OUT" | grep -q test'
    fi
    kill "$PID" 2>/dev/null || true
    wait "$PID" 2>/dev/null || true
    PID=
}
run_case nologin
run_case passonly
run_case userpass
run_case wrongpass
echo "Telnet login tests passed"
