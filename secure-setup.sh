#!/bin/bash
# =========================================================
# One-click installation and configuration of Fail2ban + PortSentry + SSH + UFW security combination
# Tested on Debian / Ubuntu
# =========================================================

set -e

echo "🔒 Starting Fail2ban and PortSentry installation..."

sudo apt update -y
sudo apt install -y fail2ban portsentry ufw

# =========================================================
# STEP 1. Modify SSH settings
# =========================================================
echo "⚙️ Setting SSH Port..."
read -p "Please enter SSH port (default: 55555): " ssh_port
ssh_port=${ssh_port:-55555}
echo "Setting SSH Port to $ssh_port..."
sudo sed -i 's/^#Port .*/Port '"$ssh_port"'/' /etc/ssh/sshd_config
sudo sed -i 's/^Port .*/Port '"$ssh_port"'/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# =========================================================
# STEP 2. Configure firewall
# =========================================================
echo "🧱 Configuring UFW firewall..."

sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow $ssh_port/tcp

# Remove ICMP (ping) packets
sudo sed -i '/-A ufw-before-input -p icmp --icmp-type destination-unreachable/s/ACCEPT/DROP/' /etc/ufw/before.rules
sudo sed -i '/-A ufw-before-input -p icmp --icmp-type time-exceeded/s/ACCEPT/DROP/' /etc/ufw/before.rules
sudo sed -i '/-A ufw-before-input -p icmp --icmp-type parameter-problem/s/ACCEPT/DROP/' /etc/ufw/before.rules
sudo sed -i '/-A ufw-before-input -p icmp --icmp-type echo-request/s/ACCEPT/DROP/' /etc/ufw/before.rules

sudo ufw logging on
sudo ufw --force enable

# =========================================================
# STEP 3. Fail2ban configuration
# =========================================================
echo "⚙️ Configuring Fail2ban..."

sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.bak 2>/dev/null || true

sudo tee /etc/fail2ban/jail.local >/dev/null <<'EOF'
[DEFAULT]
bantime  = 7d
findtime  = 5m
maxretry = 3
backend  = auto

[sshd]
enabled = true
port    = $ssh_port
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
# STEP 4. PortSentry configuration
# =========================================================
echo "⚙️ Configuring PortSentry..."

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
# STEP 5. Start services
# =========================================================
echo "🚀 Starting services..."

sudo systemctl enable fail2ban
sudo systemctl restart fail2ban

sudo systemctl enable portsentry
sudo systemctl restart portsentry

# =========================================================
# STEP 6. Display status
# =========================================================
echo
echo "======================================"
echo "✅ Installation and configuration completed! Current service status:"
echo "======================================"
sudo systemctl status ssh --no-pager | grep Active
sudo systemctl status ufw --no-pager | grep Active
sudo systemctl status fail2ban --no-pager | grep Active
sudo systemctl status portsentry --no-pager | grep Active

echo
echo "🔍 Checking Fail2ban Jail status..."
sudo fail2ban-client status

echo
echo "🎯 System has enabled enhanced security settings:"
echo " - SSH Port: $ssh_port"
echo " - ICMP packets blocked (ping will not respond)"
echo " - Fail2ban + PortSentry started"
echo " - UFW firewall enabled"
echo
echo "💡 To login to server, use: ssh -p $ssh_port user@your-server-ip"
echo "💡 Test blocking: sudo fail2ban-client set ufw banip 1.2.3.4"
echo "💡 View blocked IPs: sudo iptables -L -n | grep DROP"
