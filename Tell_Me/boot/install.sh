#!/bin/bash

# 載入配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/config.sh"

# 設定錯誤處理
set -e

# 建立日誌目錄
mkdir -p "$TELL_ME_LOGS"
LOG_FILE="$TELL_ME_LOGS/install.log"

# 日誌函數
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "開始設定開機後 IP 通知服務"

# 安裝 curl
log "安裝 curl..."
sudo apt update
sudo apt install -y curl

# 建立目標目錄
log "建立目錄結構..."
mkdir -p "$TELL_ME_BOOT"
mkdir -p "$TELL_ME_LOGS"
mkdir -p "$TELL_ME_HOME/config"

# 設定腳本權限並移動
log "設定腳本權限..."
chmod +x notify.sh

log "移動檔案到目標目錄..."
mv notify.sh "$TELL_ME_BOOT/"
cp "$SCRIPT_DIR/../config/config.sh" "$TELL_ME_HOME/config/"

# 安裝 systemd 服務
log "安裝 systemd 服務..."
# 複製服務檔案並替換路徑
sed "s|ExecStart=.*|ExecStart=$TELL_ME_BOOT/notify.sh|" "$SCRIPT_DIR/boot-notify.service" | sudo tee /etc/systemd/system/boot-notify.service > /dev/null

# 啟用並啟動服務
log "啟用並啟動服務..."
sudo systemctl daemon-reload
sudo systemctl enable boot-notify.service
sudo systemctl start boot-notify.service

# 檢查服務狀態
if systemctl is-active --quiet boot-notify.service; then
    log "服務啟動成功"
else
    log "服務啟動失敗"
    exit 1
fi

log "開機後通知服務設定完成"
