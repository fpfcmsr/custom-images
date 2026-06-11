#!/usr/bin/env bash

set -euo pipefail

dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
dnf5 -y config-manager setopt terra.enabled=1
dnf5 -y install zed vscodium
dnf5 -y config-manager setopt terra.enabled=0
dnf5 -y remove code

#dnf config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:paul4us/Fedora_43/home:paul4us.repo
#dnf5 -y install klassy

dnf config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:luisbocanegra/Fedora_43/home:luisbocanegra.repo
dnf5 -y install plasma-panel-colorizer

#dnf copr enable -y bazzite-org/webapp-manager fedora-43-x86_64
#dnf copr enable -y jsbillings/netbird fedora-43-x86_64
dnf copr enable -y bazzite-org/bazzite fedora-43-x86_64

dnf5 -y install steamdeck-kde-presets-desktop # netbird-client webapp-manager

#dnf copr disable -y bazzite-org/webapp-manager
#dnf copr disable -y jsbillings/netbird
dnf copr disable -y bazzite-org/bazzite


dnf config-manager addrepo --from-repofile="https://codeberg.org/api/packages/GramEditor/rpm.repo"
curl -L -o /tmp/GramEditor.gpg https://codeberg.org/api/packages/GramEditor/rpm/repository.key
rpm --import /tmp/GramEditor.gpg
dnf clean all
dnf makecache
dnf -y install --nogpgcheck gram


# dnf5 -y install texlive*
