#!/bin/bash

# TellMe Registration Script
# This script registers a new machine with the TellMe Worker

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config/config.sh"

# Set error handling
set -e

# Create log directory
mkdir -p "$TELL_ME_LOGS"
LOG_FILE="$TELL_ME_LOGS/register.log"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting TellMe registration process"

# Check if Worker URL is configured
if [ -z "$TELLME_WORKER_URL" ]; then
    log "Error: TELLME_WORKER_URL is not set in config.sh"
    echo ""
    echo "Please set TELLME_WORKER_URL in $TELL_ME_CONFIG/config.sh"
    echo "Example: TELLME_WORKER_URL=\"https://tellme-worker.your-subdomain.workers.dev\""
    exit 1
fi

# Get machine information
HOSTNAME=$(hostname)
USER=$(whoami)
MACHINE_ID=$(get_machine_id)

log "Machine information:"
log "  Hostname: $HOSTNAME"
log "  User: $USER"
log "  Machine ID: $MACHINE_ID"

# Step 1: Request registration
log "Requesting registration from Worker..."
REGISTER_RESPONSE=$(curl -s -X POST "$TELLME_WORKER_URL/register/request" \
    -H "Content-Type: application/json" \
    -d "{
        \"hostname\": \"$HOSTNAME\",
        \"user\": \"$USER\",
        \"machine_id\": \"$MACHINE_ID\"
    }")

if [ $? -ne 0 ]; then
    log "Error: Failed to connect to Worker"
    exit 1
fi

# Parse registration ID
REGISTRATION_ID=$(echo "$REGISTER_RESPONSE" | grep -o '"registration_id":"[^"]*"' | cut -d'"' -f4)

if [ -z "$REGISTRATION_ID" ]; then
    log "Error: Failed to get registration_id"
    log "Response: $REGISTER_RESPONSE"
    exit 1
fi

log "Registration request successful"
log "Registration ID: $REGISTRATION_ID"
log "OTP has been sent to your email"

# Step 2: Prompt for OTP
echo ""
echo "Please check your email for the OTP code."
read -p "Enter OTP code: " OTP

if [ -z "$OTP" ]; then
    log "Error: OTP code is required"
    exit 1
fi

# Step 3: Confirm registration
log "Confirming registration with OTP..."
CONFIRM_RESPONSE=$(curl -s -X POST "$TELLME_WORKER_URL/register/confirm" \
    -H "Content-Type: application/json" \
    -d "{
        \"registration_id\": \"$REGISTRATION_ID\",
        \"otp\": \"$OTP\"
    }")

if [ $? -ne 0 ]; then
    log "Error: Failed to connect to Worker"
    exit 1
fi

# Parse token
TOKEN=$(echo "$CONFIRM_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    log "Error: Failed to get token"
    log "Response: $CONFIRM_RESPONSE"
    exit 1
fi

log "Registration confirmed successfully"
log "Token received: ${TOKEN:0:20}..."

# Save token to config file
CONFIG_FILE="$TELL_ME_CONFIG/config.sh"
if [ -f "$CONFIG_FILE" ]; then
    # Update token in config file
    if grep -q "^TELLME_TOKEN=" "$CONFIG_FILE"; then
        # Replace existing token
        sed -i "s|^TELLME_TOKEN=.*|TELLME_TOKEN=\"$TOKEN\"|" "$CONFIG_FILE"
    else
        # Add token after TELLME_WORKER_URL
        sed -i "/^TELLME_WORKER_URL=/a TELLME_TOKEN=\"$TOKEN\"" "$CONFIG_FILE"
    fi
    log "Token saved to $CONFIG_FILE"
else
    log "Warning: Config file not found, token not saved"
    echo ""
    echo "Please manually add this to your config file:"
    echo "TELLME_TOKEN=\"$TOKEN\""
fi

echo ""
echo "Registration completed successfully!"
echo "Token has been saved to your configuration file."
echo ""
echo "You can now use TellMe notification services."

