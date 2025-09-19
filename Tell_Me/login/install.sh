#!/bin/bash

# 載入配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/config.sh"

# 設定錯誤處理
set -e

# 建立日誌目錄
mkdir -p "$TELL_ME_LOGS"
LOG_FILE="$TELL_ME_LOGS/login_notify_install.log"

# 日誌函數
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "開始安裝登入通知服務"

# 安裝 curl
log "安裝 curl..."
sudo apt update
sudo apt install -y curl

# 建立目錄結構
log "建立目錄結構..."
mkdir -p "$TELL_ME_LOGIN"
mkdir -p "$TELL_ME_LOGS"

# 複製腳本到目標目錄
log "複製腳本到目標目錄..."
cp "$SCRIPT_DIR/notify.sh" "$TELL_ME_LOGIN/"
cp "$SCRIPT_DIR/setup.sh" "$TELL_ME_LOGIN/"

# 設定腳本權限
log "設定腳本權限..."
chmod +x "$TELL_ME_LOGIN/notify.sh"
chmod +x "$TELL_ME_LOGIN/setup.sh"

# 安裝 systemd 服務
log "安裝 systemd 服務..."
sudo cp "$SCRIPT_DIR/notify.service" /etc/systemd/system/

# 啟用並啟動服務
log "啟用並啟動服務..."
sudo systemctl daemon-reload
sudo systemctl enable login-notify.service
sudo systemctl start login-notify.service

# 檢查服務狀態
if systemctl is-active --quiet login-notify.service; then
    log "登入通知服務啟動成功"
else
    log "登入通知服務啟動失敗"
    exit 1
fi

log "登入通知服務安裝完成"
log "腳本位置: $TELL_ME_LOGIN/"
log "日誌位置: $TELL_ME_LOGS/"
