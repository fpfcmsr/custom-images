#!/usr/bin/env bash

set -euo pipefail

URL=$(curl -s https://api.github.com/repos/bitwarden/clients/releases | jq -r 'first(.[] | .assets[]? | select(.browser_download_url | endswith(".rpm")) | .browser_download_url)')

if [ -n "$URL" ]; then
    echo "Downloading Bitwarden from $URL"
    curl -sL -o /bitwarden-latest.rpm "$URL"
else
    echo "--- Could not find Bitwarden RPM URL"
    exit 1
fi
