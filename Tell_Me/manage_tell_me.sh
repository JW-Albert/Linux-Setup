#!/bin/bash

# Tell_Me service management script
# Used to manage all Tell_Me related services

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "/etc/tell_me/config/config.sh"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display title
show_title() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}    Tell_Me Service Management Tool${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Display menu
show_menu() {
    echo -e "${YELLOW}Please select an operation:${NC}"
    echo "1. Check service status"
    echo "2. Start all services"
    echo "3. Stop all services"
    echo "4. Restart all services"
    echo "5. View logs"
    echo "6. Clean up old logs"
    echo "7. Test Discord notification"
    echo "8. Show configuration info"
    echo "9. Reinstall services"
    echo "10. Exit"
    echo ""
}

# Check service status
check_services() {
    echo -e "${BLUE}Checking service status...${NC}"
    echo ""
    
    services=("login-notify.service" "boot-notify.service")
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            echo -e "✓ ${GREEN}$service${NC} - Running"
        else
            echo -e "✗ ${RED}$service${NC} - Not running"
        fi
    done
    echo ""
}

# Start all services
start_services() {
    echo -e "${BLUE}Starting all services...${NC}"
sudo systemctl start login-notify.service
sudo systemctl start boot-notify.service
    echo -e "${GREEN}All services have been started${NC}"
    echo ""
}

# Stop all services
stop_services() {
    echo -e "${BLUE}Stopping all services...${NC}"
sudo systemctl stop login-notify.service
sudo systemctl stop boot-notify.service
    echo -e "${YELLOW}All services have been stopped${NC}"
    echo ""
}

# Restart all services
restart_services() {
    echo -e "${BLUE}Restarting all services...${NC}"
sudo systemctl restart login-notify.service
sudo systemctl restart boot-notify.service
    echo -e "${GREEN}All services have been restarted${NC}"
    echo ""
}

# View logs
view_logs() {
    echo -e "${BLUE}Available log files:${NC}"
    echo "1. Login notification log"
    echo "2. Boot notification log"
    echo "3. Login notification setup log"
    echo "4. All logs"
    echo ""
    read -p "Please select (1-4): " choice
    
    case $choice in
        1)
            if [ -f "$TELL_ME_LOGS/login_notify.log" ]; then
                tail -f "$TELL_ME_LOGS/login_notify.log"
            else
                echo -e "${RED}Log file does not exist${NC}"
            fi
            ;;
        2)
            if [ -f "$TELL_ME_LOGS/notify.log" ]; then
                tail -f "$TELL_ME_LOGS/notify.log"
            else
                echo -e "${RED}Log file does not exist${NC}"
            fi
            ;;
        3)
            if [ -f "$TELL_ME_LOGS/setup_login_notify.log" ]; then
                tail -f "$TELL_ME_LOGS/setup_login_notify.log"
            else
                echo -e "${RED}Log file does not exist${NC}"
            fi
            ;;
        4)
            echo -e "${BLUE}All log files:${NC}"
            ls -la "$TELL_ME_LOGS/"
            ;;
        *)
            echo -e "${RED}Invalid selection${NC}"
            ;;
    esac
    echo ""
}

# Clean up old logs
cleanup_logs() {
    echo -e "${BLUE}Cleaning up old logs...${NC}"
    cleanup_old_logs
    echo -e "${GREEN}Log cleanup completed${NC}"
    echo ""
}

# Test Discord notification
test_discord() {
    echo -e "${BLUE}Testing Discord notification...${NC}"
    
    if [ -z "$DISCORD_WEBHOOK_URL" ]; then
        echo -e "${RED}Error: Discord Webhook URL not set${NC}"
        echo "Please check Discord settings in config.sh"
        return 1
    fi
    
    echo "Sending test notification to Discord..."
    
    TEST_MESSAGE="🧪 **Tell_Me Test Notification**\n\n**Test Time**: $(date '+%Y-%m-%d %H:%M:%S')\n**Hostname**: $(hostname)\n**IP Address**: $(hostname -I | awk '{print $1}')\n\nIf you see this message, the Tell_Me Discord notification feature is working properly! 🎉"
    
    curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"username\":\"$DISCORD_USERNAME\",\"avatar_url\":\"$DISCORD_AVATAR_URL\",\"content\":\"$TEST_MESSAGE\"}" \
         "$DISCORD_WEBHOOK_URL"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Discord test notification sent successfully!${NC}"
    else
        echo -e "${RED}Discord test notification failed to send${NC}"
    fi
    echo ""
}

# Reinstall services
reinstall_services() {
    echo -e "${BLUE}Reinstalling services...${NC}"
    echo "1. Reinstall login notification service"
    echo "2. Reinstall boot IP notification service"
    echo "3. Reinstall all services"
    echo ""
    read -p "Please select (1-3): " choice
    
    case $choice in
        1)
            echo -e "${BLUE}Reinstalling login notification service...${NC}"
            if [ -f "$SCRIPT_DIR/Tell_Me/login/install.sh" ]; then
                bash "$SCRIPT_DIR/Tell_Me/login/install.sh"
                echo -e "${GREEN}Login notification service reinstalled${NC}"
            else
                echo -e "${RED}Login notification install script not found${NC}"
            fi
            ;;
        2)
            echo -e "${BLUE}Reinstalling boot notification service...${NC}"
            if [ -f "$SCRIPT_DIR/Tell_Me/boot/install.sh" ]; then
                cd "$SCRIPT_DIR/Tell_Me/boot"
                bash install.sh
                echo -e "${GREEN}Boot notification service reinstalled${NC}"
            else
                echo -e "${RED}Boot notification install script not found${NC}"
            fi
            ;;
        3)
            echo -e "${BLUE}Reinstalling all services...${NC}"
            if [ -f "$SCRIPT_DIR/install_tell_me.sh" ]; then
                bash "$SCRIPT_DIR/install_tell_me.sh"
                echo -e "${GREEN}All services reinstalled${NC}"
            else
                echo -e "${RED}Unified install script not found${NC}"
            fi
            ;;
        *)
            echo -e "${RED}Invalid selection${NC}"
            ;;
    esac
    echo ""
}

# Display configuration info
show_config() {
    echo -e "${BLUE}Tell_Me Configuration Info:${NC}"
    echo "System service directory: $TELL_ME_SYSTEM"
    echo "Log directory: $TELL_ME_LOGS"
    echo "Login notification: $TELL_ME_LOGIN"
    echo "Boot notification: $TELL_ME_BOOT"
    echo "Management tool: $TELL_ME_MANAGE"
    echo "Discord bot: $DISCORD_USERNAME"
    echo "Discord Webhook: ${DISCORD_WEBHOOK_URL:0:50}..."
    echo "Log retention days: $LOG_RETENTION_DAYS"
    echo ""
}

# Main program
main() {
    while true; do
        show_title
        show_menu
        read -p "Please enter option (1-10): " choice
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
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option, please select again${NC}"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
}

# Execute main program
main
