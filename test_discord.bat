@echo off
echo === Tell_Me Discord 配置測試 ===
echo.

REM 檢查 Webhook URL 是否設定
set "WEBHOOK_URL=https://discord.com/api/webhooks/1419203705751994420/UE2we0TjTDflXdHadPAM9EWZV_BPsSRxbJ4f0ooM1oP1pNBcSYS1hUQpJouWtd7pNA8E"
set "USERNAME=Tell_Me Bot"
set "AVATAR_URL=https://cdn.discordapp.com/embed/avatars/0.png"

echo Discord 機器人名稱: %USERNAME%
echo Discord 頭像 URL: %AVATAR_URL%
echo Webhook URL: %WEBHOOK_URL:~0,50%...
echo.

echo === 測試 Discord 通知 ===

REM 建立測試訊息
set "TEST_MESSAGE=🧪 **Tell_Me 測試通知**\n\n**測試時間**: %date% %time%\n**主機名**: %COMPUTERNAME%\n**使用者**: %USERNAME%\n\n如果您看到這則訊息，表示 Tell_Me Discord 通知功能運作正常！ 🎉"

REM 建立 JSON 資料
set "JSON_DATA={\"username\":\"%USERNAME%\",\"avatar_url\":\"%AVATAR_URL%\",\"content\":\"%TEST_MESSAGE%\"}"

echo 發送測試訊息到 Discord...
echo JSON 資料: %JSON_DATA%

REM 使用 PowerShell 發送請求
powershell -Command "try { $response = Invoke-RestMethod -Uri '%WEBHOOK_URL%' -Method Post -Body '%JSON_DATA%' -ContentType 'application/json'; Write-Host '✅ Discord 測試通知發送成功！'; Write-Host '請檢查您的 Discord 頻道是否收到測試訊息。' } catch { Write-Host '❌ Discord 測試通知發送失敗'; Write-Host '錯誤詳情:'; Write-Host $_.Exception.Message }"

echo.
echo 測試完成！
pause
