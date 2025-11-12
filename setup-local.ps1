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
    Write-Host "[OK] Java found" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Java not found. Please install Java JDK 11+" -ForegroundColor Red
    exit 1
}

# Check Maven
try {
    $mvnVersion = mvn -v 2>&1 | Select-Object -First 1
    Write-Host "[OK] Maven found" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Maven not found. Please install Maven" -ForegroundColor Red
    exit 1
}

# Check PostgreSQL
try {
    $psqlVersion = psql --version 2>&1
    Write-Host "[OK] PostgreSQL found" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] PostgreSQL not found. Please install PostgreSQL" -ForegroundColor Red
    exit 1
}

# Create database
Write-Host "`nCreating database '$DBName'..." -ForegroundColor Yellow
psql -U $DBUsername -h $DBHost -p $DBPort -c "CREATE DATABASE $DBName;" 2>$null
Write-Host "[OK] Database created" -ForegroundColor Green

# Run schema
Write-Host "Initializing schema..." -ForegroundColor Yellow
psql -U $DBUsername -h $DBHost -p $DBPort -d $DBName -f ".\database\schema.sql" 2>$null
Write-Host "[OK] Schema initialized" -ForegroundColor Green

# Run init data
Write-Host "Loading sample data..." -ForegroundColor Yellow
psql -U $DBUsername -h $DBHost -p $DBPort -d $DBName -f ".\database\init_data.sql" 2>$null
Write-Host "[OK] Sample data loaded" -ForegroundColor Green

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
Write-Host "[OK] Configuration updated" -ForegroundColor Green

# Build Maven project
Write-Host "`nBuilding backend..." -ForegroundColor Yellow
Push-Location .\backend
mvn clean package -q
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Backend built successfully" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Build failed" -ForegroundColor Red
    Pop-Location
    exit 1
}
Pop-Location

Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. cd .\backend" -ForegroundColor Cyan
Write-Host "  2. mvn spring-boot:run" -ForegroundColor Cyan
Write-Host "`nApplication will run on http://localhost:8080" -ForegroundColor Cyan
