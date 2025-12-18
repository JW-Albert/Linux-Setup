#!/bin/bash

# Tell_Me unified installation script
# This script installs all Tell_Me related services

# Set error handling
set -e

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/Tell_Me/config/config.sh"

# Create directory structure
create_tell_me_structure

log "Starting Tell_Me service package installation"

# Check dependencies
log "Checking system dependencies..."
if ! check_dependencies; then
    log "Installing missing dependencies..."
    sudo apt update
    sudo apt install -y curl
fi

# Install login notification service
log "Installing login notification service..."
if [ -f "$SCRIPT_DIR/Tell_Me/login/install.sh" ]; then
    bash "$SCRIPT_DIR/Tell_Me/login/install.sh"
    log "Login notification service installation completed"
else
    log "Warning: Tell_Me/login/install.sh not found"
fi

# Install boot notification service
log "Installing boot notification service..."
if [ -f "$SCRIPT_DIR/Tell_Me/boot/install.sh" ]; then
    cd "$SCRIPT_DIR/Tell_Me/boot"
    bash install.sh
    log "Boot notification service installation completed"
else
    log "Warning: Tell_Me/boot/install.sh not found"
fi

# Copy management tool to management directory
log "Copying management tool..."
if [ -f "$SCRIPT_DIR/Tell_Me/manage_tell_me.sh" ]; then
    cp "$SCRIPT_DIR/Tell_Me/manage_tell_me.sh" "$TELL_ME_MANAGE/"
    chmod +x "$TELL_ME_MANAGE/manage_tell_me.sh"
    log "Management tool copied to: $TELL_ME_MANAGE/manage_tell_me.sh"
else
    log "Warning: Management tool $SCRIPT_DIR/Tell_Me/manage_tell_me.sh not found"
fi

# Copy registration script to management directory
log "Copying registration script..."
if [ -f "$SCRIPT_DIR/Tell_Me/register.sh" ]; then
    cp "$SCRIPT_DIR/Tell_Me/register.sh" "$TELL_ME_MANAGE/"
    chmod +x "$TELL_ME_MANAGE/register.sh"
    log "Registration script copied to: $TELL_ME_MANAGE/register.sh"
else
    log "Warning: Registration script $SCRIPT_DIR/Tell_Me/register.sh not found"
fi

# Configure log rotation
log "Configuring log rotation..."
cat > "$TELL_ME_MANAGE/cleanup_logs.sh" << 'EOF'
#!/bin/bash
source "/etc/tell_me/config/config.sh"
cleanup_old_logs
EOF

chmod +x "$TELL_ME_MANAGE/cleanup_logs.sh"

# Create crontab task to clean old logs
(crontab -l 2>/dev/null; echo "0 2 * * * $TELL_ME_MANAGE/cleanup_logs.sh") | crontab -

# Check all service status
log "Checking service status..."
services=("login-notify.service" "boot-notify.service")
for service in "${services[@]}"; do
    if check_service_status "$service"; then
        log "✓ $service running normally"
    else
        log "✗ $service needs checking"
    fi
done

# Display installation summary
log "=== Installation Summary ==="
log "System service directory: $TELL_ME_SYSTEM"
log "Log directory: $TELL_ME_LOGS"
log "Login notification: $TELL_ME_LOGIN"
log "Boot notification: $TELL_ME_BOOT"
log "Configuration file: $TELL_ME_CONFIG/config.sh"
log "Management tool: $TELL_ME_MANAGE"

log "Tell_Me service package installation completed!"
log ""
log "=== Usage Instructions ==="
log "1. Configure Worker URL in: $TELL_ME_CONFIG/config.sh"
log "   Set TELLME_WORKER_URL to your Cloudflare Worker URL"
log ""
log "2. Register this machine with TellMe Worker:"
log "   $TELL_ME_MANAGE/register.sh"
log ""
log "3. Management tool location: $TELL_ME_MANAGE/manage_tell_me.sh"
log "   Execute management tool: $TELL_ME_MANAGE/manage_tell_me.sh"
log ""
log "You can check log files to monitor service status:"
log "  - Login notification: $TELL_ME_LOGS/login_notify.log"
log "  - Boot notification: $TELL_ME_LOGS/notify.log"
log "  - Registration: $TELL_ME_LOGS/register.log"
log ""
log "Note: Linux-Setup folder can be safely deleted after installation"
log "System service files copied to $TELL_ME_SYSTEM/"
log "Management tool copied to $TELL_ME_MANAGE/"
