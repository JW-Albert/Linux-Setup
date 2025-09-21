#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 設定基本變數（在載入配置之前）
TELL_ME_LOGS="/var/log/tell_me"

# 建立日誌目錄
sudo mkdir -p "$TELL_ME_LOGS"
LOG_FILE="$TELL_ME_LOGS/setup_login_notify.log"

# 日誌函數
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "開始設定登入通知"

# 檢查配置檔案是否存在
if [ ! -f "$SCRIPT_DIR/../config/config.sh" ]; then
    log "錯誤: 找不到配置檔案 $SCRIPT_DIR/../config/config.sh"
    exit 1
fi

# 載入配置
source "$SCRIPT_DIR/../config/config.sh"
log "配置檔案載入成功"

# 檢查變數是否正確設定
log "TELL_ME_HOME: $TELL_ME_HOME"
log "TELL_ME_LOGIN: $TELL_ME_LOGIN"

SCRIPT_PATH="$TELL_ME_LOGIN/notify.sh"
PAM_FILE="/etc/pam.d/sshd"

log "檢查腳本路徑: $SCRIPT_PATH"

# 確保腳本存在
if [ ! -f "$SCRIPT_PATH" ]; then
    log "錯誤: 找不到登入通知腳本 $SCRIPT_PATH"
    log "檢查目錄內容:"
    ls -la "$TELL_ME_LOGIN/" | tee -a "$LOG_FILE"
    exit 1
fi

log "腳本檔案存在，檢查權限"

# 確保腳本有執行權限
chmod +x "$SCRIPT_PATH"
log "已設定登入通知腳本執行權限"

# 檢查 PAM 檔案是否存在
if [ ! -f "$PAM_FILE" ]; then
    log "錯誤: 找不到 PAM 檔案 $PAM_FILE"
    exit 1
fi

log "檢查 PAM 設定"

# 確保 PAM 裡有這行，沒有才加
if ! grep -q "$SCRIPT_PATH" "$PAM_FILE"; then
    echo "session optional pam_exec.so seteuid $SCRIPT_PATH" >> "$PAM_FILE"
    log "PAM sshd 已加上 notify.sh 設定"
else
    log "PAM sshd 已經存在 notify.sh 設定"
fi

log "登入通知設定完成"
