#!/usr/bin/env bash

set -euo pipefail

dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
dnf5 -y config-manager setopt terra.enabled=1
dnf5 -y install zed noctalia-shell
dnf5 -y config-manager setopt terra.enabled=0


dnf config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:paul4us/Fedora_43/home:paul4us.repo
dnf5 -y install klassy
