# Tell_Me 協作開發指南

## 🎯 專案結構說明

為了便於協作編輯，我們將 Tell_Me 服務套件分為兩個獨立的模組：

### 1. login 模組
負責處理 SSH 登入通知功能

**檔案結構：**
```
Tell_Me/login/
├── notify.sh               # 主要登入通知腳本
├── setup.sh                # PAM 設定腳本
├── notify.service           # systemd 服務檔案
└── install.sh              # 獨立安裝腳本
```

**功能：**
- 監控 SSH 登入事件
- 發送登入通知郵件
- 自動設定 PAM 配置
- 提供詳細的登入資訊（使用者、IP、時間等）

### 2. boot 模組
負責處理開機後系統資訊通知功能

**檔案結構：**
```
Tell_Me/boot/
├── notify.sh               # 主要開機後通知腳本
├── notify.service           # systemd 服務檔案
└── install.sh              # 獨立安裝腳本
```

**功能：**
- 開機後自動發送系統資訊
- 包含 IP 地址、系統狀態等資訊
- 提供系統監控功能

### 3. config 模組
統一配置管理

**檔案結構：**
```
Tell_Me/config/
└── config.sh               # 統一配置檔案
```

**功能：**
- 統一管理所有模組的配置
- 郵件設定、路徑設定等
- 提供共用函數和變數

## 🔧 協作開發建議

### 1. 模組化開發
- 每個模組可以獨立開發和測試
- 修改一個模組不會影響另一個模組
- 可以分別進行版本控制和發布

### 2. 配置統一管理
- 所有模組共享 `Tell_Me/config/config.sh` 配置檔案
- 郵件設定、路徑設定等統一管理
- 便於維護和更新

### 3. 獨立安裝
- 每個模組都有獨立的安裝腳本
- 可以選擇性安裝需要的功能
- 便於測試和部署

### 4. 統一管理工具
- `manage_tell_me.sh` 提供統一的管理介面
- 支援單獨管理每個模組
- 提供重新安裝功能

## 📝 開發工作流程

### 1. 修改登入通知功能
```bash
# 進入登入通知模組目錄
cd Tell_Me/login/

# 修改相關檔案
vim notify.sh
vim setup.sh

# 測試安裝
./install.sh

# 測試功能
systemctl status login-notify.service
```

### 2. 修改開機後通知功能
```bash
# 進入開機後通知模組目錄
cd Tell_Me/boot/

# 修改相關檔案
vim notify.sh

# 測試安裝
./install.sh

# 測試功能
systemctl status notify.service
```

### 3. 修改配置
```bash
# 修改統一配置檔案
vim Tell_Me/config/config.sh

# 重新安裝受影響的服務
./manage_tell_me.sh
# 選擇選項 9 重新安裝服務
```

## 🧪 測試建議

### 1. 單元測試
- 每個模組獨立測試
- 使用 `./manage_tell_me.sh` 的測試郵件功能
- 檢查日誌檔案確認功能正常

### 2. 整合測試
- 使用 `./install_tell_me.sh` 進行完整安裝測試
- 測試所有服務的協同工作
- 驗證統一管理工具的功能

### 3. 部署測試
- 在測試環境中部署
- 驗證自動啟動功能
- 測試錯誤處理和恢復

## 📋 版本控制建議

### 1. 分支策略
- `main`: 穩定版本
- `develop`: 開發版本
- `feature/login`: 登入通知功能分支
- `feature/boot`: 開機後通知功能分支

### 2. 提交訊息格式
```
[模組名稱] 簡短描述

詳細說明：
- 修改內容
- 影響範圍
- 測試結果
```

### 3. 發布流程
1. 在功能分支完成開發
2. 合併到 develop 分支
3. 測試通過後合併到 main
4. 建立版本標籤
5. 更新文檔

## 🚀 部署建議

### 1. 開發環境
```bash
# 克隆專案
git clone <repository-url>
cd Linux-Setup

# 安裝開發依賴
sudo apt update
sudo apt install -y curl git

# 安裝 Tell_Me 服務
./install_tell_me.sh
```

### 2. 生產環境
```bash
# 使用統一安裝腳本
./install_tell_me.sh

# 或選擇性安裝
cd Tell_Me/login && ./install.sh
cd ../boot && ./install.sh
```

## 📞 協作溝通

### 1. 問題回報
- 使用 GitHub Issues
- 標明受影響的模組
- 提供詳細的錯誤資訊和日誌

### 2. 功能請求
- 說明需求場景
- 標明影響的模組
- 提供使用案例

### 3. 代碼審查
- 檢查代碼品質
- 驗證功能正確性
- 確認文檔更新

---

**注意**: 此專案採用模組化設計，每個模組可以獨立開發、測試和部署，大大提高了協作開發的便利性。
