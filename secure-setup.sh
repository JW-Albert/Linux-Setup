#!/bin/bash
# =========================================================
# 一鍵安裝與設定 Fail2ban + PortSentry + SSH + UFW 安全組合
# Tested on Debian / Ubuntu
# =========================================================

set -e

echo "🔒 開始安裝 Fail2ban 與 PortSentry..."

sudo apt update -y
sudo apt install -y fail2ban portsentry ufw

# =========================================================
# STEP 1. 修改 SSH 設定
# =========================================================
echo "⚙️ 修改 SSH Port 為 55555..."
sudo sed -i 's/^#Port .*/Port 55555/' /etc/ssh/sshd_config
sudo sed -i 's/^Port .*/Port 55555/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# =========================================================
# STEP 2. 設定防火牆
# =========================================================
echo "🧱 設定 UFW 防火牆..."

sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 55555/tcp

# 移除 ICMP (ping) 類封包
sudo sed -i '/-A ufw-before-input -p icmp --icmp-type destination-unreachable/s/ACCEPT/DROP/' /etc/ufw/before.rules
sudo sed -i '/-A ufw-before-input -p icmp --icmp-type time-exceeded/s/ACCEPT/DROP/' /etc/ufw/before.rules
sudo sed -i '/-A ufw-before-input -p icmp --icmp-type parameter-problem/s/ACCEPT/DROP/' /etc/ufw/before.rules
sudo sed -i '/-A ufw-before-input -p icmp --icmp-type echo-request/s/ACCEPT/DROP/' /etc/ufw/before.rules

sudo ufw logging on
sudo ufw --force enable

# =========================================================
# STEP 3. Fail2ban 設定
# =========================================================
echo "⚙️ 設定 Fail2ban..."

sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.bak 2>/dev/null || true

sudo tee /etc/fail2ban/jail.local >/dev/null <<'EOF'
[DEFAULT]
bantime  = 7d
findtime  = 5m
maxretry = 3
backend  = auto

[sshd]
enabled = true
port    = 55555
filter  = sshd
logpath = /var/log/auth.log

[ufw]
enabled = true
filter = ufw.aggressive
action = iptables-allports
logpath = /var/log/ufw.log
maxretry = 3
bantime = 7d
EOF

sudo tee /etc/fail2ban/filter.d/ufw.aggressive.conf >/dev/null <<'EOF'
[Definition]
failregex = \[UFW BLOCK\].*SRC=<HOST> DST
ignoreregex =
EOF

# =========================================================
# STEP 4. PortSentry 設定
# =========================================================
echo "⚙️ 設定 PortSentry..."

sudo sed -i 's/^TCP_MODE=.*/TCP_MODE="atcp"/' /etc/default/portsentry
sudo sed -i 's/^UDP_MODE=.*/UDP_MODE="audp"/' /etc/default/portsentry

sudo sed -i 's/^BLOCK_TCP=.*/BLOCK_TCP="1"/' /etc/portsentry/portsentry.conf
sudo sed -i 's/^BLOCK_UDP=.*/BLOCK_UDP="1"/' /etc/portsentry/portsentry.conf
sudo sed -i 's|^KILL_ROUTE=.*|KILL_ROUTE="/sbin/iptables -I INPUT -s $TARGET$ -j DROP"|' /etc/portsentry/portsentry.conf

sudo tee /etc/portsentry/portsentry.ignore.static >/dev/null <<'EOF'
127.0.0.1/32
::1
192.168.0.0/16
10.0.0.0/8
EOF

# =========================================================
# STEP 5. 啟動服務
# =========================================================
echo "🚀 啟動服務..."

sudo systemctl enable fail2ban
sudo systemctl restart fail2ban

sudo systemctl enable portsentry
sudo systemctl restart portsentry

# =========================================================
# STEP 6. 顯示狀態
# =========================================================
echo
echo "======================================"
echo "✅ 安裝與設定完成！目前服務狀態："
echo "======================================"
sudo systemctl status ssh --no-pager | grep Active
sudo systemctl status ufw --no-pager | grep Active
sudo systemctl status fail2ban --no-pager | grep Active
sudo systemctl status portsentry --no-pager | grep Active

echo
echo "🔍 檢查 Fail2ban Jail 狀態..."
sudo fail2ban-client status

echo
echo "🎯 系統已啟用強化安全設定："
echo " - SSH Port: 55555"
echo " - ICMP 封包已封鎖 (ping 無法響應)"
echo " - Fail2ban + PortSentry 已啟動"
echo " - UFW 防火牆已啟用"
echo
echo "💡 如要登入伺服器，請使用： ssh -p 55555 user@your-server-ip"
echo "💡 測試封鎖可用： sudo fail2ban-client set ufw banip 1.2.3.4"
echo "💡 查看被封鎖 IP： sudo iptables -L -n | grep DROP"
