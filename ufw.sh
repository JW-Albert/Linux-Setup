#!/bin/bash
# 本腳本需以 root 執行！

set -e  # 如果有錯誤就中斷腳本

# === 基本設定 ===
echo "[SETUP] 備份 sshd_config..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%s)

# === 1. 讀取 SSH Port ===
read -p "[INPUT] 請輸入新的 SSH Port（預設為 55555）: " ssh_port
ssh_port=${ssh_port:-55555}
echo "[INFO] 設定 SSH Port 為 $ssh_port"

# 修改 SSH Port
sed -i '/^#\?Port /d' /etc/ssh/sshd_config
echo "Port $ssh_port" >> /etc/ssh/sshd_config

# === 2. 是否允許 root 登入 ===
read -p "[INPUT] 是否允許 root 使用 SSH 登入？(yes/no，預設 no): " allow_root
allow_root=${allow_root:-no}
echo "[INFO] 設定 PermitRootLogin 為 $allow_root"

# 修改 root 登入設定
sed -i '/^#\?PermitRootLogin /d' /etc/ssh/sshd_config
echo "PermitRootLogin $allow_root" >> /etc/ssh/sshd_config

# === 3. 啟用 port 80 與 443？ ===
read -p "[INPUT] 是否開放 port 80？(y/N): " open_80
read -p "[INPUT] 是否開放 port 443？(y/N): " open_443

# === 4. 重新啟動 SSH ===
echo "[INFO] 重新啟動 SSH 服務..."
systemctl restart ssh

# === 5. 安裝並設定 ufw 防火牆 ===
echo "[INFO] 安裝 ufw（Uncomplicated Firewall）..."
apt update -y
apt install ufw -y

echo "[INFO] 設定預設防火牆規則：拒絕所有輸入、允許所有輸出"
ufw default deny incoming
ufw default allow outgoing

echo "[INFO] 開放 TCP port $ssh_port"
ufw allow "$ssh_port"/tcp

if [[ $open_80 =~ ^[yY]$ ]]; then
  echo "[INFO] 開放 TCP port 80"
  ufw allow 80/tcp
fi

if [[ $open_443 =~ ^[yY]$ ]]; then
  echo "[INFO] 開放 TCP port 443"
  ufw allow 443/tcp
fi

echo "[INFO] 啟用 ufw 防火牆..."
ufw --force enable

# === 6. 修改 ICMP DROP ===
echo "[INFO] 備份 before.rules..."
cp /etc/ufw/before.rules /etc/ufw/before.rules.bak.$(date +%s)

echo "[INFO] 修改 ICMP echo-request 規則為 DROP..."
sed -i '/-A ufw-before-input -p icmp --icmp-type destination-unreachable/s/ACCEPT/DROP/' /etc/ufw/before.rules
sed -i '/-A ufw-before-input -p icmp --icmp-type time-exceeded/s/ACCEPT/DROP/' /etc/ufw/before.rules
sed -i '/-A ufw-before-input -p icmp --icmp-type parameter-problem/s/ACCEPT/DROP/' /etc/ufw/before.rules
sed -i '/-A ufw-before-input -p icmp --icmp-type echo-request/s/ACCEPT/DROP/' /etc/ufw/before.rules

echo "[INFO] 重新載入 ufw 防火牆規則..."
ufw reload

# === 完成提示 ===
echo
echo "[DONE] 所有設定已完成！"
echo "[INFO] 請使用 SSH port $ssh_port 登入系統。"
