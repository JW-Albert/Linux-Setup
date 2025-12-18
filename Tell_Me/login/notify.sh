#!/bin/bash

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "/etc/tell_me/config/config.sh"

# Set error handling
set -e

# Create log directory
sudo mkdir -p "$TELL_ME_LOGS"
LOG_FILE="$TELL_ME_LOGS/login_notify.log"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | sudo tee -a "$LOG_FILE"
}

log "Login notification triggered"

# Get login information
# Try multiple methods to get actual login user
USER_NAME=""
if [ -n "$PAM_USER" ]; then
    USER_NAME="$PAM_USER"
elif [ -n "$USER" ]; then
    USER_NAME="$USER"
elif [ -n "$LOGNAME" ]; then
    USER_NAME="$LOGNAME"
else
    USER_NAME=$(whoami)
fi

HOSTNAME=$(hostname)
DATE=$(date '+%Y-%m-%d %H:%M:%S')
TIMESTAMP=$(date +%s)

# Get source IP address
IP_ADDR=""
if [ -n "$SSH_CONNECTION" ]; then
    IP_ADDR=$(echo $SSH_CONNECTION | awk '{print $1}')
elif [ -n "$SSH_CLIENT" ]; then
    IP_ADDR=$(echo $SSH_CLIENT | awk '{print $1}')
else
    # Try to get from who command
    IP_ADDR=$(who am i 2>/dev/null | awk '{print $5}' | sed 's/[()]//g')
fi

# If still no IP, use local IP
if [ -z "$IP_ADDR" ] || [ "$IP_ADDR" = "localhost" ]; then
    IP_ADDR=$(hostname -I | awk '{print $1}')
fi

log "Login info - User: $USER_NAME, Host: $HOSTNAME, IP: $IP_ADDR"

# Check if Worker is configured
if [ -n "$TELLME_WORKER_URL" ] && [ -n "$TELLME_TOKEN" ]; then
    # Use Worker API
    log "Sending login notification via Worker API"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$TELLME_WORKER_URL/event" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TELLME_TOKEN" \
        -d "{
            \"event\": \"login\",
            \"hostname\": \"$HOSTNAME\",
            \"user\": \"$USER_NAME\",
            \"time\": $TIMESTAMP,
            \"ip\": \"$IP_ADDR\",
            \"message\": \"SSH login from $IP_ADDR\"
        }")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" = "200" ]; then
        log "Login notification sent successfully via Worker"
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
        
        DISCORD_MESSAGE="🔐 **Login Notification**\n\n👤 **User Information**\n\`\`\`\nUser: $USER_NAME\nHost: $HOSTNAME\nTime: $DATE\n\`\`\`\n\n🌐 **Connection Information**\n\`\`\`\nSource IP: $IP_ADDR\nTerminal: $TERM\nSession: $SSH_TTY\n\`\`\`"
        
        curl -H "Content-Type: application/json" \
             -X POST \
             -d "{\"username\":\"$DISCORD_USERNAME\",\"avatar_url\":\"$DISCORD_AVATAR_URL\",\"content\":\"$DISCORD_MESSAGE\"}" \
             "$DISCORD_WEBHOOK_URL" 2>&1 | sudo tee -a "$LOG_FILE"
        
        if [ $? -eq 0 ]; then
            log "Login notification sent via legacy Discord webhook"
        else
            log "Login notification failed to send"
            exit 1
        fi
    else
        log "Error: Neither Worker API nor Discord webhook is configured"
        exit 1
    fi
fi
