#!/bin/bash

echo "[SETUP] 備份 sshd_config..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%s)

# === 1. 讀取 SSH Port ===
read -p "[INPUT] 請輸入新的 SSH Port（預設為 55555）: " ssh_port
ssh_port=${ssh_port:-55555}
echo "[INFO] 設定 SSH Port 為 $ssh_port"

# 修改 SSH Port
sudo sed -i '/^#\?Port /d' /etc/ssh/sshd_config
echo "Port $ssh_port" | sudo tee -a /etc/ssh/sshd_config

# === 2. 是否允許 root 登入 ===
read -p "[INPUT] 是否允許 root 使用 SSH 登入？(yes/no，預設 no): " allow_root
allow_root=${allow_root:-no}
echo "[INFO] 設定 PermitRootLogin 為 $allow_root"

# 修改 root 登入設定
sudo sed -i '/^#\?PermitRootLogin /d' /etc/ssh/sshd_config
echo "PermitRootLogin $allow_root" | sudo tee -a /etc/ssh/sshd_config

# === 3. 重新啟動 SSH ===
echo "[INFO] 重新啟動 SSH 服務..."
sudo systemctl restart ssh

echo "[DONE] SSH 設定已完成，請使用 port $ssh_port 登入"
