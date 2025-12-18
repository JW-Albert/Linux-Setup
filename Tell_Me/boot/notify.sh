#!/bin/bash

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "/etc/tell_me/config/config.sh"

# Set error handling
set -e

# Create log directory
sudo mkdir -p "$TELL_ME_LOGS"
LOG_FILE="$TELL_ME_LOGS/notify.log"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | sudo tee -a "$LOG_FILE"
}

log "Boot notification triggered"

# Get system information
HOSTNAME=$(hostname)
USER="system"
TIMESTAMP=$(date +%s)
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Get IP address
IP_ADDR=$(hostname -I | awk '{print $1}')

# Get system uptime
UPTIME=$(uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')

# Get system load
LOAD=$(uptime | awk -F'load average:' '{print $2}')

# Get disk usage
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')

# Get memory usage
MEMORY_USAGE=$(free -m | awk 'NR==2{printf "%.1f%%", $3*100/$2}')

log "System info - Host: $HOSTNAME, IP: $IP_ADDR, Uptime: $UPTIME"

# Check if Worker is configured
if [ -n "$TELLME_WORKER_URL" ] && [ -n "$TELLME_TOKEN" ]; then
    # Use Worker API
    log "Sending boot notification via Worker API"
    
    MESSAGE="System booted. Uptime: $UPTIME, Load: $LOAD, Disk: $DISK_USAGE, Memory: $MEMORY_USAGE"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$TELLME_WORKER_URL/event" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TELLME_TOKEN" \
        -d "{
            \"event\": \"boot\",
            \"hostname\": \"$HOSTNAME\",
            \"user\": \"$USER\",
            \"time\": $TIMESTAMP,
            \"ip\": \"$IP_ADDR\",
            \"message\": \"$MESSAGE\"
        }")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" = "200" ]; then
        log "Boot notification sent successfully via Worker"
    else
        log "Error: Failed to send notification via Worker (HTTP $HTTP_CODE)"
        log "Response: $BODY"
        exit 1
    fi
else
    # Fallback to legacy Discord webhook (if configured)
    if [ -n "$DISCORD_WEBHOOK_URL" ]; then
        log "Warning: Worker not configured, using legacy Discord webhook"
        log "Please run register.sh to set up Worker API"
        
        DISCORD_MESSAGE="🚀 **Boot Notification**\n\n🖥️ **System Information**\n\`\`\`\nHostname: $HOSTNAME\nIP: $IP_ADDR\nTime: $DATE\nUptime: $UPTIME\n\`\`\`\n\n📊 **System Status**\n\`\`\`\nLoad: $LOAD\nDisk Usage: $DISK_USAGE\nMemory Usage: $MEMORY_USAGE\n\`\`\`"
        
        curl -H "Content-Type: application/json" \
             -X POST \
             -d "{\"username\":\"$DISCORD_USERNAME\",\"avatar_url\":\"$DISCORD_AVATAR_URL\",\"content\":\"$DISCORD_MESSAGE\"}" \
             "$DISCORD_WEBHOOK_URL" 2>&1 | sudo tee -a "$LOG_FILE"
        
        if [ $? -eq 0 ]; then
            log "Boot notification sent via legacy Discord webhook"
        else
            log "Boot notification failed to send"
            exit 1
        fi
    else
        log "Error: Neither Worker API nor Discord webhook is configured"
        exit 1
    fi
fi

