<div align="center">

# luci-app-jodu5164x-status
## Made with Antigravity as a Personal Fun Project.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![OpenWrt Compatible](https://img.shields.io/badge/OpenWrt-Compatible-success.svg)
![ImmortalWrt Compatible](https://img.shields.io/badge/ImmortalWrt-Compatible-success.svg)

A LuCI dashboard extension for (JODU51641 / JODU51642).

This package provides a real-time ODU monitoring for OpenWrt. 
</div>

## Features
- **Real-Time Signal Monitoring:** Dynamically updates RSRP, RSRQ, SINR, and Signal Quality in real-time.
- **Data Usage Monitor:** Monitor the Data Usage directly on the Dashboard.
- **Neighbouring Cells Tracking:** See all active SCells and neighbouring cells in your sector.
- **Cell Locking:** Experimental feature to force the modem to lock onto a specific NR-ARFCN and PCI directly from the UI.

## Installation
Grab the Latest from the [Releases](https://github.com/RummaanKhan/luci-app-jodu5164x-status/releases) page or directly install using:
```sh
wget --no-check-certificate -O /tmp/luci-app-jodu5164x-status-1.0.0-r3.apk https://github.com/RummaanKhan/luci-app-jodu5164x-status/releases/download/v1.0.0-r3/luci-app-jodu5164x-status-1.0.0-r3.apk && apk add --allow-untrusted /tmp/luci-app-jodu5164x-status-1.0.0-r3.apk
```
   Go to **Status** -> **5G Dashboard** to view your stats!

## Telnet login
All scripts that talk to the ODU over telnet share `jodu5164x-telnet.sh`, which follows the ODU's
prompts instead of sleeping: `login:` gets the Telnet Username (default `root`), `Password:` gets
the Telnet Password, and with neither set it just presses Enter. A wrong login is reported
("Telnet login failed") instead of failing silently. `tests/run.sh` checks all variants against a
mock ODU (needs busybox and python3).

## Telnet login

The ODU connection helper follows login prompts instead of relying on fixed delays.
It supports login with username and password, password-only login, and shells that
do not require credentials. Incorrect credentials are surfaced as a login error.
Run `tests/run.sh` to exercise the login cases with the mock ODU.
