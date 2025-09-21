@echo off
chcp 65001 >nul
echo === Tell_Me Discord 測試 ===
echo.

set "WEBHOOK_URL=https://discord.com/api/webhooks/1419203705751994420/UE2we0TjTDflXdHadPAM9EWZV_BPsSRxbJ4f0ooM1oP1pNBcSYS1hUQpJouWtd7pNA8E"

echo 正在發送測試訊息到 Discord...
echo.

powershell -Command "$body = @{username='Tell_Me Bot';avatar_url='https://cdn.discordapp.com/embed/avatars/0.png';content='🧪 **Tell_Me 測試通知**\n\n**測試時間**: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + '\n**主機名**: ' + $env:COMPUTERNAME + '\n**使用者**: ' + $env:USERNAME + '\n\n如果您看到這則訊息，表示 Tell_Me Discord 通知功能運作正常！ 🎉'} | ConvertTo-Json; try { Invoke-RestMethod -Uri '%WEBHOOK_URL%' -Method Post -Body $body -ContentType 'application/json' -ErrorAction Stop; Write-Host '✅ Discord 測試通知發送成功！' -ForegroundColor Green; Write-Host '請檢查您的 Discord #notify 頻道是否收到測試訊息。' -ForegroundColor Cyan } catch { Write-Host '❌ Discord 測試通知發送失敗' -ForegroundColor Red; Write-Host '錯誤詳情:' -ForegroundColor Yellow; Write-Host $_.Exception.Message -ForegroundColor Red }"

echo.
echo 測試完成！
pause
