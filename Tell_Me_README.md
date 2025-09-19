# Tell_Me 服務套件

這是一個統一的 Linux 系統通知服務套件，包含登入通知和開機後 IP 通知功能。

## 📁 目錄結構

### 專案根目錄
```
Linux-Setup/
├── Tell_Me/                        # Tell_Me 服務套件目錄
│   ├── login/                      # 登入通知服務
│   │   ├── notify.sh               # 登入通知腳本
│   │   ├── setup.sh                # 登入通知設定腳本
│   │   ├── notify.service          # systemd 服務檔案
│   │   └── install.sh              # 登入通知安裝腳本
│   ├── boot/                       # 開機後通知服務
│   │   ├── notify.sh               # 開機後通知腳本
│   │   ├── notify.service          # systemd 服務檔案
│   │   └── install.sh              # 開機後通知安裝腳本
│   └── config/                     # 統一配置目錄
│       └── config.sh               # 統一配置檔案
├── install_tell_me.sh              # 統一安裝腳本
├── manage_tell_me.sh               # 服務管理工具
└── Tell_Me_README.md               # 說明文件
```

### 運行時目錄結構
```
~/Tell_Me/
├── login/                 # 登入通知相關檔案
│   ├── notify.sh          # 登入通知腳本
│   └── setup.sh           # 登入通知設定腳本
├── boot/                  # 開機後通知相關檔案
│   └── notify.sh          # 開機後通知腳本
├── logs/                  # 日誌檔案目錄
│   ├── notify.log         # 通知日誌
│   └── install.log        # 安裝日誌
├── manage_tell_me.sh      # 服務管理工具
└── cleanup_logs.sh        # 日誌清理腳本
```

## 🚀 快速安裝

### 方法一：使用統一安裝腳本（推薦）

```bash
# 執行統一安裝腳本
./install_tell_me.sh
```

### 方法二：分別安裝

```bash
# 安裝登入通知服務
cd Tell_Me/login
./install.sh

# 安裝開機後通知服務
cd ../boot
./install.sh
```

## 🛠️ 服務管理

安裝完成後，管理工具會自動複製到 `~/Tell_Me/` 目錄中。使用管理腳本來管理所有服務：

```bash
# 安裝後使用（推薦）
~/Tell_Me/manage_tell_me.sh

# 或從專案目錄使用（安裝前）
./manage_tell_me.sh
```

管理腳本提供以下功能：
- 檢查服務狀態
- 啟動/停止/重啟服務
- 查看日誌
- 清理舊日誌
- 測試郵件發送
- 顯示配置資訊
- 重新安裝服務

## 📧 郵件配置

所有服務使用相同的郵件配置：

- **SMTP 伺服器**: smtp.gmail.com:587
- **發送者**: jw.albert.tw@gmail.com
- **接收者**: albert@mail.jw-albert.tw

如需修改郵件配置，請編輯 `~/Tell_Me/config/config.sh` 檔案。

## 🗑️ 安裝後清理

安裝完成後，您可以安全地刪除 `Linux-Setup` 資料夾，因為：

- 所有必要的檔案都已複製到 `~/Tell_Me/` 目錄
- 管理工具位於 `~/Tell_Me/manage_tell_me.sh`
- 服務腳本位於 `~/Tell_Me/login/` 和 `~/Tell_Me/boot/`
- 配置檔案位於 `~/Tell_Me/config/`
- 日誌檔案位於 `~/Tell_Me/logs/`

```bash
# 安裝完成後可以安全刪除
rm -rf Linux-Setup/
```

## 📋 服務說明

### 1. 登入通知服務 (login-notify.service)

- **功能**: 當有使用者透過 SSH 登入時自動發送通知郵件
- **觸發**: 每次 SSH 登入
- **日誌**: `~/Tell_Me/logs/notify.log`

### 2. 開機後通知服務 (notify.service)

- **功能**: 系統開機後自動發送系統資訊和 IP 地址
- **觸發**: 系統開機時
- **日誌**: `~/Tell_Me/logs/notify.log`

## 🔧 手動操作

### 檢查服務狀態

```bash
systemctl status login-notify.service
systemctl status notify.service
```

### 手動執行腳本

```bash
# 手動發送開機後通知
~/Tell_Me/boot/notify.sh

# 手動測試登入通知
~/Tell_Me/login/notify.sh
```

### 查看日誌

```bash
# 查看所有日誌
ls -la ~/Tell_Me/logs/

# 即時查看日誌
tail -f ~/Tell_Me/logs/notify.log
tail -f ~/Tell_Me/logs/install.log
```

## 🧹 日誌管理

- 日誌檔案會自動保留 30 天
- 每天凌晨 2 點自動清理舊日誌
- 可手動執行清理：`~/Tell_Me/cleanup_logs.sh`

## ⚠️ 注意事項

1. **權限要求**: 安裝腳本需要 sudo 權限
2. **網路連線**: 服務需要網路連線來發送郵件
3. **Gmail 設定**: 使用 Gmail 需要啟用應用程式密碼
4. **防火牆**: 確保 SMTP 端口 587 可正常連線

## 🐛 故障排除

### 服務無法啟動

```bash
# 檢查服務狀態
systemctl status login-notify.service
systemctl status notify.service

# 查看詳細錯誤
journalctl -u login-notify.service
journalctl -u notify.service
```

### 郵件發送失敗

1. 檢查網路連線
2. 確認 Gmail 應用程式密碼正確
3. 檢查 SMTP 設定
4. 查看日誌檔案中的錯誤訊息

### 權限問題

```bash
# 確保腳本有執行權限
chmod +x ~/Tell_Me/boot/notify.sh
chmod +x ~/Tell_Me/login/notify.sh
```

## 📞 支援

如有問題，請檢查：
1. 日誌檔案 (`~/Tell_Me/logs/`)
2. 系統服務狀態
3. 網路連線
4. 郵件配置

---

**版本**: 2.0  
**更新日期**: $(date '+%Y-%m-%d')  
**作者**: Albert
