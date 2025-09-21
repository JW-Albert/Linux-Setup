#!/bin/bash
# This script needs to be executed as root!

# echo "[INFO] 更新 apt"
apt update && apt upgrade -y

echo "[INFO] Installing sudo"
apt install sudo -y

echo "[INFO] Creating sudo user account"
read -p "[INPUT] 請輸入新使用者名稱（預設為 albert）: " user_name
user_name=${user_name:-albert}
echo "[INFO] 設定使用者名稱為 $user_name"

useradd -m -s /bin/bash $user_name

echo "[INFO] Granting $user_name permissions"
usermod -aG sudo $user_name

echo "[INFO] Setting $user_name account password"
passwd $user_name
echo "[INFO] $user_name 帳戶密碼已設定"
