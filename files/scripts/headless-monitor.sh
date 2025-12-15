#!/usr/bin/env bash

set -euo pipefail

mkdir /usr/lib/firmware/edid
wget -P /usr/lib/firmware/edid/ https://git.linuxtv.org/v4l-utils.git/plain/utils/edid-decode/data/samsung-q800t-hdmi2.1

tee /etc/dracut.conf.d/10-edid.conf >/dev/null <<EOF
# Ensure custom EDID is available early in boot
# NOTE: keep the spaces exactly as in this line – dracut is picky.
install_items+=" /usr/lib/firmware/edid/${EDID_NAME:-samsung-q800t-hdmi2.1} "
EOF
