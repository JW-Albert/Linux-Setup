#!/bin/bash
# This script needs to be executed as root!

set -e  # Exit script if there is an error

clear

echo "[INFO] Set root password"
passwd

echo "[INFO] Update and upgrade apt"
apt update && apt upgrade -y

echo "[INFO] Install sudo wget curl"
apt install sudo wget curl -y

echo "[INFO] Creating user account"
read -p "[INPUT] Please enter the new username (default: albert): " user_name
user_name=${user_name:-albert}
echo "[INFO] Set user name to $user_name"

useradd -m -s /bin/bash $user_name

echo "[INFO] Granting $user_name permissions"
usermod -aG sudo $user_name

echo "[INFO] Setting $user_name account password"
passwd $user_name
echo "[INFO] $user_name account password set"

echo "[SETUP] Backup sshd_config..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%s)

echo "[SETUP] Set SSH port"
read -p "[INPUT] Please enter the new SSH port (default: 55555): " ssh_port
ssh_port=${ssh_port:-55555}
echo "[INFO] Set SSH port to $ssh_port"

sed -i '/^#\?Port /d' /etc/ssh/sshd_config
echo "Port $ssh_port" | tee -a /etc/ssh/sshd_config

echo "[SETUP] Set SSH root login"
read -p "[INPUT] Allow root login? (yes/no, default: no): " allow_root
allow_root=${allow_root:-no}
echo "[INFO] Set SSH root login to $allow_root"

sed -i '/^#\?PermitRootLogin /d' /etc/ssh/sshd_config
echo "PermitRootLogin $allow_root" | tee -a /etc/ssh/sshd_config

echo "[SETUP] Restart SSH service"
systemctl restart ssh

echo "[DONE] SSH setup completed, please use SSH port $ssh_port to login"

echo "[SETUP] Install ufw"
apt install ufw -y

echo "[SETUP] Set default firewall rules"
ufw default deny incoming
ufw default allow outgoing

echo "[SETUP] Allow SSH port"
ufw allow $ssh_port/tcp

read -p "[INPUT] Allow port 80? (y/N): " open_80
read -p "[INPUT] Allow port 443? (y/N): " open_443

if [[ $open_80 =~ ^[yY]$ ]]; then
  echo "[SETUP] Allow port 80"
  ufw allow 80/tcp
fi

if [[ $open_443 =~ ^[yY]$ ]]; then
  echo "[SETUP] Allow port 443"
  ufw allow 443/tcp
fi

echo "[SETUP] Enable ufw"
ufw --force enable

echo "[SETUP] Backup before.rules"
cp /etc/ufw/before.rules /etc/ufw/before.rules.bak.$(date +%s)

echo "[SETUP] Set ICMP DROP"
sed -i '/-A ufw-before-input -p icmp --icmp-type destination-unreachable/s/ACCEPT/DROP/' /etc/ufw/before.rules
sed -i '/-A ufw-before-input -p icmp --icmp-type time-exceeded/s/ACCEPT/DROP/' /etc/ufw/before.rules
sed -i '/-A ufw-before-input -p icmp --icmp-type parameter-problem/s/ACCEPT/DROP/' /etc/ufw/before.rules
sed -i '/-A ufw-before-input -p icmp --icmp-type echo-request/s/ACCEPT/DROP/' /etc/ufw/before.rules

ufw reload

echo "[INFO] Install systemd-timesyncd"
apt install systemd-timesyncd -y

echo "[INFO] Install hwcloc util-linux-extra"
apt install util-linux-extra -y

echo "[INFO] Set timezone to Asia/Taipei"
timedatectl set-timezone Asia/Taipei

echo "[INFO] Enable and start time synchronization service"
systemctl enable systemd-timesyncd --now

echo "[INFO] Backup original timesyncd.conf"
cp /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf.bak.$(date +%s)

echo "[INFO] Clear old NTP settings"
sed -i '/^NTP=/d' /etc/systemd/timesyncd.conf
sed -i '/^FallbackNTP=/d' /etc/systemd/timesyncd.conf

echo "[INFO] Ensure [Time] block exists"
if ! grep -q "^\[Time\]" /etc/systemd/timesyncd.conf; then
    echo "[Time]" | tee -a /etc/systemd/timesyncd.conf
fi

echo "[INFO] Set NTP to Taiwan standard time server"
sed -i '/^\[Time\]/a NTP=tick.stdtime.gov.tw tock.stdtime.gov.tw time.stdtime.gov.tw watch.stdtime.gov.tw clock.stdtime.gov.tw' /etc/systemd/timesyncd.conf

echo "[INFO] Set hardware clock to local time"
timedatectl set-local-rtc 1

echo "[INFO] Restart timesyncd and enable NTP synchronization"
systemctl restart systemd-timesyncd
timedatectl set-ntp true

echo "[INFO] Write system time to hardware clock"
hwclock -w

clear

echo "[INFO] Show current time status"
timedatectl
hwclock --show

echo "\n\n [DONE] All setup completed"

echo "[INFO] Rebooting in 3 seconds"
sleep 3

reboot