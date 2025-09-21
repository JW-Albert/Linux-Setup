#!/bin/bash

# Tell_Me 服務管理腳本
# 用於管理所有 Tell_Me 相關服務

# 載入配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "/etc/tell_me/config/config.sh"

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 顯示標題
show_title() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}    Tell_Me 服務管理工具${NC}"
    echo -e "${BLUE}================================${NC}"
}

# 顯示選單
show_menu() {
    echo -e "${YELLOW}請選擇操作：${NC}"
    echo "1. 檢查服務狀態"
    echo "2. 啟動所有服務"
    echo "3. 停止所有服務"
    echo "4. 重啟所有服務"
    echo "5. 查看日誌"
    echo "6. 清理舊日誌"
    echo "7. 測試 Discord 通知"
    echo "8. 顯示配置資訊"
    echo "9. 重新安裝服務"
    echo "10. 退出"
    echo ""
}

# 檢查服務狀態
check_services() {
    echo -e "${BLUE}檢查服務狀態...${NC}"
    echo ""
    
    services=("login-notify.service" "boot-notify.service")
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            echo -e "✓ ${GREEN}$service${NC} - 運行中"
        else
            echo -e "✗ ${RED}$service${NC} - 未運行"
        fi
    done
    echo ""
}

# 啟動所有服務
start_services() {
    echo -e "${BLUE}啟動所有服務...${NC}"
sudo systemctl start login-notify.service
sudo systemctl start boot-notify.service
    echo -e "${GREEN}所有服務已啟動${NC}"
    echo ""
}

# 停止所有服務
stop_services() {
    echo -e "${BLUE}停止所有服務...${NC}"
sudo systemctl stop login-notify.service
sudo systemctl stop boot-notify.service
    echo -e "${YELLOW}所有服務已停止${NC}"
    echo ""
}

# 重啟所有服務
restart_services() {
    echo -e "${BLUE}重啟所有服務...${NC}"
sudo systemctl restart login-notify.service
sudo systemctl restart boot-notify.service
    echo -e "${GREEN}所有服務已重啟${NC}"
    echo ""
}

# 查看日誌
view_logs() {
    echo -e "${BLUE}可用的日誌檔案：${NC}"
    echo "1. 登入通知日誌"
    echo "2. 開機後通知日誌"
    echo "3. 登入通知設定日誌"
    echo "4. 所有日誌"
    echo ""
    read -p "請選擇 (1-4): " choice
    
    case $choice in
        1)
            if [ -f "$TELL_ME_LOGS/login_notify.log" ]; then
                tail -f "$TELL_ME_LOGS/login_notify.log"
            else
                echo -e "${RED}日誌檔案不存在${NC}"
            fi
            ;;
        2)
            if [ -f "$TELL_ME_LOGS/notify.log" ]; then
                tail -f "$TELL_ME_LOGS/notify.log"
            else
                echo -e "${RED}日誌檔案不存在${NC}"
            fi
            ;;
        3)
            if [ -f "$TELL_ME_LOGS/setup_login_notify.log" ]; then
                tail -f "$TELL_ME_LOGS/setup_login_notify.log"
            else
                echo -e "${RED}日誌檔案不存在${NC}"
            fi
            ;;
        4)
            echo -e "${BLUE}所有日誌檔案：${NC}"
            ls -la "$TELL_ME_LOGS/"
            ;;
        *)
            echo -e "${RED}無效選擇${NC}"
            ;;
    esac
    echo ""
}

# 清理舊日誌
cleanup_logs() {
    echo -e "${BLUE}清理舊日誌...${NC}"
    cleanup_old_logs
    echo -e "${GREEN}日誌清理完成${NC}"
    echo ""
}

