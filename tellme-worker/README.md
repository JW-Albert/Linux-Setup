# TellMe Cloudflare Worker

Linux 自動通知系統 TellMe 的雲端 gateway。Client 永遠不拿到 Gmail 密碼或 Discord webhook；client 只送事件到 Worker，Worker 用自己的 secrets 幫你送通知。

## 📋 功能

- **OTP 註冊系統**：新機器透過 OTP 註冊，無需在 client 端儲存敏感資訊
- **Token 認證**：註冊成功後取得長期 token
- **事件通知**：Client 使用 token 發送事件，Worker 自動轉發到 Discord
- **Email OTP**：使用 Resend API 發送 OTP 郵件

## 🚀 快速開始

### 1. 安裝 Wrangler CLI

```bash
npm install -g wrangler
# 或
npm install wrangler --save-dev
```

### 2. 登入 Cloudflare

```bash
wrangler login
```

### 3. 建立 KV Namespaces

建立兩個 KV namespace：

```bash
# 建立 REG_KV（用於 OTP 註冊資料）
wrangler kv:namespace create "REG_KV"
# 複製輸出的 id，更新到 wrangler.toml 的 REG_KV id

# 建立 preview namespace
wrangler kv:namespace create "REG_KV" --preview
# 複製輸出的 id，更新到 wrangler.toml 的 REG_KV preview_id

# 建立 TOKEN_KV（用於 client token）
wrangler kv:namespace create "TOKEN_KV"
# 複製輸出的 id，更新到 wrangler.toml 的 TOKEN_KV id

# 建立 preview namespace
wrangler kv:namespace create "TOKEN_KV" --preview
# 複製輸出的 id，更新到 wrangler.toml 的 TOKEN_KV preview_id
```

### 4. 設定 Secrets

設定必要的 secrets：

```bash
# Discord Webhook URL
wrangler secret put DISCORD_WEBHOOK

# Resend API Key
wrangler secret put RESEND_API_KEY

# 收 OTP 的信箱
wrangler secret put EMAIL_TO

# 寄出用的 from 信箱（必須是 Resend 驗證過的 domain）
wrangler secret put EMAIL_FROM
```

### 5. 更新 wrangler.toml

將 KV namespace IDs 更新到 `wrangler.toml`：

```toml
[[kv_namespaces]]
binding = "REG_KV"
id = "你的-REG_KV-id"
preview_id = "你的-REG_KV-preview-id"

[[kv_namespaces]]
binding = "TOKEN_KV"
id = "你的-TOKEN_KV-id"
preview_id = "你的-TOKEN_KV-preview-id"
```

### 6. 部署

```bash
wrangler deploy
```

## 📡 API 規格

所有 endpoints 只接受 POST（除了 `/health`）。

### A. POST /register/request

新機器請求註冊，產生 OTP 並寄送到 EMAIL_TO。

**Request:**
```json
{
  "hostname": "server-01",
  "user": "root",
  "machine_id": "hashed-fingerprint"
}
```

**Response:**
```json
{
  "registration_id": "uuid",
  "message": "OTP sent"
}
```

### B. POST /register/confirm

使用者輸入 OTP，驗證成功後發放 client token。

**Request:**
```json
{
  "registration_id": "uuid",
  "otp": "123456"
}
```

**Response:**
```json
{
  "token": "tm_..."
}
```

**錯誤碼：**
- `400`: Registration not found or expired
- `401`: Invalid OTP
- `403`: Too many failed attempts (>= 5)

### C. POST /event

Client 發送事件，Worker 轉發到 Discord。

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "event": "login",
  "hostname": "server-01",
  "user": "root",
  "time": 1735688888,
  "ip": "1.2.3.4",
  "message": "optional"
}
```

**Response:**
```json
{
  "status": "ok"
}
```

**錯誤碼：**
- `401`: Missing/invalid Authorization header or invalid token
- `403`: Token disabled or event not allowed
- `413`: Payload too large (> 4KB)
- `502`: Discord webhook failed

### D. GET /health

健康檢查 endpoint。

**Response:**
```json
{
  "ok": true
}
```

## 🧪 測試

### 測試註冊流程

```bash
# 1. 請求註冊
curl -X POST https://your-worker.workers.dev/register/request \
  -H "Content-Type: application/json" \
  -d '{
    "hostname": "test-server",
    "user": "root",
    "machine_id": "test-machine-123"
  }'

# 2. 檢查信箱取得 OTP，然後確認註冊
curl -X POST https://your-worker.workers.dev/register/confirm \
  -H "Content-Type: application/json" \
  -d '{
    "registration_id": "從上一步取得的 registration_id",
    "otp": "從信箱取得的 6 位數 OTP"
  }'
```

### 測試事件發送

```bash
curl -X POST https://your-worker.workers.dev/event \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer tm_你的token" \
  -d '{
    "event": "login",
    "hostname": "test-server",
    "user": "root",
    "time": 1735688888,
    "ip": "1.2.3.4",
    "message": "Test login event"
  }'
```

### 測試健康檢查

```bash
curl https://your-worker.workers.dev/health
```

## 🔒 安全特性

- OTP 只存 hash（SHA256），不存明碼
- OTP 有 TTL（10 分鐘）與 attempts limit（5 次）
- Token 長度足夠（128+ 字元）
- 禁止回傳任何 webhook / email 密碼給 client
- 所有 endpoint 只接受 POST（除了 `/health`）
- 基本 CORS 支援

## 📝 注意事項

1. **Resend API Key**：需要在 [Resend](https://resend.com) 註冊並取得 API key
2. **EMAIL_FROM**：必須是 Resend 驗證過的 domain
3. **KV Namespace**：記得建立 production 和 preview 兩個 namespace
4. **Secrets**：所有 secrets 都需要透過 `wrangler secret put` 設定

## 🛠️ 開發

### 本地測試

```bash
wrangler dev
```

### 查看日誌

```bash
wrangler tail
```

## 📦 專案結構

```
tellme-worker/
├── wrangler.toml      # Wrangler 配置
├── src/
│   └── index.js       # Worker 主程式
└── README.md          # 本文件
```

## 🔄 更新部署

修改程式碼後：

```bash
wrangler deploy
```

## 📞 故障排除

### KV Namespace 錯誤

確認 `wrangler.toml` 中的 KV namespace IDs 正確。

### Secrets 未設定

使用 `wrangler secret list` 檢查已設定的 secrets。

### Email 發送失敗

1. 確認 Resend API key 正確
2. 確認 EMAIL_FROM 是 Resend 驗證過的 domain
3. 查看 Worker logs：`wrangler tail`

### Discord Webhook 失敗

1. 確認 DISCORD_WEBHOOK secret 正確
2. 確認 webhook URL 格式正確
3. 查看 Worker logs：`wrangler tail`

