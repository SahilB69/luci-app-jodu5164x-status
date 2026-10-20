#!/bin/sh
# jodu5164x_reboot.sh - Safely reboots JODU5164x ODU using shared telnet handling.
. "${ODU_LIB:-/usr/libexec/jodu5164x-telnet.sh}"
odu_config

trap odu_close EXIT INT TERM
if odu_open; then
    odu_send reboot
else
    echo "Error: $(odu_err_text)" >&2
    exit 1
fi
