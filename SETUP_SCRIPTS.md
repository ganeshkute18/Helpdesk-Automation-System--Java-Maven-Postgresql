# Setup & Deployment Helper Scripts

This directory contains helper scripts for setting up, testing, and deploying the Helpdesk Automation System.

## PowerShell Scripts

### 1. setup-local.ps1 - Complete Local Setup
Automates database setup, configuration, and initial build.

```powershell
# Usage:
.\setup-local.ps1 -DBUsername "postgres" -DBPassword "your_password"

# What it does:
# - Creates PostgreSQL database
# - Runs schema.sql
# - Runs init_data.sql
# - Updates application-properties.yml with credentials
# - Builds Maven project
# - Runs tests (if any)
```

**Script content:**
```powershell
param(
    [string]$DBUsername = "postgres",
    [string]$DBPassword = "your_password",
    [string]$DBHost = "localhost",
    [string]$DBPort = "5432",
    [string]$DBName = "helpdeskdb"
)

Write-Host "=== Helpdesk Automation System - Local Setup ===" -ForegroundColor Green

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check Java
try {
    $javaVersion = java -version 2>&1
    Write-Host "✓ Java found: $($javaVersion[0])" -ForegroundColor Green
} catch {
    Write-Host "✗ Java not found. Please install Java JDK 11+" -ForegroundColor Red
    exit 1
}

# Check Maven
try {
    $mvnVersion = mvn -v 2>&1 | Select-Object -First 1
    Write-Host "✓ Maven found: $mvnVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Maven not found. Please install Maven" -ForegroundColor Red
    exit 1
}

# Check PostgreSQL
try {
    $psqlVersion = psql --version 2>&1
    Write-Host "✓ PostgreSQL found: $psqlVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ PostgreSQL not found. Please install PostgreSQL" -ForegroundColor Red
    exit 1
}

# Create database
Write-Host "`nCreating database..." -ForegroundColor Yellow
psql -U $DBUsername -h $DBHost -p $DBPort -c "CREATE DATABASE $DBName;" 2>$null
Write-Host "✓ Database created" -ForegroundColor Green

# Run schema
Write-Host "Initializing schema..." -ForegroundColor Yellow
psql -U $DBUsername -h $DBHost -p $DBPort -d $DBName -f ".\database\schema.sql" | Out-Null
Write-Host "✓ Schema initialized" -ForegroundColor Green

# Run init data
Write-Host "Loading sample data..." -ForegroundColor Yellow
psql -U $DBUsername -h $DBHost -p $DBPort -d $DBName -f ".\database\init_data.sql" | Out-Null
Write-Host "✓ Sample data loaded" -ForegroundColor Green

# Update configuration
Write-Host "Updating configuration..." -ForegroundColor Yellow
$configPath = ".\backend\src\main\resources\application-properties.yml"
$config = @"
spring:
  datasource:
    url: jdbc:postgresql://$DBHost`:$DBPort/$DBName
    username: $DBUsername
    password: $DBPassword
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
server:
  port: 8080
"@
$config | Out-File -FilePath $configPath -Encoding utf8
Write-Host "✓ Configuration updated" -ForegroundColor Green

# Build Maven project
Write-Host "Building backend..." -ForegroundColor Yellow
Push-Location .\backend
mvn clean package -q
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Backend built successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Build failed" -ForegroundColor Red
    Pop-Location
    exit 1
}
Pop-Location

Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
Write-Host "Next: cd .\backend && mvn spring-boot:run" -ForegroundColor Cyan
```

---

### 2. run-local.ps1 - Start Local Application
Starts the Spring Boot application.

```powershell
# Usage:
.\run-local.ps1

# What it does:
# - Verifies database connection
# - Starts Spring Boot application on port 8080
```

**Script content:**
```powershell
Write-Host "=== Starting Helpdesk Automation System ===" -ForegroundColor Green

# Check if database is running
Write-Host "Checking database connection..." -ForegroundColor Yellow
try {
    psql -U postgres -c "SELECT 1;" -q 2>$null
    Write-Host "✓ Database is accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ Cannot connect to database. Is PostgreSQL running?" -ForegroundColor Red
    exit 1
}

