#!/bin/bash

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/config.sh"

# Set error handling
set -e

# Create log directory
mkdir -p "$TELL_ME_LOGS"
LOG_FILE="$TELL_ME_LOGS/install.log"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting boot IP notification service setup"

# Install curl
log "Installing curl..."
sudo apt update
sudo apt install -y curl

# Create target directory
log "Creating directory structure..."
sudo mkdir -p "$TELL_ME_BOOT"
sudo mkdir -p "$TELL_ME_LOGS"
sudo mkdir -p "$TELL_ME_CONFIG"

# Set script permissions and move
log "Setting script permissions..."
chmod +x notify.sh

log "Moving files to target directory..."
sudo mv notify.sh "$TELL_ME_BOOT/"
sudo cp "$SCRIPT_DIR/../config/config.sh" "$TELL_ME_CONFIG/"

# Install systemd service
log "Installing systemd service..."
# Copy service file and replace path
sed "s|ExecStart=.*|ExecStart=$TELL_ME_BOOT/notify.sh|" "$SCRIPT_DIR/boot-notify.service" | sudo tee /etc/systemd/system/boot-notify.service > /dev/null

# Enable and start service
log "Enabling and starting service..."
sudo systemctl daemon-reload
sudo systemctl enable boot-notify.service
sudo systemctl start boot-notify.service

# Check service status
if systemctl is-active --quiet boot-notify.service; then
    log "Service started successfully"
else
    log "Service failed to start"
    exit 1
fi

log "Boot notification service setup completed"
