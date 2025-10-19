#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set basic variables (before loading configuration)
TELL_ME_LOGS="/var/log/tell_me"

# Create log directory
sudo mkdir -p "$TELL_ME_LOGS"
LOG_FILE="$TELL_ME_LOGS/setup_login_notify.log"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting login notification setup"

# Check if configuration file exists
CONFIG_FILE="/etc/tell_me/config/config.sh"
if [ ! -f "$CONFIG_FILE" ]; then
    log "Error: Configuration file $CONFIG_FILE not found"
    exit 1
fi

# Load configuration
source "$CONFIG_FILE"
log "Configuration file loaded successfully"

# Check if variables are correctly set
log "TELL_ME_SYSTEM: $TELL_ME_SYSTEM"
log "TELL_ME_LOGIN: $TELL_ME_LOGIN"

SCRIPT_PATH="$TELL_ME_LOGIN/notify.sh"
PAM_FILE="/etc/pam.d/sshd"

log "Checking script path: $SCRIPT_PATH"

# Ensure script exists
if [ ! -f "$SCRIPT_PATH" ]; then
    log "Error: Login notification script $SCRIPT_PATH not found"
    log "Checking directory contents:"
    ls -la "$TELL_ME_LOGIN/" | tee -a "$LOG_FILE"
    exit 1
fi

log "Script file exists, checking permissions"

# Ensure script has execution permission
chmod +x "$SCRIPT_PATH"
log "Login notification script execution permission set"

# Check if PAM file exists
if [ ! -f "$PAM_FILE" ]; then
    log "Error: PAM file $PAM_FILE not found"
    exit 1
fi

log "Checking PAM configuration"

# Ensure PAM has this line, add if not present
if ! grep -q "$SCRIPT_PATH" "$PAM_FILE"; then
    echo "session optional pam_exec.so $SCRIPT_PATH" >> "$PAM_FILE"
    log "PAM sshd has added notify.sh configuration"
else
    log "PAM sshd already has notify.sh configuration"
fi

log "Login notification setup completed"