# Start application
Write-Host "Starting Spring Boot application..." -ForegroundColor Yellow
Push-Location .\backend
mvn spring-boot:run
Pop-Location
```

---

### 3. test-endpoints.ps1 - Test API Endpoints
Tests all REST endpoints with sample data.

```powershell
# Usage:
.\test-endpoints.ps1 -BaseUrl "http://localhost:8080"

# What it does:
# - Tests GET /tickets/1 (should 404 initially)
# - Creates a new ticket via POST /tickets
# - Retrieves the created ticket
# - Reports results
```

**Script content:**
```powershell
param(
    [string]$BaseUrl = "http://localhost:8080"
)

Write-Host "=== Testing API Endpoints ===" -ForegroundColor Green
Write-Host "Base URL: $BaseUrl`n" -ForegroundColor Cyan

# Test Create Ticket
Write-Host "TEST 1: Create Ticket (POST /tickets)" -ForegroundColor Yellow
$createBody = @{
    userId = 101
    category = "network"
    description = "Test ticket - cannot connect to VPN"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/tickets" `
        -Method Post `
        -ContentType 'application/json' `
        -Body $createBody
    
    Write-Host "✓ Ticket created successfully" -ForegroundColor Green
    Write-Host "  Ticket ID: $($response.ticketId)" -ForegroundColor Cyan
    Write-Host "  Status: $($response.status)" -ForegroundColor Cyan
    Write-Host "  Agent ID: $($response.assignedAgentId)" -ForegroundColor Cyan
    
    $ticketId = $response.ticketId
} catch {
    Write-Host "✗ Failed to create ticket: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test Get Ticket
Write-Host "`nTEST 2: Get Ticket (GET /tickets/$ticketId)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/tickets/$ticketId" -Method Get
    Write-Host "✓ Ticket retrieved successfully" -ForegroundColor Green
    Write-Host "  Description: $($response.description)" -ForegroundColor Cyan
    Write-Host "  Created At: $($response.createdAt)" -ForegroundColor Cyan
    Write-Host "  SLA Due At: $($response.slaDueAt)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Failed to retrieve ticket: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== All Tests Passed ===" -ForegroundColor Green
```

---

### 4. build-and-package.ps1 - Build Production JAR
Creates optimized JAR for deployment.

```powershell
# Usage:
.\build-and-package.ps1 -Output "..\helpdesk-app.jar"

# What it does:
# - Cleans previous builds
# - Runs full Maven build (skips tests)
# - Copies JAR to output directory
```

**Script content:**
```powershell
param(
    [string]$Output = ".\backend\target\helpdesk-backend-0.0.1-SNAPSHOT.jar"
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
    }
} else {
    Write-Host "✗ Build failed" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location
```

---

### 5. create-deployment-package.ps1 - Create Zip for Distribution
Packages entire project for sharing/backup.

```powershell
# Usage:
.\create-deployment-package.ps1 -OutputPath "..\helpdesk-automation-system.zip"

# What it does:
# - Cleans build artifacts
# - Creates zip file with all source code
# - Reports file size
```

**Script content:**
```powershell
param(
    [string]$OutputPath = "..\helpdesk-automation-system.zip"
)

Write-Host "=== Creating Deployment Package ===" -ForegroundColor Green

# Clean build artifacts
Write-Host "Cleaning build artifacts..." -ForegroundColor Yellow
Remove-Item -Path ".\backend\target" -Recurse -Force -ErrorAction SilentlyContinue

# Create zip
Write-Host "Creating zip file..." -ForegroundColor Yellow
Compress-Archive -Path "." -DestinationPath $OutputPath -Force

$zipSize = (Get-Item $OutputPath).Length / 1MB
Write-Host "✓ Package created: $OutputPath ($([Math]::Round($zipSize, 2)) MB)" -ForegroundColor Green
```

---

### 6. push-to-github.ps1 - Push to GitHub
Initializes Git and pushes to GitHub repository.

```powershell
# Usage:
.\push-to-github.ps1 -RepoUrl "https://github.com/username/helpdesk-automation-system.git"

# What it does:
# - Initializes git repository
# - Creates initial commit
# - Sets remote origin
# - Pushes to main branch
```

**Script content:**
```powershell
param(
    [string]$RepoUrl = "",
    [string]$Branch = "main"
)

if ([string]::IsNullOrEmpty($RepoUrl)) {
    Write-Host "✗ RepoUrl parameter is required" -ForegroundColor Red
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
} else {
    Write-Host "Git repository already initialized" -ForegroundColor Yellow
}

# Add remote and push
Write-Host "Setting remote origin..." -ForegroundColor Yellow
git remote add origin $RepoUrl -ErrorAction SilentlyContinue
git branch -M $Branch

Write-Host "Pushing to $RepoUrl..." -ForegroundColor Yellow
git push -u origin $Branch

Write-Host "✓ Repository pushed successfully" -ForegroundColor Green
Write-Host "URL: $RepoUrl" -ForegroundColor Cyan
```

---

## Usage Examples

### Complete Local Setup
```powershell
# 1. Run setup
.\setup-local.ps1 -DBPassword "your_secure_password"

# 2. Start application
.\run-local.ps1

# In another PowerShell window:

# 3. Test endpoints
.\test-endpoints.ps1

# 4. Build production JAR
.\build-and-package.ps1
```

### Deploy to AWS
```powershell
# 1. Build JAR
.\build-and-package.ps1 -Output ".\helpdesk-app.jar"

# 2. Upload to S3
aws s3 cp .\helpdesk-app.jar s3://your-bucket/helpdesk-app.jar

# 3. Deploy with CloudFormation
aws cloudformation create-stack `
  --stack-name helpdesk-stack `
  --template-body file://deployment/aws/cloudformation-template.yml
```

### Share via GitHub
```powershell
# 1. Create deployment package
.\create-deployment-package.ps1

# 2. Push to GitHub
.\push-to-github.ps1 -RepoUrl "https://github.com/your-username/helpdesk-automation-system.git"
```

---

## Bash Scripts (for macOS/Linux)

### setup-local.sh
```bash
#!/bin/bash

DB_USERNAME="${1:-postgres}"
DB_PASSWORD="${2:-your_password}"
DB_HOST="${3:-localhost}"
DB_PORT="${4:-5432}"
DB_NAME="helpdeskdb"

echo "=== Helpdesk Automation System - Local Setup ==="

# Check prerequisites
echo "Checking prerequisites..."
java -version 2>/dev/null || { echo "✗ Java not found"; exit 1; }
mvn -v 2>/dev/null | head -1 || { echo "✗ Maven not found"; exit 1; }
psql --version 2>/dev/null || { echo "✗ PostgreSQL not found"; exit 1; }

# Create database
echo -e "\nCreating database..."
psql -U $DB_USERNAME -h $DB_HOST -p $DB_PORT -c "CREATE DATABASE $DB_NAME;" 2>/dev/null

# Run schema
echo "Initializing schema..."
psql -U $DB_USERNAME -h $DB_HOST -p $DB_PORT -d $DB_NAME -f ./database/schema.sql > /dev/null

# Run init data
echo "Loading sample data..."
psql -U $DB_USERNAME -h $DB_HOST -p $DB_PORT -d $DB_NAME -f ./database/init_data.sql > /dev/null

# Update configuration
echo "Updating configuration..."
cat > ./backend/src/main/resources/application-properties.yml << EOF
spring:
  datasource:
    url: jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME
    username: $DB_USERNAME
    password: $DB_PASSWORD
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
server:
  port: 8080
EOF

# Build
echo "Building backend..."
cd backend
mvn clean package -q && echo "✓ Backend built successfully" || { echo "✗ Build failed"; exit 1; }
cd ..

echo -e "\n=== Setup Complete ==="
echo "Next: cd backend && mvn spring-boot:run"
```

---

## GitHub Actions CI/CD (Optional)

Create `.github/workflows/ci.yml`:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v2
      
      - name: Set up JDK 11
        uses: actions/setup-java@v2
        with:
          java-version: '11'
      
      - name: Build with Maven
        run: cd backend && mvn clean package
      
      - name: Upload JAR
        uses: actions/upload-artifact@v2
        with:
          name: helpdesk-backend
          path: backend/target/*.jar
```

---

## Troubleshooting

| Error | Solution |
|-------|----------|
| `psql: command not found` | Install PostgreSQL and add to PATH |
| `mvn: command not found` | Install Maven and add to PATH |
| `java: command not found` | Install Java JDK 11+ |
| Connection refused (DB) | Ensure PostgreSQL service is running |
| Port 8080 in use | Kill process: `netstat -ano \| findstr :8080` |

---

For more details, see the main README.md and individual component documentation.
