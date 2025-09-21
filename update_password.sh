#!/bin/bash

# Tell_Me 密碼更新腳本

echo "=== Tell_Me 密碼更新工具 ==="
echo ""

# 檢查配置檔案是否存在
CONFIG_FILE="Tell_Me/config/config.sh"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "錯誤: 找不到配置檔案 $CONFIG_FILE"
    exit 1
fi

echo "請輸入新的 Gmail 應用程式密碼："
read -s NEW_PASSWORD

if [ -z "$NEW_PASSWORD" ]; then
    echo "錯誤: 密碼不能為空"
    exit 1
fi

# 備份原配置檔案
cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
echo "已備份原配置檔案"

# 更新密碼
sed -i "s/SENDER_PASSWORD=\".*\"/SENDER_PASSWORD=\"$NEW_PASSWORD\"/" "$CONFIG_FILE"

echo ""
echo "✓ 密碼已更新"
echo ""

# 測試新密碼
echo "是否要測試新密碼？(y/n)"
read -p "請選擇: " test_choice

if [ "$test_choice" = "y" ] || [ "$test_choice" = "Y" ]; then
    echo ""
    echo "=== 測試新密碼 ==="
    ./test_email.sh
fi

echo ""
echo "密碼更新完成！"
echo "如果測試成功，請重新安裝服務："
echo "  ./install_tell_me.sh"
