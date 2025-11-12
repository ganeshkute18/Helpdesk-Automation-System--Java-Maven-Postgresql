param(
    [string]$Output = ".\helpdesk-backend-0.0.1-SNAPSHOT.jar"
)

Write-Host "=== Building Production JAR ===" -ForegroundColor Green

Push-Location .\backend

Write-Host "Running Maven clean package..." -ForegroundColor Yellow
mvn clean package -DskipTests -q

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Build successful" -ForegroundColor Green
    
    $jarPath = ".\target\helpdesk-backend-0.0.1-SNAPSHOT.jar"
    if (Test-Path $jarPath) {
        Copy-Item $jarPath -Destination $Output
        $jarSize = (Get-Item $Output).Length / 1MB
        Write-Host "✓ JAR created: $Output ($([Math]::Round($jarSize, 2)) MB)" -ForegroundColor Green
        Write-Host "`nTo run the JAR:" -ForegroundColor Cyan
        Write-Host "  java -jar $Output" -ForegroundColor Cyan
    }
} else {
    Write-Host "✗ Build failed" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location
