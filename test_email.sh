#!/bin/bash

# 載入配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/Tell_Me/config/config.sh"

echo "=== Tell_Me 郵件配置測試 ==="
echo "SMTP 伺服器: $SMTP_SERVER:$SMTP_PORT"
echo "發送者: $SENDER_EMAIL"
echo "接收者: $RECIPIENT_EMAIL"
echo "密碼長度: ${#SENDER_PASSWORD} 字符"
echo ""

# 測試網路連線
echo "測試網路連線..."
if ping -c 1 $SMTP_SERVER > /dev/null 2>&1; then
    echo "✓ 可以連接到 $SMTP_SERVER"
else
    echo "✗ 無法連接到 $SMTP_SERVER"
fi

# 測試 SMTP 端口
echo "測試 SMTP 端口..."
if nc -z $SMTP_SERVER $SMTP_PORT 2>/dev/null; then
    echo "✓ SMTP 端口 $SMTP_PORT 可訪問"
else
    echo "✗ SMTP 端口 $SMTP_PORT 無法訪問"
fi

echo ""
echo "=== 測試郵件發送 ==="

# 建立測試郵件
SUBJECT="Tell_Me 測試郵件: $(hostname)"
BODY="這是一封測試郵件

發送時間: $(date '+%Y-%m-%d %H:%M:%S')
主機名: $(hostname)
IP 地址: $(hostname -I | awk '{print $1}')

如果您收到此郵件，表示 Tell_Me 郵件服務運作正常。
"

echo "Subject: $SUBJECT

$BODY" | curl -v \
    --url "smtp://$SMTP_SERVER:$SMTP_PORT" \
    --mail-from "$SENDER_EMAIL" \
    --mail-rcpt "$RECIPIENT_EMAIL" \
    --ssl-reqd \
    --user "$SENDER_EMAIL:$SENDER_PASSWORD" \
    --upload-file - \
    --mail-rcpt-allowfails \
    --fail-with-body

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ 測試郵件發送成功！"
else
    echo ""
    echo "✗ 測試郵件發送失敗"
    echo ""
    echo "可能的問題："
    echo "1. Gmail 應用程式密碼不正確"
    echo "2. 網路連線問題"
    echo "3. Gmail 帳戶設定問題"
    echo "4. 防火牆阻擋 SMTP 連接"
fi
