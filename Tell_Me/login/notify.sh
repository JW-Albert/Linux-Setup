#!/bin/bash

# 載入配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "/etc/tell_me/config/config.sh"

# 設定錯誤處理
set -e

# 建立日誌目錄
sudo mkdir -p "$TELL_ME_LOGS"
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
# 嘗試多種方法獲取實際登入使用者
USER_NAME=""
if [ -n "$PAM_USER" ]; then
    USER_NAME="$PAM_USER"
elif [ -n "$USER" ]; then
    USER_NAME="$USER"
elif [ -n "$LOGNAME" ]; then
    USER_NAME="$LOGNAME"
else
    USER_NAME=$(whoami)
fi

HOSTNAME=$(hostname)
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# 獲取來源 IP 地址
IP_ADDR=""
if [ -n "$SSH_CONNECTION" ]; then
    IP_ADDR=$(echo $SSH_CONNECTION | awk '{print $1}')
elif [ -n "$SSH_CLIENT" ]; then
    IP_ADDR=$(echo $SSH_CLIENT | awk '{print $1}')
else
    # 嘗試從 who 命令獲取
    IP_ADDR=$(who am i | awk '{print $5}' | sed 's/[()]//g')
fi

# 如果還是沒有 IP，使用本地 IP
if [ -z "$IP_ADDR" ] || [ "$IP_ADDR" = "localhost" ]; then
    IP_ADDR=$(hostname -I | awk '{print $1}')
fi

# 調試資訊
log "環境變數調試:"
log "  PAM_USER: $PAM_USER"
log "  USER: $USER"
log "  LOGNAME: $LOGNAME"
log "  SSH_CONNECTION: $SSH_CONNECTION"
log "  SSH_CLIENT: $SSH_CLIENT"
log "  TERM: $TERM"
log "  SSH_TTY: $SSH_TTY"

log "登入資訊 - 使用者: $USER_NAME, 主機: $HOSTNAME, IP: $IP_ADDR"

# 建立 Discord 通知內容

log "準備發送登入通知到 Discord"

# 建立 Discord 訊息
DISCORD_MESSAGE="🔐 **登入通知**\n\n**使用者**: $USER_NAME\n**主機**: $HOSTNAME\n**時間**: $DATE\n**來源 IP**: $IP_ADDR\n**終端**: $TERM\n**會話**: $SSH_TTY"

# 發送 Discord 通知
log "開始發送 Discord 通知..."
log "Webhook URL: $DISCORD_WEBHOOK_URL"

curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"username\":\"$DISCORD_USERNAME\",\"avatar_url\":\"$DISCORD_AVATAR_URL\",\"content\":\"$DISCORD_MESSAGE\"}" \
     "$DISCORD_WEBHOOK_URL" 2>&1 | tee -a "$LOG_FILE"

# 檢查 Discord 通知發送結果
if [ $? -eq 0 ]; then
    log "登入通知 Discord 發送成功"
else
    log "登入通知 Discord 發送失敗"
    exit 1
fi
