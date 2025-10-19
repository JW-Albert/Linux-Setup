#!/bin/bash

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/config.sh"

# Set error handling
set -e

# Create log directory
mkdir -p "$TELL_ME_LOGS"
LOG_FILE="$TELL_ME_LOGS/login_notify_install.log"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting login notification service installation"

# Install curl
log "Installing curl..."
sudo apt update
sudo apt install -y curl

# Create directory structure
log "Creating directory structure..."
sudo mkdir -p "$TELL_ME_LOGIN"
sudo mkdir -p "$TELL_ME_LOGS"
sudo mkdir -p "$TELL_ME_CONFIG"

# Copy scripts to target directory
log "Copying scripts to target directory..."
sudo cp "$SCRIPT_DIR/notify.sh" "$TELL_ME_LOGIN/"
sudo cp "$SCRIPT_DIR/setup.sh" "$TELL_ME_LOGIN/"
sudo cp "$SCRIPT_DIR/../config/config.sh" "$TELL_ME_CONFIG/"

# Set script permissions
log "Setting script permissions..."
sudo chmod +x "$TELL_ME_LOGIN/notify.sh"
sudo chmod +x "$TELL_ME_LOGIN/setup.sh"

# Install systemd service
log "Installing systemd service..."
# Copy service file and replace path
sed "s|ExecStart=.*|ExecStart=$TELL_ME_LOGIN/setup.sh|" "$SCRIPT_DIR/login-notify.service" | sudo tee /etc/systemd/system/login-notify.service > /dev/null
log "Service file installed: /etc/systemd/system/login-notify.service"

# Check service file content
log "Checking service file content:"
sudo cat /etc/systemd/system/login-notify.service | tee -a "$LOG_FILE"

# Enable and start service
log "Enabling and starting service..."
sudo systemctl daemon-reload
sudo systemctl enable login-notify.service
sudo systemctl start login-notify.service

# Check service status
if systemctl is-active --quiet login-notify.service; then
    log "Login notification service started successfully"
else
    log "Login notification service failed to start"
    exit 1
fi

log "Login notification service installation completed"
log "Script location: $TELL_ME_LOGIN/"
log "Log location: $TELL_ME_LOGS/"
