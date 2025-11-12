param(
    [string]$RepoUrl = "",
    [string]$Branch = "main"
)

if ([string]::IsNullOrEmpty($RepoUrl)) {
    Write-Host "Usage: .\push-to-github.ps1 -RepoUrl 'https://github.com/username/repo.git'" -ForegroundColor Yellow
    exit 1
}

Write-Host "=== Pushing to GitHub ===" -ForegroundColor Green

# Check if git is installed
try {
    git --version | Out-Null
} catch {
    Write-Host "✗ Git not found. Please install Git" -ForegroundColor Red
    exit 1
}

# Initialize git if not already done
if (-not (Test-Path ".\.git")) {
    Write-Host "Initializing git repository..." -ForegroundColor Yellow
    git init
    git add .
    git commit -m "Initial commit: helpdesk automation system"
    Write-Host "✓ Repository initialized" -ForegroundColor Green
} else {
    Write-Host "Git repository already exists" -ForegroundColor Yellow
}

# Add remote and push
Write-Host "Setting remote origin..." -ForegroundColor Yellow
git remote add origin $RepoUrl -ErrorAction SilentlyContinue

Write-Host "Setting branch to $Branch..." -ForegroundColor Yellow
git branch -M $Branch

Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
git push -u origin $Branch -f

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Repository pushed successfully" -ForegroundColor Green
    Write-Host "`nRepository URL: $RepoUrl" -ForegroundColor Cyan
} else {
    Write-Host "✗ Push failed. Check your credentials and internet connection." -ForegroundColor Red
    exit 1
}
