#!/bin/bash
# 本腳本需以 root 身份執行！

echo "[INFO] 更新 apt"
apt update -y && apt upgrade -y

echo "[INFO] 安裝 sudo"
apt install sudo -y

echo "[INFO] 建立 albert 帳戶"
useradd -m -s /bin/bash albert

echo "[INFO] 給予 albert 權限"
usermod -aG sudo albert

echo "[INFO] 設定 albert 帳戶密碼"
passwd albert
