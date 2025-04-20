#!/bin/bash
# 本腳本需以 root 身份執行！

echo "[INFO] 安裝 systemd-timesyncd"
apt install systemd-timesyncd -y

echo "[INFO] 設定時區為 Asia/Taipei"
timedatectl set-timezone Asia/Taipei

echo "[INFO] 啟用並啟動時間同步服務"
systemctl enable systemd-timesyncd --now

echo "[INFO] 備份原始 timesyncd.conf"
cp /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf.bak.$(date +%s)

echo "[INFO] 清除舊 NTP 設定"
sed -i '/^NTP=/d' /etc/systemd/timesyncd.conf
sed -i '/^FallbackNTP=/d' /etc/systemd/timesyncd.conf

echo "[INFO] 確保 [Time] 區塊存在"
if ! grep -q "^\[Time\]" /etc/systemd/timesyncd.conf; then
    echo "[Time]" >> /etc/systemd/timesyncd.conf
fi

echo "[INFO] 設定 NTP 為台灣標準時間伺服器"
sed -i '/^\[Time\]/a NTP=tick.stdtime.gov.tw tock.stdtime.gov.tw time.stdtime.gov.tw watch.stdtime.gov.tw clock.stdtime.gov.tw' /etc/systemd/timesyncd.conf

echo "[INFO] 重新啟動 timesyncd 並啟用 NTP 同步"
systemctl restart systemd-timesyncd
timedatectl set-ntp true

echo "[INFO] 將系統時間寫入硬體時鐘"
hwclock --systohc

echo "[INFO] 顯示目前時間狀態"
timedatectl
hwclock --show
