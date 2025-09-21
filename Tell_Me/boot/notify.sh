#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 設定基本變數（在載入配置之前）
TELL_ME_LOGS="/var/log/tell_me"

# 建立日誌目錄
sudo mkdir -p "$TELL_ME_LOGS"
LOG_FILE="$TELL_ME_LOGS/notify.log"

# 日誌函數
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "開始執行開機後通知腳本"

# 檢查配置檔案是否存在
CONFIG_FILE="/etc/tell_me/config/config.sh"
if [ ! -f "$CONFIG_FILE" ]; then
    log "錯誤: 找不到配置檔案 $CONFIG_FILE"
    exit 1
fi

# 載入配置
source "$CONFIG_FILE"
log "配置檔案載入成功"

# Get system information
HOSTNAME=$(hostname)
IP_ADDRESS=$(hostname -I | awk '{print $1}')
DATE=$(date '+%Y-%m-%d %H:%M:%S')

log "系統資訊 - 主機名: $HOSTNAME, IP: $IP_ADDRESS"

log "準備發送開機後通知到 Discord"

# 建立 Discord 訊息
# 直接使用 free -h 的資訊，更清楚易懂
MEMORY_INFO=$(free -h | awk 'NR==2{print "已用: " $3 " / 總計: " $2 " (可用: " $7 ")"}')
log "記憶體資訊: $MEMORY_INFO"

DISCORD_MESSAGE="🚀 **系統開機通知**\n\n📊 **系統資訊**\n\`\`\`\n主機名: $HOSTNAME\nIP 地址: $IP_ADDRESS\n開機時間: $DATE\n運行時間: $(uptime -p)\n\`\`\`\n\n📈 **系統狀態**\n\`\`\`\n負載平均: $(uptime | awk -F'load average:' '{print $2}')\n磁碟使用率: $(df -h / | awk 'NR==2 {print $5}')\n記憶體: $MEMORY_INFO\n\`\`\`"

# 發送 Discord 通知
log "開始發送 Discord 通知..."
log "Webhook URL: $DISCORD_WEBHOOK_URL"

curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"username\":\"$DISCORD_USERNAME\",\"avatar_url\":\"$DISCORD_AVATAR_URL\",\"content\":\"$DISCORD_MESSAGE\"}" \
     "$DISCORD_WEBHOOK_URL" 2>&1 | tee -a "$LOG_FILE"

# Check if Discord notification was sent successfully
if [ $? -eq 0 ]; then
    log "開機後通知 Discord 發送成功"
    exit 0
else
    log "開機後通知 Discord 發送失敗"
    exit 1
fi