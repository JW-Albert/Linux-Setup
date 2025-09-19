#!/bin/bash

# 載入配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/config.sh"

# 設定錯誤處理
set -e

# 建立日誌目錄
mkdir -p "$TELL_ME_LOGS"
LOG_FILE="$TELL_ME_LOGS/notify.log"

# 日誌函數
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "開始執行開機後通知腳本"

# Email configuration (使用統一配置)
SMTP_SERVER="$SMTP_SERVER"
SMTP_PORT="$SMTP_PORT"
SENDER_EMAIL="$SENDER_EMAIL"
SENDER_PASSWORD="$SENDER_PASSWORD"
RECIPIENT_EMAIL="$RECIPIENT_EMAIL"

# Get system information
HOSTNAME=$(hostname)
IP_ADDRESS=$(hostname -I | awk '{print $1}')
DATE=$(date '+%Y-%m-%d %H:%M:%S')

log "系統資訊 - 主機名: $HOSTNAME, IP: $IP_ADDRESS"

# Create email content
SUBJECT="System Information: $HOSTNAME"
BODY="System Information Report

Date: $DATE
Hostname: $HOSTNAME
IP Address: $IP_ADDRESS
Uptime: $(uptime -p)
Load Average: $(uptime | awk -F'load average:' '{print $2}')
Disk Usage: $(df -h / | awk 'NR==2 {print $5}')
Memory Usage: $(free -h | awk 'NR==2 {printf "%.1f%%", $3/$2*100}')
"

log "準備發送開機後通知郵件到: $RECIPIENT_EMAIL"

# Send email using curl
echo "Subject: $SUBJECT

$BODY" | curl -s \
    --url "smtp://$SMTP_SERVER:$SMTP_PORT" \
    --mail-from "$SENDER_EMAIL" \
    --mail-rcpt "$RECIPIENT_EMAIL" \
    --ssl-reqd \
    --user "$SENDER_EMAIL:$SENDER_PASSWORD" \
    --upload-file - \
    --mail-rcpt-allowfails \
    --fail-with-body

# Check if email was sent successfully
if [ $? -eq 0 ]; then
    log "開機後通知郵件發送成功"
else
    log "開機後通知郵件發送失敗"
    exit 1
fi 
