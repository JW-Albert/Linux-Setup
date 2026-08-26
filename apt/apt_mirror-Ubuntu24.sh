#!/bin/bash
# This script needs to be executed as root!
# For Ubuntu 24.04+ (deb822 /etc/apt/sources.list.d/ubuntu.sources format)

set -e  # Exit script if there is an error

clear

MIRROR="mirrors.kernel.org"

echo "[INFO] Checking OS"
. /etc/os-release
if [ "$ID" != "ubuntu" ]; then
    echo "[WARN] This script targets Ubuntu; detected ID=$ID. Continuing anyway."
fi

DEB822_FILE="/etc/apt/sources.list.d/ubuntu.sources"
LEGACY_FILE="/etc/apt/sources.list"

replace_mirror() {
    local file="$1"
    echo "[INFO] Backing up $file"
    cp "$file" "$file.bak.$(date +%s)"

    echo "[INFO] Pointing apt sources in $file to $MIRROR"
    sed -i \
        -e "s|https\?://[a-zA-Z0-9.-]*archive\.ubuntu\.com/ubuntu|http://$MIRROR/ubuntu|g" \
        -e "s|https\?://[a-zA-Z0-9.-]*security\.ubuntu\.com/ubuntu|http://$MIRROR/ubuntu|g" \
        -e "s|https\?://[a-zA-Z0-9.-]*ports\.ubuntu\.com/ubuntu-ports|http://$MIRROR/ubuntu-ports|g" \
        "$file"
}

if [ -f "$DEB822_FILE" ]; then
    replace_mirror "$DEB822_FILE"
elif [ -f "$LEGACY_FILE" ]; then
    replace_mirror "$LEGACY_FILE"
else
    echo "[ERROR] No apt sources file found at $DEB822_FILE or $LEGACY_FILE"
    exit 1
fi

echo "[INFO] Updating apt"
apt update

clear

echo "[INFO] apt sources now point to $MIRROR"
