#!/bin/bash

# Tell_Me unified configuration file
# This file contains shared configuration for all Tell_Me related scripts

# Basic directory settings
TELL_ME_SYSTEM="/etc/tell_me"                    # System service file directory
TELL_ME_LOGS="/var/log/tell_me"                  # Log file directory
TELL_ME_LOGIN="$TELL_ME_SYSTEM/login"            # Login notification service directory
TELL_ME_BOOT="$TELL_ME_SYSTEM/boot"              # Boot notification service directory
TELL_ME_CONFIG="$TELL_ME_SYSTEM/config"          # Configuration file directory
TELL_ME_MANAGE="$HOME/Tell_Me"                   # Management tool directory

# Cloudflare Worker configuration
# Set this to your deployed Worker URL (e.g., https://tellme-worker.your-subdomain.workers.dev)
TELLME_WORKER_URL=""
# Client token (set after registration via register.sh)
TELLME_TOKEN=""

# Legacy Discord Webhook configuration (deprecated, kept for backward compatibility)
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1419203705751994420/UE2we0TjTDflXdHadPAM9EWZV_BPsSRxbJ4f0ooM1oP1pNBcSYS1hUQpJouWtd7pNA8E"
DISCORD_USERNAME="Tell_Me Bot"
DISCORD_AVATAR_URL="https://raw.githubusercontent.com/JW-Albert/Linux-Setup/refs/heads/main/Tell_Me/config/icon.png"

# Log configuration
LOG_RETENTION_DAYS=30

# Create directory structure function
create_tell_me_structure() {
    # Create system directories (requires root privileges)
    sudo mkdir -p "$TELL_ME_SYSTEM"
    sudo mkdir -p "$TELL_ME_LOGS"
    sudo mkdir -p "$TELL_ME_LOGIN"
    sudo mkdir -p "$TELL_ME_BOOT"
    sudo mkdir -p "$TELL_ME_CONFIG"
    
    # Create management directory
    mkdir -p "$TELL_ME_MANAGE"
    
    echo "Tell_Me directory structure has been created:"
    echo "  System service: $TELL_ME_SYSTEM"
    echo "  Log files: $TELL_ME_LOGS"
    echo "  Login service: $TELL_ME_LOGIN"
    echo "  Boot service: $TELL_ME_BOOT"
    echo "  Configuration file: $TELL_ME_CONFIG"
    echo "  Management tool: $TELL_ME_MANAGE"
}

# Log function
log() {
    local log_file="$TELL_ME_LOGS/$(basename "$0" .sh).log"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$log_file"
}

# Clean up old logs function
cleanup_old_logs() {
    find "$TELL_ME_LOGS" -name "*.log" -type f -mtime +$LOG_RETENTION_DAYS -delete
    log "Cleaned up old log files from $LOG_RETENTION_DAYS days ago"
}

# Check dependencies function
check_dependencies() {
    local deps=("curl" "systemctl")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log "Error: Missing dependency $dep"
            return 1
        fi
    done
    return 0
}

# Check service status function
check_service_status() {
    local service_name="$1"
    local status=$(systemctl is-active "$service_name")
    
    if [ "$status" = "active" ] || [ "$status" = "inactive" ]; then
        # For oneshot services, both active and inactive are normal states
        if [ "$service_name" = "boot-notify.service" ]; then
            log "Service $service_name status: $status (oneshot service normal)"
            return 0
        else
            log "Service $service_name status: $status"
            return 0
        fi
    else
        log "Service $service_name status abnormal: $status"
        return 1
    fi
}

# Export variables for other scripts to use
export TELL_ME_SYSTEM TELL_ME_LOGS TELL_ME_LOGIN TELL_ME_BOOT TELL_ME_CONFIG TELL_ME_MANAGE
export TELLME_WORKER_URL TELLME_TOKEN
export DISCORD_WEBHOOK_URL DISCORD_USERNAME DISCORD_AVATAR_URL
export LOG_RETENTION_DAYS

# Helper function: Get machine ID (fingerprint)
get_machine_id() {
    # Try to get a unique machine identifier
    if [ -f /etc/machine-id ]; then
        cat /etc/machine-id
    elif command -v hostid &> /dev/null; then
        hostid
    else
        # Fallback: use hostname + MAC address
        hostname | sha256sum | cut -d' ' -f1
    fi
}
