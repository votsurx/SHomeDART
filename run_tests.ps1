Write-Host "🧪 Запуск тестов SHome (последовательно)..." -ForegroundColor Cyan
Write-Host ""

flutter test --concurrency=1

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Все тесты пройдены!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "❌ Некоторые тесты упали" -ForegroundColor Red
}
