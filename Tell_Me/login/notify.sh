#!/bin/bash

# 載入配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/config.sh"

# 設定錯誤處理
set -e

# 建立日誌目錄
mkdir -p "$TELL_ME_LOGS"
LOG_FILE="$TELL_ME_LOGS/login_notify.log"

# 日誌函數
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "登入通知觸發"

# Email configuration (使用統一配置)
SMTP_SERVER="$SMTP_SERVER"
SMTP_PORT="$SMTP_PORT"
SENDER_EMAIL="$SENDER_EMAIL"
SENDER_PASSWORD="$SENDER_PASSWORD"
RECIPIENT_EMAIL="$RECIPIENT_EMAIL"

# 獲取登入資訊
USER_NAME=$(whoami)
HOSTNAME=$(hostname)
DATE=$(date '+%Y-%m-%d %H:%M:%S')
IP_ADDR=$(echo $SSH_CONNECTION | awk '{print $1}')

# 如果沒有 SSH_CONNECTION 環境變數，嘗試其他方法獲取 IP
if [ -z "$IP_ADDR" ]; then
    IP_ADDR=$(who am i | awk '{print $5}' | sed 's/[()]//g')
fi

# 如果還是沒有 IP，使用本地 IP
if [ -z "$IP_ADDR" ]; then
    IP_ADDR=$(hostname -I | awk '{print $1}')
fi

log "登入資訊 - 使用者: $USER_NAME, 主機: $HOSTNAME, IP: $IP_ADDR"

# 建立郵件內容
SUBJECT="Login Alert: $USER_NAME on $HOSTNAME"
BODY="A user has logged in:

Date: $DATE
User: $USER_NAME
Host: $HOSTNAME
Source IP: $IP_ADDR
Terminal: $TERM
Session: $SSH_TTY
"

log "準備發送登入通知到 Discord"

# 建立 Discord 訊息
DISCORD_MESSAGE="🔐 **登入通知**

**使用者**: $USER_NAME
**主機**: $HOSTNAME
**時間**: $DATE
**來源 IP**: $IP_ADDR
**終端**: $TERM
**會話**: $SSH_TTY"

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

# 檢查 Discord 通知發送結果
if [ $? -eq 0 ]; then
    log "登入通知 Discord 發送成功"
else
    log "登入通知 Discord 發送失敗"
    exit 1
fi
