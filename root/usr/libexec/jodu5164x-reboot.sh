#!/bin/sh
# Safely reboot JODU5164x ODU using the shared prompt-aware telnet helper.
. "${ODU_LIB:-/usr/libexec/jodu5164x-telnet.sh}"
odu_config
trap odu_close EXIT INT TERM
if odu_open; then
    odu_send reboot
else
    echo "Error: $(odu_err_text)" >&2
    exit 1
fi
