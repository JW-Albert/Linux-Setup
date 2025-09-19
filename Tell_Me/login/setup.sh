#!/bin/bash

# 載入配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/config.sh"

# 設定錯誤處理
set -e

# 建立日誌目錄
mkdir -p "$TELL_ME_LOGS"
LOG_FILE="$TELL_ME_LOGS/setup_login_notify.log"

# 日誌函數
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "開始設定登入通知"

SCRIPT_PATH="$TELL_ME_LOGIN/notify.sh"
PAM_FILE="/etc/pam.d/sshd"

# 確保腳本存在
if [ ! -f "$SCRIPT_PATH" ]; then
    log "錯誤: 找不到登入通知腳本 $SCRIPT_PATH"
    exit 1
fi

# 確保腳本有執行權限
chmod +x "$SCRIPT_PATH"
log "已設定登入通知腳本執行權限"

# 確保 PAM 裡有這行，沒有才加
if ! grep -q "$SCRIPT_PATH" "$PAM_FILE"; then
    echo "session optional pam_exec.so seteuid $SCRIPT_PATH" >> "$PAM_FILE"
    log "PAM sshd 已加上 notify.sh 設定"
else
    log "PAM sshd 已經存在 notify.sh 設定"
fi

log "登入通知設定完成"
