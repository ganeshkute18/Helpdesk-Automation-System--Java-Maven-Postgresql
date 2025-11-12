param(
    [string]$OutputPath = "..\helpdesk-automation-system.zip"
)

Write-Host "=== Creating Deployment Package ===" -ForegroundColor Green

# Clean build artifacts
Write-Host "Cleaning build artifacts..." -ForegroundColor Yellow
Remove-Item -Path ".\backend\target" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".\backend\.idea" -Recurse -Force -ErrorAction SilentlyContinue

# Exclude unnecessary files from zip
$exclude = @("*.git*", "*\.idea", "*\.DS_Store", "*node_modules")

# Create zip
Write-Host "Creating zip file..." -ForegroundColor Yellow
Compress-Archive -Path "." -DestinationPath $OutputPath -Force

$zipSize = (Get-Item $OutputPath).Length / 1MB
Write-Host "✓ Package created: $OutputPath" -ForegroundColor Green
Write-Host "  Size: $([Math]::Round($zipSize, 2)) MB" -ForegroundColor Cyan
