#!/bin/bash

# 載入配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/Tell_Me/config/config.sh"

echo "=== Tell_Me Discord 配置測試 ==="
echo ""

# 檢查 Webhook URL 是否設定
if [ "$DISCORD_WEBHOOK_URL" = "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN" ]; then
    echo "❌ 錯誤: 請先設定 Discord Webhook URL"
    echo ""
    echo "請按照以下步驟設定："
    echo "1. 開啟 Discord 應用程式或網頁版"
    echo "2. 進入您想要接收通知的頻道"
    echo "3. 點擊頻道名稱旁的齒輪圖示"
    echo "4. 選擇「整合」→「Webhook」"
    echo "5. 點擊「建立 Webhook」"
    echo "6. 複製 Webhook URL"
    echo "7. 編輯 Tell_Me/config/config.sh"
    echo "8. 將 DISCORD_WEBHOOK_URL 替換為您的 Webhook URL"
    echo ""
    exit 1
fi

echo "Discord 機器人名稱: $DISCORD_USERNAME"
echo "Discord 頭像 URL: $DISCORD_AVATAR_URL"
echo "Webhook URL: ${DISCORD_WEBHOOK_URL:0:50}..."
echo ""

# 測試網路連線
echo "測試網路連線..."
if ping -c 1 discord.com > /dev/null 2>&1; then
    echo "✓ 可以連接到 discord.com"
else
    echo "✗ 無法連接到 discord.com"
fi

echo ""
echo "=== 測試 Discord 通知 ==="

# 建立測試訊息
TEST_MESSAGE="🧪 **Tell_Me 測試通知**\n\n"
TEST_MESSAGE+="📋 **測試資訊**\n"
TEST_MESSAGE+="```\n"
TEST_MESSAGE+="測試時間: $(date '+%Y-%m-%d %H:%M:%S')\n"
TEST_MESSAGE+="主機名: $(hostname)\n"
TEST_MESSAGE+="IP 地址: $(hostname -I | awk '{print $1}')\n"
TEST_MESSAGE+="```\n\n"
TEST_MESSAGE+="✅ 如果您看到這則訊息，表示 Tell_Me Discord 通知功能運作正常！ 🎉"

# 發送測試訊息
echo "發送測試訊息到 Discord..."
curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"username\":\"$DISCORD_USERNAME\",\"avatar_url\":\"$DISCORD_AVATAR_URL\",\"content\":\"$TEST_MESSAGE\"}" \
     "$DISCORD_WEBHOOK_URL"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Discord 測試通知發送成功！"
    echo "請檢查您的 Discord 頻道是否收到測試訊息。"
else
    echo ""
    echo "❌ Discord 測試通知發送失敗"
    echo ""
    echo "可能的問題："
    echo "1. Webhook URL 不正確"
    echo "2. 網路連線問題"
    echo "3. Discord 頻道權限問題"
    echo "4. Webhook 已被刪除或停用"
fi
