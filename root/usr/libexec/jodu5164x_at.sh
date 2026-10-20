#!/bin/sh
# Executes AT and CRI commands over Telnet on JODU5164x.
. "${ODU_LIB:-/usr/libexec/jodu5164x-telnet.sh}"
CMD="$1"
[ -z "$CMD" ] && exit 1
odu_config
FIRST_WORD=$(printf '%s\n' "$CMD" | awk '{print toupper($1)}')
if echo "$FIRST_WORD" | grep -q '^AT'; then
    QUOTED=$(printf '%s' "$CMD" | sed "s/'/'\\\\''/g")
    EXEC_CMD="/usr/bin/atcli '$QUOTED'"
else
    EXEC_CMD="$CMD"
fi
trap odu_close EXIT INT TERM
odu_open || { echo "Error: $(odu_err_text)"; exit 1; }
odu_cmd "$EXEC_CMD" 15 || [ -n "$ODU_OUT" ] || echo "Error: the ODU did not answer in time."
printf '%s\n' "$ODU_OUT" | awk 'NF'
