#!/bin/bash
# This script needs to be executed as root (or via sudo)!
# Runs the apt mirror switch, ufw secure setup, and timedatectl setup for Ubuntu 24.04.

set -e  # Exit script if there is an error

clear

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[INFO] Please change Your Password"
passwd

clear
echo "[INFO] Switching apt sources to mirrors.kernel.org"
sudo bash "$SCRIPT_DIR/apt/apt_mirror-Ubuntu24.sh"

clear
echo "[INFO] Running ufw secure setup"
sudo bash "$SCRIPT_DIR/network/ufw_secure_setup.sh"

clear
echo "[INFO] Running timedatectl Ubuntu24 setup"
sudo bash "$SCRIPT_DIR/time/timedatectl-Ubuntu24.sh"

clear
echo "[DONE] Ubuntu 24.04 setup completed"