#!/bin/bash
# This script needs to be executed as root!

set -e  # Exit script if there is an error

clear

echo "[INFO] Updating apt"
apt update && apt upgrade -y

echo "[INFO] Installing sudo"
apt install sudo -y

echo "[INFO] Creating sudo user account"
read -p "[INPUT] Please enter new username (default: albert): " user_name
user_name=${user_name:-albert}
echo "[INFO] Setting username to $user_name"

useradd -m -s /bin/bash $user_name

echo "[INFO] Granting $user_name permissions"
usermod -aG sudo $user_name

echo "[INFO] Setting $user_name account password"
passwd $user_name
echo "[INFO] Password for $user_name account has been set"