# 測試 Discord 通知
test_discord() {
    echo -e "${BLUE}測試 Discord 通知...${NC}"
    
    if [ -z "$DISCORD_WEBHOOK_URL" ]; then
        echo -e "${RED}錯誤: Discord Webhook URL 未設定${NC}"
        echo "請檢查 config.sh 中的 Discord 設定"
        return 1
    fi
    
    echo "發送測試通知到 Discord..."
    
    TEST_MESSAGE="🧪 **Tell_Me 測試通知**\n\n**測試時間**: $(date '+%Y-%m-%d %H:%M:%S')\n**主機名**: $(hostname)\n**IP 地址**: $(hostname -I | awk '{print $1}')\n\n如果您看到這則訊息，表示 Tell_Me Discord 通知功能運作正常！ 🎉"
    
    curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"username\":\"$DISCORD_USERNAME\",\"avatar_url\":\"$DISCORD_AVATAR_URL\",\"content\":\"$TEST_MESSAGE\"}" \
         "$DISCORD_WEBHOOK_URL"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}測試 Discord 通知發送成功！${NC}"
    else
        echo -e "${RED}測試 Discord 通知發送失敗${NC}"
    fi
    echo ""
}

# 重新安裝服務
reinstall_services() {
    echo -e "${BLUE}重新安裝服務...${NC}"
    echo "1. 重新安裝登入通知服務"
    echo "2. 重新安裝開機後 IP 通知服務"
    echo "3. 重新安裝所有服務"
    echo ""
    read -p "請選擇 (1-3): " choice
    
    case $choice in
        1)
            echo -e "${BLUE}重新安裝登入通知服務...${NC}"
            if [ -f "$SCRIPT_DIR/Tell_Me/login/install.sh" ]; then
                bash "$SCRIPT_DIR/Tell_Me/login/install.sh"
                echo -e "${GREEN}登入通知服務重新安裝完成${NC}"
            else
                echo -e "${RED}找不到登入通知安裝腳本${NC}"
            fi
            ;;
        2)
            echo -e "${BLUE}重新安裝開機後通知服務...${NC}"
            if [ -f "$SCRIPT_DIR/Tell_Me/boot/install.sh" ]; then
                cd "$SCRIPT_DIR/Tell_Me/boot"
                bash install.sh
                echo -e "${GREEN}開機後通知服務重新安裝完成${NC}"
            else
                echo -e "${RED}找不到開機後通知安裝腳本${NC}"
            fi
            ;;
        3)
            echo -e "${BLUE}重新安裝所有服務...${NC}"
            if [ -f "$SCRIPT_DIR/install_tell_me.sh" ]; then
                bash "$SCRIPT_DIR/install_tell_me.sh"
                echo -e "${GREEN}所有服務重新安裝完成${NC}"
            else
                echo -e "${RED}找不到統一安裝腳本${NC}"
            fi
            ;;
        *)
            echo -e "${RED}無效選擇${NC}"
            ;;
    esac
    echo ""
}

# 顯示配置資訊
show_config() {
    echo -e "${BLUE}Tell_Me 配置資訊：${NC}"
    echo "系統服務目錄: $TELL_ME_SYSTEM"
    echo "日誌目錄: $TELL_ME_LOGS"
    echo "登入通知: $TELL_ME_LOGIN"
    echo "開機通知: $TELL_ME_BOOT"
    echo "管理工具: $TELL_ME_MANAGE"
    echo "Discord 機器人: $DISCORD_USERNAME"
    echo "Discord Webhook: ${DISCORD_WEBHOOK_URL:0:50}..."
    echo "日誌保留天數: $LOG_RETENTION_DAYS"
    echo ""
}

# 主程式
main() {
    while true; do
        show_title
        show_menu
        read -p "請輸入選項 (1-10): " choice
        echo ""
        
        case $choice in
            1) check_services ;;
            2) start_services ;;
            3) stop_services ;;
            4) restart_services ;;
            5) view_logs ;;
            6) cleanup_logs ;;
            7) test_discord ;;
            8) show_config ;;
            9) reinstall_services ;;
            10) 
                echo -e "${GREEN}再見！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}無效選項，請重新選擇${NC}"
                ;;
        esac
        
        echo ""
        read -p "按 Enter 鍵繼續..."
        clear
    done
}

# 執行主程式
main
