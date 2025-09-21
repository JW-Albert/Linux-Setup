#!/bin/bash

# Tell_Me 統一配置檔案
# 此檔案包含所有 Tell_Me 相關腳本的共用配置

# 基本目錄設定
TELL_ME_SYSTEM="/etc/tell_me"                    # 系統服務檔案目錄
TELL_ME_LOGS="/var/log/tell_me"                  # 日誌檔案目錄
TELL_ME_LOGIN="$TELL_ME_SYSTEM/login"            # 登入通知服務目錄
TELL_ME_BOOT="$TELL_ME_SYSTEM/boot"              # 開機通知服務目錄
TELL_ME_CONFIG="$TELL_ME_SYSTEM/config"          # 配置檔案目錄
TELL_ME_MANAGE="$HOME/Tell_Me"                   # 管理工具目錄

# Discord Webhook 配置
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1419203705751994420/UE2we0TjTDflXdHadPAM9EWZV_BPsSRxbJ4f0ooM1oP1pNBcSYS1hUQpJouWtd7pNA8E"
DISCORD_USERNAME="Tell_Me Bot"
# 自訂頭像 URL - 可以設定為任何有效的圖片 URL
# 範例：
# DISCORD_AVATAR_URL="https://example.com/your-custom-avatar.png"
# DISCORD_AVATAR_URL="https://raw.githubusercontent.com/username/repo/main/avatar.png"
# DISCORD_AVATAR_URL="https://i.imgur.com/your-image-id.png"
DISCORD_AVATAR_URL="https://cdn.discordapp.com/embed/avatars/0.png"

# 日誌配置
LOG_RETENTION_DAYS=30

# 建立目錄結構函數
create_tell_me_structure() {
    # 建立系統目錄（需要 root 權限）
    sudo mkdir -p "$TELL_ME_SYSTEM"
    sudo mkdir -p "$TELL_ME_LOGS"
    sudo mkdir -p "$TELL_ME_LOGIN"
    sudo mkdir -p "$TELL_ME_BOOT"
    sudo mkdir -p "$TELL_ME_CONFIG"
    
    # 建立管理目錄
    mkdir -p "$TELL_ME_MANAGE"
    
    echo "Tell_Me 目錄結構已建立:"
    echo "  系統服務: $TELL_ME_SYSTEM"
    echo "  日誌檔案: $TELL_ME_LOGS"
    echo "  登入服務: $TELL_ME_LOGIN"
    echo "  開機服務: $TELL_ME_BOOT"
    echo "  配置檔案: $TELL_ME_CONFIG"
    echo "  管理工具: $TELL_ME_MANAGE"
}

# 日誌函數
log() {
    local log_file="$TELL_ME_LOGS/$(basename "$0" .sh).log"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$log_file"
}

# 清理舊日誌函數
cleanup_old_logs() {
    find "$TELL_ME_LOGS" -name "*.log" -type f -mtime +$LOG_RETENTION_DAYS -delete
    log "已清理 $LOG_RETENTION_DAYS 天前的舊日誌檔案"
}

# 檢查依賴函數
check_dependencies() {
    local deps=("curl" "systemctl")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log "錯誤: 缺少依賴 $dep"
            return 1
        fi
    done
    return 0
}

# 檢查服務狀態函數
check_service_status() {
    local service_name="$1"
    local status=$(systemctl is-active "$service_name")
    
    if [ "$status" = "active" ] || [ "$status" = "inactive" ]; then
        # 對於 oneshot 服務，active 或 inactive 都是正常狀態
        if [ "$service_name" = "boot-notify.service" ]; then
            log "服務 $service_name 狀態: $status (oneshot 服務正常)"
            return 0
        else
            log "服務 $service_name 狀態: $status"
            return 0
        fi
    else
        log "服務 $service_name 狀態異常: $status"
        return 1
    fi
}

# 匯出變數供其他腳本使用
export TELL_ME_SYSTEM TELL_ME_LOGS TELL_ME_LOGIN TELL_ME_BOOT TELL_ME_CONFIG TELL_ME_MANAGE
export DISCORD_WEBHOOK_URL DISCORD_USERNAME DISCORD_AVATAR_URL
export LOG_RETENTION_DAYS
