#!/bin/bash

echo "[INFO] Updating apt"
sudo apt update -y && sudo apt upgrade -y

echo "[INFO] Installing systemd-timesyncd"
sudo apt install systemd-timesyncd -y

echo "[INFO] Installing hwcloc package util-linux-extra"
sudo apt install util-linux-extra -y

echo "[INFO] Setting timezone to Asia/Taipei"
sudo timedatectl set-timezone Asia/Taipei

echo "[INFO] Enabling and starting time sync service"
sudo systemctl enable systemd-timesyncd --now

echo "[INFO] Backing up original timesyncd.conf"
sudo cp /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf.bak.$(date +%s)

echo "[INFO] Clearing old NTP settings"
sudo sed -i '/^NTP=/d' /etc/systemd/timesyncd.conf
sudo sed -i '/^FallbackNTP=/d' /etc/systemd/timesyncd.conf

echo "[INFO] Ensuring [Time] section exists"
if ! grep -q "^\[Time\]" /etc/systemd/timesyncd.conf; then
    echo "[Time]" | sudo tee -a /etc/systemd/timesyncd.conf
fi

echo "[INFO] Setting NTP to Taiwan Standard Time servers"
sudo sed -i '/^\[Time\]/a NTP=tick.stdtime.gov.tw tock.stdtime.gov.tw time.stdtime.gov.tw watch.stdtime.gov.tw clock.stdtime.gov.tw' /etc/systemd/timesyncd.conf

echo "[INFO] Setting hardware clock to local time"
sudo timedatectl set-local-rtc 1

echo "[INFO] Restarting timesyncd and enabling NTP sync"
sudo systemctl restart systemd-timesyncd
sudo timedatectl set-ntp true

echo "[INFO] Writing system time to hardware clock"
sudo hwclock -w

echo "[INFO] Displaying current time status"
sudo timedatectl
sudo hwclock --show
