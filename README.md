# Linux-Setup

這是一個用於快速設定和配置 Linux 系統的腳本集合，特別針對 Debian/Ubuntu 系統設計。這些腳本可以幫助您自動化常見的系統設定任務，包括用戶管理、安全配置、服務安裝等。

## 📁 專案結構

```
Linux-Setup/
├── albert.sh                    # 用戶帳戶設定腳本
├── docker.sh                    # Docker 安裝腳本
├── nezhahq.sh                   # Nezha 監控代理安裝腳本 for JW-Albert
├── sshd.sh                      # SSH 服務配置腳本
├── timedatectl-Debian12.sh      # 時間同步設定腳本 for Debian 12 and Ubuntu 24.02
├── timedatectl-Ubuntu24.02      # 時間同步設定腳本 for Ubuntu 24.02
├── ufw.sh                       # 防火牆配置腳本
├── Tell_Me/                     # Tell_Me 通知服務套件
│   ├── login/                   # 登入通知服務
│   ├── boot/                    # 開機後通知服務
│   └── config/                  # 統一配置
├── install_tell_me.sh           # Tell_Me 統一安裝腳本
├── manage_tell_me.sh            # Tell_Me 管理工具
├── test_discord.sh              # Discord 測試腳本
└── DISCORD_SETUP.md             # Discord 設定指南
└── README.md                    # 專案說明文件
```

## 🚀 功能特色

### 1. 用戶管理 (`albert.sh`)
- 建立新用戶帳戶 (albert)
- 授予 sudo 權限
- 設定用戶密碼
- 自動更新系統套件

### 2. Docker 環境 (`docker.sh`)
- 自動安裝 Docker
- 安裝 Docker Compose
- 設定開機自動啟動
- 支援最新版本安裝

### 3. 系統監控 (`nezhahq.sh`)
- 安裝 Nezha 監控代理
- 自動配置連接到指定伺服器
- 簡化監控設定流程

### 4. SSH 安全配置 (`sshd.sh`)
- 自定義 SSH 連接埠
- 控制 root 登入權限
- 自動備份原始設定
- 安全重啟 SSH 服務

### 5. 時間同步 (`timedatectl-Debian12.sh`)
- 設定台灣時區 (Asia/Taipei)
- 配置台灣標準時間伺服器
- 啟用 NTP 同步
- 同步硬體時鐘

### 6. 防火牆設定 (`ufw.sh`)
- 安裝並配置 UFW 防火牆
- 自定義 SSH 連接埠
- 可選開放 HTTP/HTTPS 連接埠
- 增強 ICMP 安全設定，拋棄所有 ICMP 封包(這會導致裝置無法被 PING)
- 自動備份 SSH 配置

### 7. Tell_Me 通知系統 (`Tell_Me/`)
- 登入通知：SSH 登入時自動發送通知
- 開機通知：系統開機後自動發送系統資訊
- 透過 Discord Webhook 發送通知
- 包含詳細的系統和使用者資訊
- 設定為 systemd 服務

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

### 1. 基本用戶設定
```bash
chmod +x albert.sh
sudo ./albert.sh
```

### 2. Docker 與 docker-compose 環境安裝
```bash
chmod +x docker.sh
sudo ./docker.sh 
```

### 3. SSH 安全配置
```bash
chmod +x sshd.sh
sudo ./sshd.sh
```

### 4. 時間同步設定
```bash
chmod +x timedatectl-Debian12.sh
sudo ./timedatectl-Debian12.sh
```

### 5. 防火牆配置
```bash
chmod +x ufw.sh
sudo ./ufw.sh
```

### 6. Tell_Me 通知系統設定
```bash
# 統一安裝 Tell_Me 服務
chmod +x install_tell_me.sh
sudo ./install_tell_me.sh

# 測試 Discord 通知
chmod +x test_discord.sh
./test_discord.sh
```

## ⚠️ 重要注意事項

### 安全提醒
1. **SSH 連接埠變更**：執行 `sshd.sh` 或 `ufw.sh` 後，SSH 連接埠會變更，請記住新的連接埠號碼
2. **防火牆啟用**：`ufw.sh` 會啟用防火牆，確保在執行前已正確配置允許的連接埠
3. **備份檔案**：腳本會自動備份重要設定檔案，備份位置通常在原始檔案同目錄

### 執行順序建議
1. 首先執行 `albert.sh` 建立用戶帳戶
2. 執行 `sshd.sh` 或 `ufw.sh` 配置 SSH 和防火牆
3. 根據需求執行其他腳本

### Tell_Me 通知設定
- 需要配置 Discord Webhook URL
- 確保網路連線到 discord.com
- 服務會在登入和開機時自動執行

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
```

## 📝 版本資訊

- **版本**：1.0.0
- **最後更新**：2025年06月25日
- **支援系統**：Debian 12, Ubuntu 20.04+

## 🤝 貢獻

歡迎提交 Issue 和 Pull Request 來改善這個專案。

## 📄 授權

本專案採用 MIT 授權條款。

---

**注意**：這些腳本會修改系統重要設定，請在測試環境中先進行測試，並確保了解每個腳本的功能後再在生產環境中使用。
