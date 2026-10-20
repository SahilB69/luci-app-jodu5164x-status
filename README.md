<div align="center">

# luci-app-jodu5164x-status
## Made with Antigravity as a Personal Fun Project.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![OpenWrt Compatible](https://img.shields.io/badge/OpenWrt-25.12.5-success.svg)
![Target](https://img.shields.io/badge/Target-mediatek%2Ffilogic-blue.svg)

A LuCI dashboard extension for JODU51641 / JODU51642.

This package provides real-time ODU monitoring on OpenWrt.
</div>

## Features
- **Real-Time Signal Monitoring:** Dynamically updates RSRP, RSRQ, SINR, and signal quality.
- **Data Usage Monitor:** Monitor data usage directly on the dashboard.
- **Neighbouring Cells Tracking:** See active SCells and neighbouring cells in your sector.
- **Cell Locking:** Experimental feature to force the modem to lock onto a specific NR-ARFCN and PCI directly from the UI.

## Installation

Prebuilt APKs for OpenWrt **25.12.5, mediatek/filogic** are published to the [latest GitHub Release](https://github.com/SahilB69/luci-app-jodu5164x-status/releases/latest).

Install directly on the router:

```sh
wget -O /tmp/luci-app-jodu5164x-status.apk https://github.com/SahilB69/luci-app-jodu5164x-status/releases/latest/download/luci-app-jodu5164x-status.apk
apk add --allow-untrusted /tmp/luci-app-jodu5164x-status.apk
rm -f /tmp/luci-app-jodu5164x-status.apk
```

After installation, go to **Status → 5G Dashboard**.

## Build automation

GitHub Actions builds the package with the matching OpenWrt 25.12.5 MediaTek Filogic SDK when code is pushed to `main`, and publishes the APK to the moving `latest` release. You can also run the workflow manually from the **Actions** tab.

## Telnet login

The ODU Telnet helper detects login prompts, submits the configured username/password, and uses a unique completion marker for command output. Run `sh tests/run.sh` to exercise the mock ODU cases.
