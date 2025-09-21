# Linux-Setup

這是一個用於快速設定和配置 Linux 系統的腳本集合，特別針對 Debian/Ubuntu 系統設計。這些腳本可以幫助您自動化常見的系統設定任務，包括用戶管理、安全配置、服務安裝等。

## 📁 專案結構

```
Linux-Setup/
├── Debian.sh                    # Debian 系統完整設定腳本
├── docker.sh                    # Docker 安裝腳本
├── sshd_secure_setup.sh         # SSH 安全配置腳本
├── timedatectl-Debian12.sh      # 時間同步設定腳本 for Debian 12
├── timedatectl-Ubuntu24.02.sh   # 時間同步設定腳本 for Ubuntu 24.02
├── ufw_secure_setup.sh          # 防火牆安全配置腳本
├── sudoer.sh                    # sudo 權限設定腳本
├── Tell_Me/                     # Tell_Me 通知服務套件
│   ├── login/                   # 登入通知服務
│   │   ├── notify.sh            # 登入通知腳本
│   │   ├── setup.sh             # PAM 設定腳本
│   │   ├── login-notify.service # systemd 服務檔案
│   │   └── install.sh           # 登入通知安裝腳本
│   ├── boot/                    # 開機後通知服務
│   │   ├── notify.sh            # 開機通知腳本
│   │   ├── boot-notify.service  # systemd 服務檔案
│   │   └── install.sh           # 開機通知安裝腳本
│   ├── config/                  # 統一配置
│   │   ├── config.sh            # 統一配置檔案
│   │   └── icon.png             # Discord 頭像圖示
│   ├── manage_tell_me.sh       # Tell_Me 管理工具
│   └── test_discord.sh          # Discord 測試腳本
├── install_tell_me.sh           # Tell_Me 統一安裝腳本
├── Tell_Me_README.md            # Tell_Me 詳細說明文件
├── COLLABORATION_GUIDE.md       # 協作開發指南
├── DISCORD_SETUP.md             # Discord 設定指南
└── README.md                    # 專案說明文件
```

## 🚀 功能特色

### 1. Debian 系統完整設定 (`Debian.sh`)
- 系統更新和套件安裝
- 建立用戶帳戶並授予 sudo 權限
- SSH 安全配置（自定義連接埠、控制 root 登入）
- UFW 防火牆設定（ICMP 安全配置）
- 時間同步設定（台灣時區、NTP 伺服器）
- 自動安裝 Tell_Me 通知系統

### 2. Docker 環境 (`docker.sh`)
- 自動安裝 Docker
- 安裝 Docker Compose
- 設定開機自動啟動
- 支援最新版本安裝

### 3. SSH 安全配置 (`sshd_secure_setup.sh`)
- 自定義 SSH 連接埠
- 控制 root 登入權限
- 自動備份原始設定
- 安全重啟 SSH 服務

### 4. 時間同步設定
- **Debian 12** (`timedatectl-Debian12.sh`)：設定台灣時區和 NTP 伺服器
- **Ubuntu 24.02** (`timedatectl-Ubuntu24.02.sh`)：Ubuntu 專用時間同步設定

### 5. 防火牆安全配置 (`ufw_secure_setup.sh`)
- 安裝並配置 UFW 防火牆
- 自定義 SSH 連接埠
- 可選開放 HTTP/HTTPS 連接埠
- 增強 ICMP 安全設定，拋棄所有 ICMP 封包（這會導致裝置無法被 PING）
- 自動備份 SSH 配置

### 6. sudo 權限設定 (`sudoer.sh`)
- 為指定用戶授予 sudo 權限
- 安全的權限管理

### 7. Tell_Me 通知系統 (`Tell_Me/`)
- **登入通知**：SSH 登入時自動發送 Discord 通知
- **開機通知**：系統開機後自動發送系統資訊
- **Discord 整合**：透過 Webhook 發送美觀格式的通知
- **系統服務**：設定為 systemd 服務，自動啟動
- **管理工具**：提供完整的管理和監控功能

## 📋 使用前準備

### 系統需求
- Debian 12 或 Ubuntu 系統
- Root 權限或 sudo 權限
- 網路連接

### 權限要求
所有腳本都需要 root 權限執行：
```bash
sudo su
```

## 🔧 使用方法

### 🚀 快速開始（推薦）
**一鍵完成所有設定**：
```bash
# 以 root 身份執行完整設定
sudo su
chmod +x Debian.sh
./Debian.sh
```

