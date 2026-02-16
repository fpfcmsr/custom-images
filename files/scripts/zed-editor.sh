#!/usr/bin/env bash

set -euo pipefail

dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
dnf5 -y config-manager setopt terra.enabled=1
dnf5 -y install zed noctalia-shell
dnf5 -y config-manager setopt terra.enabled=0
