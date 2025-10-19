#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set basic variables (before loading configuration)
TELL_ME_LOGS="/var/log/tell_me"

# Create log directory
sudo mkdir -p "$TELL_ME_LOGS"
LOG_FILE="$TELL_ME_LOGS/notify.log"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting boot notification script execution"

# Check if configuration file exists
CONFIG_FILE="/etc/tell_me/config/config.sh"
if [ ! -f "$CONFIG_FILE" ]; then
    log "Error: Configuration file $CONFIG_FILE not found"
    exit 1
fi

# Load configuration
source "$CONFIG_FILE"
log "Configuration file loaded successfully"

# Get system information
HOSTNAME=$(hostname)
IP_ADDRESS=$(hostname -I | awk '{print $1}')
DATE=$(date '+%Y-%m-%d %H:%M:%S')

log "System info - Hostname: $HOSTNAME, IP: $IP_ADDRESS"

log "Preparing to send boot notification to Discord"

# Create Discord message
# Use free -h information directly, clearer and easier to understand
MEMORY_INFO=$(free -h | awk 'NR==2{print "Used: " $3 " / Total: " $2 " (Available: " $7 ")"}')
SWAP_INFO=$(free -h | awk 'NR==3{print "Used: " $3 " / Total: " $2}' | sed 's/Used: 0B \/ Total: /Not used /')
log "Memory info: $MEMORY_INFO"
log "Swap info: $SWAP_INFO"

DISCORD_MESSAGE="🚀 **System Boot Notification**\n\n📊 **System Information**\n\`\`\`\nHostname: $HOSTNAME\nIP Address: $IP_ADDRESS\nBoot Time: $DATE\nUptime: $(uptime -p)\n\`\`\`\n\n📈 **System Status**\n\`\`\`\nLoad Average: $(uptime | awk -F'load average:' '{print $2}')\nDisk Usage: $(df -h / | awk 'NR==2 {print $5}')\nMemory: $MEMORY_INFO\nSwap: $SWAP_INFO\n\`\`\`"

# Send Discord notification
log "Starting to send Discord notification..."
log "Webhook URL: $DISCORD_WEBHOOK_URL"

curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"username\":\"$DISCORD_USERNAME\",\"avatar_url\":\"$DISCORD_AVATAR_URL\",\"content\":\"$DISCORD_MESSAGE\"}" \
     "$DISCORD_WEBHOOK_URL" 2>&1 | tee -a "$LOG_FILE"

# Check if Discord notification was sent successfully
if [ $? -eq 0 ]; then
    log "Boot notification Discord sent successfully"
    exit 0
else
    log "Boot notification Discord failed to send"
    exit 1
fi