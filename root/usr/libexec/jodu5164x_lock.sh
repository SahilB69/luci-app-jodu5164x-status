#!/bin/sh
# Locks or unlocks 5G NR cell on Sercomm JODU5164x using cricli.
. "${ODU_LIB:-/usr/libexec/jodu5164x-telnet.sh}"
odu_config
NR_ARFCN="$1"
NR_PCI="$2"
[ -n "$NR_ARFCN" ] || NR_ARFCN=$(uci -q get jodu5164x.main.arfcn)
[ -n "$NR_PCI" ] || NR_PCI=$(uci -q get jodu5164x.main.pci)
if [ -z "$NR_ARFCN" ] || [ -z "$NR_PCI" ]; then
    CMD="cricli set_nr5g_cell_config 2"
else
    case "$NR_ARFCN$NR_PCI" in *[!0-9]*) echo '{"result":"FAILED","error":"invalid_value"}'; exit 1 ;; esac
    CMD="cricli set_nr5g_cell_config 0 $NR_PCI $NR_ARFCN 1 0 8192 0 0 0 0 0 0"
fi
trap odu_close EXIT INT TERM
if odu_open && odu_cmd "$CMD" 10; then
    echo '{"result":"OK"}'
else
    printf '{"result":"FAILED","error":"%s"}\n' "${ODU_ERR:-timeout}"
fi
