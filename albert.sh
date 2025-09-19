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
# 檢查是否通過環境變數或參數指定密碼
if [ -n "$ALBERT_PASSWORD" ]; then
    echo "使用環境變數中的密碼"
    PASSWORD="$ALBERT_PASSWORD"
elif [ -n "$1" ]; then
    echo "使用命令行參數中的密碼"
    PASSWORD="$1"
else
    echo "使用預設密碼: albert123"
    PASSWORD="albert123"
fi

echo "albert:$PASSWORD" | chpasswd
echo "[INFO] albert 帳戶密碼已設定"
