#!/bin/bash
# This script needs to be executed as root

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

# === 3. Restart SSH ===
echo "[INFO] Restarting SSH service..."
systemctl restart ssh

echo "[DONE] SSH configuration completed, please login using port $ssh_port"
