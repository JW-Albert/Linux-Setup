#!/bin/bash
# This script needs to be executed as root!

# echo "[INFO] 更新 apt"
apt update && apt upgrade -y

echo "[INFO] Installing sudo"
apt install sudo -y

echo "[INFO] Creating albert account"
useradd -m -s /bin/bash albert

echo "[INFO] Granting albert permissions"
usermod -aG sudo albert

echo "[INFO] Setting albert account password"
passwd albert
