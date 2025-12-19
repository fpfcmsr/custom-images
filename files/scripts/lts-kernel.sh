#!/bin/bash

# Configuration
LTS_VER="6.18"
MOK_DIR="/etc/pki/MOK"
MOK_KEY="$MOK_DIR/MOK.key"
MOK_DER="$MOK_DIR/MOK.der"
ZFS_REPO_URL="https://zfsonlinux.org/fedora/zfs-release-3-0$(rpm --eval "%{dist}").noarch.rpm"

# 1. Root Check
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (sudo)."
  exit 1
fi

echo "--- Step 1: Installing Required Tools ---"
dnf install -y openssl mokutil sbsigntools dkms

echo "--- Step 2: Generating MOK (Machine Owner Key) ---"
if [ ! -f "$MOK_KEY" ]; then
    mkdir -p "$MOK_DIR"
    chmod 700 "$MOK_DIR"
    openssl req -new -x509 -newkey rsa:2048 -keyout "$MOK_KEY" -outform DER -out "$MOK_DER" \
        -nodes -days 36500 -subj "/CN=Fedora LTS Custom Signing Key/"
    echo "MOK generated at $MOK_DIR"
else
    echo "MOK already exists, skipping generation."
fi

echo "--- Step 3: Enabling kwizart/kernel-longterm-$LTS_VER ---"
dnf copr enable -y kwizart/kernel-longterm-$LTS_VER

echo "--- Step 4: Installing LTS Kernel and Headers ---"
dnf install -y kernel-longterm kernel-longterm-devel

echo "--- Step 5: Configuring DKMS for Auto-Signing (ZFS) ---"
mkdir -p /etc/dkms
cat <<EOF > /etc/dkms/framework.conf
mok_signing_key="$MOK_KEY"
mok_certificate="$MOK_DER"
EOF

echo "--- Step 6: Installing ZFS ---"
dnf install -y "$ZFS_REPO_URL"
dnf install -y zfs
echo "zfs" > /etc/modules-load.d/zfs.conf

echo "--- Step 7: Signing the LTS Kernel Image ---"
# Find the exact installed LTS kernel
LTS_KERNEL=$(ls /boot/vmlinuz-*.longterm* | head -n 1)
if [ -n "$LTS_KERNEL" ]; then
    sbsign --key "$MOK_KEY" --cert "$MOK_DER" "$LTS_KERNEL" --output "$LTS_KERNEL"
    echo "Successfully signed $LTS_KERNEL"
else
    echo "Error: Could not find LTS kernel image to sign."
fi

echo "--- Step 8: Setting LTS as Default and Cleaning Up ---"
LTS_PATH=$(grubby --info=ALL | grep -m1 "longterm" | cut -d'=' -f2)
[ -n "$LTS_PATH" ] && grubby --set-default="$LTS_PATH"

# Remove standard kernels
dnf remove -y kernel kernel-core kernel-modules --exclude="kernel-longterm*"

echo "----------------------------------------------------------"
echo "SCRIPT FINISHED: NEXT STEPS REQUIRED"
echo "----------------------------------------------------------"
echo "The kernel is installed and signed, but your BIOS does not"
echo "trust your new key yet. You MUST run the following command:"
echo ""
echo "  sudo mokutil --import $MOK_DER"
echo ""
echo "1. Enter a temporary password when prompted."
echo "2. Reboot your computer."
echo "3. On the blue 'MokManager' screen, select 'Enroll MOK'."
echo "4. Select 'View key' to verify it is yours, then 'Continue'."
echo "5. Enter the temporary password you just created."
echo "6. Reboot. Your LTS kernel and ZFS will now load securely."