### 📋 個別腳本使用

### 1. Docker 環境安裝
```bash
chmod +x docker.sh
sudo ./docker.sh 
```

### 2. SSH 安全配置
```bash
chmod +x sshd_secure_setup.sh
sudo ./sshd_secure_setup.sh
```

### 3. 時間同步設定
```bash
# Debian 12
chmod +x timedatectl-Debian12.sh
sudo ./timedatectl-Debian12.sh

# Ubuntu 24.02
chmod +x timedatectl-Ubuntu24.02.sh
sudo ./timedatectl-Ubuntu24.02.sh
```

### 4. 防火牆安全配置
```bash
chmod +x ufw_secure_setup.sh
sudo ./ufw_secure_setup.sh
```

### 5. sudo 權限設定
```bash
chmod +x sudoer.sh
sudo ./sudoer.sh
```

### 6. Tell_Me 通知系統設定
```bash
# 統一安裝 Tell_Me 服務
chmod +x install_tell_me.sh
sudo ./install_tell_me.sh

# 測試 Discord 通知
chmod +x Tell_Me/test_discord.sh
./Tell_Me/test_discord.sh

# 使用管理工具
chmod +x ~/Tell_Me/manage_tell_me.sh
~/Tell_Me/manage_tell_me.sh
```

## ⚠️ 重要注意事項

### 安全提醒
1. **SSH 連接埠變更**：執行 SSH 或防火牆腳本後，SSH 連接埠會變更，請記住新的連接埠號碼
2. **防火牆啟用**：防火牆腳本會啟用 UFW，確保在執行前已正確配置允許的連接埠
3. **備份檔案**：腳本會自動備份重要設定檔案，備份位置通常在原始檔案同目錄
4. **ICMP 封包**：防火牆會拋棄所有 ICMP 封包，這會導致裝置無法被 PING

### 執行順序建議
1. **推薦**：直接執行 `Debian.sh` 完成所有基本設定
2. **個別設定**：根據需求執行其他專用腳本
3. **Tell_Me 設定**：在基本系統設定完成後安裝通知系統

### Tell_Me 通知設定
- 需要配置 Discord Webhook URL（參考 `DISCORD_SETUP.md`）
- 確保網路連線到 discord.com
- 服務會在登入和開機時自動執行
- 使用 `~/Tell_Me/manage_tell_me.sh` 管理服務

## 🔍 故障排除

### 常見問題
1. **權限錯誤**：確保以 root 權限執行腳本
2. **網路連接問題**：檢查網路設定和防火牆規則
3. **服務啟動失敗**：檢查 systemd 服務狀態

### 檢查服務狀態
```bash
# 檢查 SSH 服務
sudo systemctl status ssh

# 檢查 Docker 服務
sudo systemctl status docker

# 檢查 Tell_Me 服務
sudo systemctl status login-notify.service
sudo systemctl status boot-notify.service

# 檢查防火牆狀態
sudo ufw status

# 檢查時間同步服務
sudo systemctl status systemd-timesyncd
sudo timedatectl status
```

### Tell_Me 管理
```bash
# 使用管理工具
~/Tell_Me/manage_tell_me.sh

# 查看日誌
tail -f /var/log/tell_me/login_notify.log
tail -f /var/log/tell_me/notify.log

# 測試 Discord 通知
./Tell_Me/test_discord.sh
```

## 📝 版本資訊

- **版本**：3.0.0
- **最後更新**：2025年09月21日
- **支援系統**：Debian 12, Debian 13(同12版), Ubuntu 24.02+
- **主要更新**：
  - 新增 `Debian.sh` 一鍵完整設定腳本
  - 重構 Tell_Me 通知系統，支援 Discord Webhook
  - 優化腳本結構和權限管理
  - 新增協作開發指南和詳細文檔

## 📚 相關文檔

- **[Tell_Me_README.md](Tell_Me_README.md)**：Tell_Me 通知系統詳細說明
- **[DISCORD_SETUP.md](DISCORD_SETUP.md)**：Discord Webhook 設定指南
- **[COLLABORATION_GUIDE.md](COLLABORATION_GUIDE.md)**：協作開發指南

## 🤝 貢獻

歡迎提交 Issue 和 Pull Request 來改善這個專案。

## 📄 授權

本專案採用 MIT 授權條款。

---

**⚠️ 重要提醒**：這些腳本會修改系統重要設定，請在測試環境中先進行測試，並確保了解每個腳本的功能後再在生產環境中使用。
