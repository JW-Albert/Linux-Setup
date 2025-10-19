#!/bin/bash

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/Tell_Me/config/config.sh"

echo "=== Tell_Me Discord Configuration Test ==="
echo ""

# Check if Webhook URL is set
if [ "$DISCORD_WEBHOOK_URL" = "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN" ]; then
    echo "❌ Error: Please set Discord Webhook URL first"
    echo ""
    echo "Please follow these steps to configure:"
    echo "1. Open Discord application or web version"
    echo "2. Enter the channel where you want to receive notifications"
    echo "3. Click the gear icon next to the channel name"
    echo "4. Select "Integrations" → "Webhook""
    echo "5. Click "Create Webhook""
    echo "6. Copy the Webhook URL"
    echo "7. Edit Tell_Me/config/config.sh"
    echo "8. Replace DISCORD_WEBHOOK_URL with your Webhook URL"
    echo ""
    exit 1
fi

echo "Discord bot name: $DISCORD_USERNAME"
echo "Discord avatar URL: $DISCORD_AVATAR_URL"
echo "Webhook URL: ${DISCORD_WEBHOOK_URL:0:50}..."
echo ""

# Test network connection
echo "Testing network connection..."
if ping -c 1 discord.com > /dev/null 2>&1; then
    echo "✓ Can connect to discord.com"
else
    echo "✗ Cannot connect to discord.com"
fi

echo ""
echo "=== Testing Discord Notification ==="

# Create test message
TEST_MESSAGE="🧪 **Tell_Me Test Notification**\n\n📋 **Test Information**\n\`\`\`\nTest Time: $(date '+%Y-%m-%d %H:%M:%S')\nHostname: $(hostname)\nIP Address: $(hostname -I | awk '{print $1}')\n\`\`\`\n\n✅ If you see this message, the Tell_Me Discord notification feature is working properly! 🎉"

# Send test message
echo "Sending test message to Discord..."
curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"username\":\"$DISCORD_USERNAME\",\"avatar_url\":\"$DISCORD_AVATAR_URL\",\"content\":\"$TEST_MESSAGE\"}" \
     "$DISCORD_WEBHOOK_URL"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Discord test notification sent successfully!"
    echo "Please check your Discord channel for the test message."
else
    echo ""
    echo "❌ Discord test notification failed to send"
    echo ""
    echo "Possible issues:"
    echo "1. Incorrect Webhook URL"
    echo "2. Network connection problem"
    echo "3. Discord channel permission issue"
    echo "4. Webhook has been deleted or disabled"
fi
