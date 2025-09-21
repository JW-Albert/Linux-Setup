#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 設定基本變數（在載入配置之前）
TELL_ME_HOME="$HOME/Tell_Me"
TELL_ME_LOGS="$TELL_ME_HOME/logs"

# 建立日誌目錄
mkdir -p "$TELL_ME_LOGS"
LOG_FILE="$TELL_ME_LOGS/notify.log"

# 日誌函數
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "開始執行開機後通知腳本"

# 檢查配置檔案是否存在
if [ ! -f "$SCRIPT_DIR/../config/config.sh" ]; then
    log "錯誤: 找不到配置檔案 $SCRIPT_DIR/../config/config.sh"
    exit 1
fi

# 載入配置
source "$SCRIPT_DIR/../config/config.sh"
log "配置檔案載入成功"

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

log "準備發送開機後通知到 Discord"

# 建立 Discord 訊息
DISCORD_MESSAGE="🚀 **系統開機通知**

**主機名**: $HOSTNAME
**IP 地址**: $IP_ADDRESS
**開機時間**: $DATE
**運行時間**: $(uptime -p)
**負載平均**: $(uptime | awk -F'load average:' '{print $2}')
**磁碟使用率**: $(df -h / | awk 'NR==2 {print $5}')
**記憶體使用率**: $(free -h | awk 'NR==2 {printf "%.1f%%", $3/$2*100}')"

# 發送 Discord 通知
log "開始發送 Discord 通知..."
log "Webhook URL: $DISCORD_WEBHOOK_URL"

# 使用 printf 來正確處理換行符號
printf '{"username":"%s","avatar_url":"%s","content":"%s"}' \
    "$DISCORD_USERNAME" \
    "$DISCORD_AVATAR_URL" \
    "$DISCORD_MESSAGE" | curl -H "Content-Type: application/json" \
    -X POST \
    --data-binary @- \
    "$DISCORD_WEBHOOK_URL" 2>&1 | tee -a "$LOG_FILE"

# Check if Discord notification was sent successfully
if [ $? -eq 0 ]; then
    log "開機後通知 Discord 發送成功"
else
    log "開機後通知 Discord 發送失敗"
    exit 1
fi 
