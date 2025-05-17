#!/bin/bash
# This script needs to be executed as root!

set -e  # Exit script if there's an error

# === Basic Setup ===
echo "[SETUP] Backing up sshd_config..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%s)

# === 1. Read SSH Port ===
read -p "[INPUT] Please enter new SSH Port (default: 55555): " ssh_port
ssh_port=${ssh_port:-55555}
echo "[INFO] Setting SSH Port to $ssh_port"

# Modify SSH Port
sed -i '/^#\?Port /d' /etc/ssh/sshd_config
echo "Port $ssh_port" >> /etc/ssh/sshd_config

# === 2. Allow root login ===
read -p "[INPUT] Allow root SSH login? (yes/no, default: no): " allow_root
allow_root=${allow_root:-no}
echo "[INFO] Setting PermitRootLogin to $allow_root"

# Modify root login settings
sed -i '/^#\?PermitRootLogin /d' /etc/ssh/sshd_config
echo "PermitRootLogin $allow_root" >> /etc/ssh/sshd_config

# === 3. Enable ports 80 and 443? ===
read -p "[INPUT] Open port 80? (y/N): " open_80
read -p "[INPUT] Open port 443? (y/N): " open_443

# === 4. Restart SSH ===
echo "[INFO] Restarting SSH service..."
systemctl restart ssh

# === 5. Install and configure ufw firewall ===
echo "[INFO] Installing ufw (Uncomplicated Firewall)..."
apt update -y
apt install ufw -y

echo "[INFO] Setting default firewall rules: deny incoming, allow outgoing"
ufw default deny incoming
ufw default allow outgoing

echo "[INFO] Opening TCP port $ssh_port"
ufw allow "$ssh_port"/tcp

if [[ $open_80 =~ ^[yY]$ ]]; then
  echo "[INFO] Opening TCP port 80"
  ufw allow 80/tcp
fi

if [[ $open_443 =~ ^[yY]$ ]]; then
  echo "[INFO] Opening TCP port 443"
  ufw allow 443/tcp
fi

echo "[INFO] Enabling ufw firewall..."
ufw --force enable

# === 6. Modify ICMP DROP ===
echo "[INFO] Backing up before.rules..."
cp /etc/ufw/before.rules /etc/ufw/before.rules.bak.$(date +%s)

echo "[INFO] Modifying ICMP echo-request rules to DROP..."
sed -i '/-A ufw-before-input -p icmp --icmp-type destination-unreachable/s/ACCEPT/DROP/' /etc/ufw/before.rules
sed -i '/-A ufw-before-input -p icmp --icmp-type time-exceeded/s/ACCEPT/DROP/' /etc/ufw/before.rules
sed -i '/-A ufw-before-input -p icmp --icmp-type parameter-problem/s/ACCEPT/DROP/' /etc/ufw/before.rules
sed -i '/-A ufw-before-input -p icmp --icmp-type echo-request/s/ACCEPT/DROP/' /etc/ufw/before.rules

echo "[INFO] Reloading ufw firewall rules..."
ufw reload

# === Completion Message ===
echo
echo "[DONE] All configurations completed!"
echo "[INFO] Please login using SSH port $ssh_port."
