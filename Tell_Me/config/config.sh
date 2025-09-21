#!/bin/bash

# Tell_Me 統一配置檔案
# 此檔案包含所有 Tell_Me 相關腳本的共用配置

# 基本目錄設定
TELL_ME_HOME="$HOME/Tell_Me"
TELL_ME_LOGS="$TELL_ME_HOME/logs"
TELL_ME_LOGIN="$TELL_ME_HOME/login"
TELL_ME_BOOT="$TELL_ME_HOME/boot"

# Discord Webhook 配置
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1419203705751994420/UE2we0TjTDflXdHadPAM9EWZV_BPsSRxbJ4f0ooM1oP1pNBcSYS1hUQpJouWtd7pNA8E"
DISCORD_USERNAME="Tell_Me Bot"
DISCORD_AVATAR_URL="https://cdn.discordapp.com/embed/avatars/0.png"

# 日誌配置
LOG_RETENTION_DAYS=30

# 建立目錄結構函數
create_tell_me_structure() {
    mkdir -p "$TELL_ME_HOME"
    mkdir -p "$TELL_ME_LOGS"
    mkdir -p "$TELL_ME_LOGIN"
    mkdir -p "$TELL_ME_BOOT"
    
    echo "Tell_Me 目錄結構已建立:"
    echo "  - $TELL_ME_HOME"
    echo "  - $TELL_ME_LOGS"
    echo "  - $TELL_ME_LOGIN"
    echo "  - $TELL_ME_BOOT"
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
    if systemctl is-active --quiet "$service_name"; then
        log "服務 $service_name 正在運行"
        return 0
    else
        log "服務 $service_name 未運行"
        return 1
    fi
}

# 匯出變數供其他腳本使用
export TELL_ME_HOME TELL_ME_LOGS TELL_ME_LOGIN TELL_ME_BOOT
export DISCORD_WEBHOOK_URL DISCORD_USERNAME DISCORD_AVATAR_URL
export LOG_RETENTION_DAYS
