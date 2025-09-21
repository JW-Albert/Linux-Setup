#!/bin/bash

# Tell_Me 統一安裝腳本
# 此腳本會安裝所有 Tell_Me 相關的服務

# 設定錯誤處理
set -e

# 載入配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/Tell_Me/config/config.sh"

# 建立目錄結構
create_tell_me_structure

log "開始安裝 Tell_Me 服務套件"

# 檢查依賴
log "檢查系統依賴..."
if ! check_dependencies; then
    log "安裝缺少的依賴..."
    sudo apt update
    sudo apt install -y curl
fi

# 安裝登入通知服務
log "安裝登入通知服務..."
if [ -f "$SCRIPT_DIR/Tell_Me/login/install.sh" ]; then
    bash "$SCRIPT_DIR/Tell_Me/login/install.sh"
    log "登入通知服務安裝完成"
else
    log "警告: 找不到 Tell_Me/login/install.sh"
fi

# 安裝開機後通知服務
log "安裝開機後通知服務..."
if [ -f "$SCRIPT_DIR/Tell_Me/boot/install.sh" ]; then
    cd "$SCRIPT_DIR/Tell_Me/boot"
    bash install.sh
    log "開機後通知服務安裝完成"
else
    log "警告: 找不到 Tell_Me/boot/install.sh"
fi

# 複製管理工具到系統目錄
log "複製管理工具..."
if [ -f "$SCRIPT_DIR/Tell_Me/manage_tell_me.sh" ]; then
    cp "$SCRIPT_DIR/Tell_Me/manage_tell_me.sh" "$TELL_ME_HOME/"
    chmod +x "$TELL_ME_HOME/manage_tell_me.sh"
    log "管理工具已複製到: $TELL_ME_HOME/manage_tell_me.sh"
else
    log "警告: 找不到管理工具 Tell_Me/manage_tell_me.sh"
fi

# 設定日誌輪轉
log "設定日誌輪轉..."
cat > "$TELL_ME_HOME/cleanup_logs.sh" << 'EOF'
#!/bin/bash
source "$HOME/Tell_Me/config/config.sh"
cleanup_old_logs
EOF

chmod +x "$TELL_ME_HOME/cleanup_logs.sh"

# 建立 crontab 任務清理舊日誌
(crontab -l 2>/dev/null; echo "0 2 * * * $TELL_ME_HOME/cleanup_logs.sh") | crontab -

# 檢查所有服務狀態
log "檢查服務狀態..."
services=("login-notify.service" "boot-notify.service")
for service in "${services[@]}"; do
    if check_service_status "$service"; then
        log "✓ $service 運行正常"
    else
        log "✗ $service 需要檢查"
    fi
done

# 顯示安裝摘要
log "=== 安裝摘要 ==="
log "Tell_Me 目錄: $TELL_ME_HOME"
log "日誌目錄: $TELL_ME_LOGS"
log "登入通知: $TELL_ME_LOGIN"
log "開機通知: $TELL_ME_BOOT"
log "配置檔案: $SCRIPT_DIR/Tell_Me/config/config.sh"

log "Tell_Me 服務套件安裝完成！"
log ""
log "=== 使用說明 ==="
log "管理工具位置: $TELL_ME_HOME/manage_tell_me.sh"
log "執行管理工具: $TELL_ME_HOME/manage_tell_me.sh"
log ""
log "您可以查看日誌檔案來監控服務狀態："
log "  - 登入通知: $TELL_ME_LOGS/notify.log"
log "  - 開機後通知: $TELL_ME_LOGS/notify.log"
log "  - 安裝日誌: $TELL_ME_LOGS/install.log"
log ""
log "注意: 安裝完成後可以安全刪除 Linux-Setup 資料夾"
log "所有必要的檔案都已複製到 $TELL_ME_HOME/"
