# Discord Webhook 設定指南

## 🎯 為什麼選擇 Discord？

- **更安全**：不需要應用程式密碼
- **更簡單**：只需要一個 Webhook URL
- **更即時**：即時通知，不會被歸類為垃圾郵件
- **更豐富**：支援 Markdown 格式和表情符號

## 📋 設定步驟

### 1. 建立 Discord Webhook

1. **開啟 Discord**：應用程式或網頁版
2. **選擇頻道**：進入您想要接收通知的頻道
3. **開啟頻道設定**：
   - 點擊頻道名稱旁的齒輪圖示 ⚙️
   - 或右鍵點擊頻道名稱
4. **進入整合設定**：
   - 選擇「整合」→「Webhook」
5. **建立 Webhook**：
   - 點擊「建立 Webhook」
   - 設定機器人名稱（例如：Tell_Me Bot）
   - 選擇頭像（可選）
6. **複製 Webhook URL**：
   - 點擊「複製 Webhook URL」
   - 格式類似：`https://discord.com/api/webhooks/123456789/abcdefghijklmnop`

### 2. 更新 Tell_Me 配置

編輯 `Tell_Me/config/config.sh` 檔案：

```bash
nano Tell_Me/config/config.sh
```

找到這一行：
```bash
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
```

替換為您的實際 Webhook URL：
```bash
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/您的實際Webhook URL"
```

### 3. 測試設定

執行測試腳本：
```bash
chmod +x test_discord.sh
./test_discord.sh
```

### 4. 安裝服務

如果測試成功，重新安裝 Tell_Me：
```bash
./install_tell_me.sh
```

## 🔧 自訂設定

### 機器人名稱
在 `config.sh` 中修改：
```bash
DISCORD_USERNAME="您的機器人名稱"
```

### 機器人頭像
在 `config.sh` 中修改：
```bash
DISCORD_AVATAR_URL="https://您的頭像URL"
```

## 📱 通知類型

Tell_Me 會發送以下通知：

### 1. 登入通知 🔐
- 使用者名稱
- 主機名
- 登入時間
- 來源 IP
- 終端類型
- 會話資訊

### 2. 開機通知 🚀
- 主機名
- IP 地址
- 開機時間
- 運行時間
- 系統負載
- 磁碟使用率
- 記憶體使用率

## 🛡️ 安全注意事項

1. **保護 Webhook URL**：
   - 不要將 Webhook URL 分享給他人
   - 不要在公開場所顯示 Webhook URL
   - 定期更換 Webhook（如需要）

2. **頻道權限**：
   - 建議在私人頻道中設定 Webhook
   - 限制頻道成員權限

3. **備份設定**：
   - 記錄 Webhook URL（安全地）
   - 定期測試通知功能

## 🔍 故障排除

### 測試失敗
1. 檢查 Webhook URL 是否正確
2. 確認網路連線正常
3. 檢查 Discord 頻道權限
4. 確認 Webhook 未被刪除

### 通知未收到
1. 檢查 Discord 通知設定
2. 確認頻道未被靜音
3. 檢查機器人是否在線
4. 查看 Tell_Me 日誌檔案

## 📞 支援

如有問題，請檢查：
1. 日誌檔案：`~/Tell_Me/logs/`
2. Discord 頻道設定
3. 網路連線狀態
4. Webhook URL 有效性

---

**提示**：Discord Webhook 比 Gmail 更可靠，建議優先使用！
