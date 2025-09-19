#!/bin/bash

echo "[INFO] 更新 apt"
sudo apt update -y && sudo apt upgrade -y

echo "[INFO] 安裝 systemd-timesyncd"
sudo apt install systemd-timesyncd -y

echo "[INFO] 安裝 hwcloc 套件 util-linux-extra"
sudo apt install util-linux-extra -y

echo "[INFO] 設定時區為 Asia/Taipei"
sudo timedatectl set-timezone Asia/Taipei

echo "[INFO] 啟用並啟動時間同步服務"
sudo systemctl enable systemd-timesyncd --now

echo "[INFO] 備份原始 timesyncd.conf"
sudo cp /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf.bak.$(date +%s)

echo "[INFO] 清除舊 NTP 設定"
sudo sed -i '/^NTP=/d' /etc/systemd/timesyncd.conf
sudo sed -i '/^FallbackNTP=/d' /etc/systemd/timesyncd.conf

echo "[INFO] 確保 [Time] 區塊存在"
if ! grep -q "^\[Time\]" /etc/systemd/timesyncd.conf; then
    echo "[Time]" | sudo tee -a /etc/systemd/timesyncd.conf
fi

echo "[INFO] 設定 NTP 為台灣標準時間伺服器"
sudo sed -i '/^\[Time\]/a NTP=tick.stdtime.gov.tw tock.stdtime.gov.tw time.stdtime.gov.tw watch.stdtime.gov.tw clock.stdtime.gov.tw' /etc/systemd/timesyncd.conf

echo "[INFO] 設定硬體時鐘為本地時鐘"
sudo timedatectl set-local-rtc 1

echo "[INFO] 重新啟動 timesyncd 並啟用 NTP 同步"
sudo systemctl restart systemd-timesyncd
sudo timedatectl set-ntp true

echo "[INFO] 將系統時間寫入硬體時鐘"
sudo hwclock -w

echo "[INFO] 顯示目前時間狀態"
sudo timedatectl
sudo hwclock --show
