#!/bin/bash
apt update -y && apt upgrade -y && \
apt install sudo ufw wget curl systemd-timesyncd -y && \
ufw allow 22/tcp && \
#ufw allow 55555/tcp && \
ufw default deny incoming && \
ufw default allow outgoing && \
ufw enable && \
ufw status && \
echo "UFW turn on!" && \
timedatectl set-timezone Asia/Taipei && \
systemctl enable systemd-timesyncd --now && \
timedatectl set-ntp true && \
hwclock --systohc && \
hwclock --show && \
echo "System and Hareway time updated!" && \
echo "System will reboot in 5 seconds..." && \
sleep 5 && \
reboot
