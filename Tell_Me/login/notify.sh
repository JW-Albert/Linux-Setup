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
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Login notification triggered"

# Email configuration (using unified configuration)
SMTP_SERVER="$SMTP_SERVER"
SMTP_PORT="$SMTP_PORT"
SENDER_EMAIL="$SENDER_EMAIL"
SENDER_PASSWORD="$SENDER_PASSWORD"
RECIPIENT_EMAIL="$RECIPIENT_EMAIL"

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

# Get source IP address
IP_ADDR=""
if [ -n "$SSH_CONNECTION" ]; then
    IP_ADDR=$(echo $SSH_CONNECTION | awk '{print $1}')
elif [ -n "$SSH_CLIENT" ]; then
    IP_ADDR=$(echo $SSH_CLIENT | awk '{print $1}')
else
    # Try to get from who command
    IP_ADDR=$(who am i | awk '{print $5}' | sed 's/[()]//g')
fi

# If still no IP, use local IP
if [ -z "$IP_ADDR" ] || [ "$IP_ADDR" = "localhost" ]; then
    IP_ADDR=$(hostname -I | awk '{print $1}')
fi

# Debug information
log "Environment variable debug:"
log "  PAM_USER: $PAM_USER"
log "  USER: $USER"
log "  LOGNAME: $LOGNAME"
log "  SSH_CONNECTION: $SSH_CONNECTION"
log "  SSH_CLIENT: $SSH_CLIENT"
log "  TERM: $TERM"
log "  SSH_TTY: $SSH_TTY"

log "Login info - User: $USER_NAME, Host: $HOSTNAME, IP: $IP_ADDR"

# Create Discord notification content

log "Preparing to send login notification to Discord"

# Create Discord message
DISCORD_MESSAGE="🔐 **Login Notification**\n\n👤 **User Information**\n\`\`\`\nUser: $USER_NAME\nHost: $HOSTNAME\nTime: $DATE\n\`\`\`\n\n🌐 **Connection Information**\n\`\`\`\nSource IP: $IP_ADDR\nTerminal: $TERM\nSession: $SSH_TTY\n\`\`\`"

# Send Discord notification
log "Starting to send Discord notification..."
log "Webhook URL: $DISCORD_WEBHOOK_URL"

curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"username\":\"$DISCORD_USERNAME\",\"avatar_url\":\"$DISCORD_AVATAR_URL\",\"content\":\"$DISCORD_MESSAGE\"}" \
     "$DISCORD_WEBHOOK_URL" 2>&1 | tee -a "$LOG_FILE"

# Check Discord notification sending result
if [ $? -eq 0 ]; then
    log "Login notification Discord sent successfully"
else
    log "Login notification Discord failed to send"
    exit 1
fi
