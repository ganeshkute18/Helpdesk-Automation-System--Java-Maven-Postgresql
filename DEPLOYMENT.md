# Deployment & Release Guide

Complete guide for packaging, sharing, and deploying the Helpdesk Automation System.

---

## Part 1: Create Deployment Package (ZIP)

### Option A: Using PowerShell Script (Recommended)
```powershell
.\create-deployment-package.ps1 -OutputPath "..\helpdesk-automation-system.zip"
```

This will:
- Clean build artifacts and temporary files
- Create a zip file (~20 MB)
- Clean up unnecessary folders (.git, .idea, target)

**Output:** `helpdesk-automation-system.zip`

### Option B: Manual PowerShell Command
```powershell
# Clean build artifacts first
Remove-Item -Path ".\backend\target" -Recurse -Force -ErrorAction SilentlyContinue

# Create zip file
Compress-Archive -Path "." -DestinationPath "..\helpdesk-automation-system.zip" -Force

# Verify size
Get-Item "..\helpdesk-automation-system.zip" | Format-List Length
```

### Option C: Manual File Explorer
1. Right-click `helpdesk-automation-system` folder
2. Select "Send to" → "Compressed (zipped) folder"
3. Rename to `helpdesk-automation-system.zip`

---

## Part 2: Push to GitHub

### Prerequisites
- GitHub account
- Git installed
- Repository created on GitHub (empty)

### Option A: Using PowerShell Script (Recommended)
```powershell
.\push-to-github.ps1 -RepoUrl "https://github.com/your-username/helpdesk-automation-system.git"
```

This will:
- Initialize git repository (if not exists)
- Stage all files
- Create initial commit
- Push to GitHub main branch

### Option B: Manual Git Commands
```powershell
# Initialize git
git init
git add .
git commit -m "Initial commit: helpdesk automation system"

# Add remote
git remote add origin https://github.com/your-username/helpdesk-automation-system.git

# Push to main branch
git branch -M main
git push -u origin main
```

### Option C: Using GitHub CLI
```powershell
# Create repository
gh repo create helpdesk-automation-system --source=. --remote=origin --push
```

---

## Part 3: Complete Setup on Fresh Machine

### Step 1: Extract ZIP
```powershell
Expand-Archive -Path ".\helpdesk-automation-system.zip" -DestinationPath ".\"
cd .\helpdesk-automation-system
```

### Step 2: Run Automated Setup
```powershell
# Run setup script with your database password
.\setup-local.ps1 -DBPassword "your_secure_password"
```

**What it does automatically:**
- ✓ Verifies Java, Maven, PostgreSQL are installed
- ✓ Creates PostgreSQL database
- ✓ Runs schema.sql to create tables
- ✓ Runs init_data.sql to load sample data
- ✓ Updates application-properties.yml with credentials
- ✓ Builds Maven project
- ✓ Reports success and next steps

### Step 3: Start Application
```powershell
cd .\backend
mvn spring-boot:run
```

The application will start on `http://localhost:8080`

### Step 4: Test Endpoints (In New PowerShell Window)
```powershell
# From project root
.\test-endpoints.ps1

# Expected output:
# ✓ Ticket created successfully
# ✓ Ticket retrieved successfully
# ✓ All Tests Completed
```

---

## Part 4: Build Production JAR

### Option A: Using PowerShell Script
```powershell
.\build-and-package.ps1 -Output ".\helpdesk-app.jar"
```

Creates: `helpdesk-app.jar` (~50 MB)

### Option B: Manual Maven Build
```powershell
cd .\backend
mvn clean package -DskipTests

# JAR file location:
# .\target\helpdesk-backend-0.0.1-SNAPSHOT.jar
```

### Option C: Run JAR Directly
```powershell
java -jar helpdesk-app.jar
```

---

## Part 5: Deploy to AWS

### Prerequisites
- AWS Account with CLI configured
- CloudFormation permissions
- Production JAR file

### Step 1: Upload JAR to S3
```powershell
# Create S3 bucket (one-time)
aws s3 mb s3://helpdesk-artifacts-$(Get-Random)

# Upload JAR
aws s3 cp .\helpdesk-app.jar `
  s3://helpdesk-artifacts-12345/helpdesk-app.jar
```

### Step 2: Deploy CloudFormation Stack
```powershell
# Deploy stack
aws cloudformation create-stack `
  --stack-name helpdesk-automation-prod `
  --template-body file://deployment/aws/cloudformation-template.yml `
  --parameters `
    ParameterKey=ApplicationJarUrl,ParameterValue=s3://helpdesk-artifacts-12345/helpdesk-app.jar `
    ParameterKey=DBUsername,ParameterValue=admin `
    ParameterKey=DBPassword,ParameterValue=YourSecurePassword123! `
    ParameterKey=EnvironmentName,ParameterValue=production `
  --capabilities CAPABILITY_IAM

# Wait for stack creation
aws cloudformation wait stack-create-complete `
  --stack-name helpdesk-automation-prod

# Get ALB DNS name
aws cloudformation describe-stacks `
  --stack-name helpdesk-automation-prod `
  --query 'Stacks[0].Outputs[?OutputKey==`LoadBalancerDNS`].OutputValue' `
  --output text
```

### Step 3: Test Production Deployment
```powershell
$albDns = "helpdesk-alb-123456.us-east-1.elb.amazonaws.com"

# Create ticket
$body = @{
    userId = 101
    category = "network"
    description = "Production test"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://$albDns/tickets" `
  -Method Post `
  -ContentType 'application/json' `
  -Body $body
```

---

## Part 6: Share & Backup

### Share ZIP File
```powershell
# Share via cloud storage
Copy-Item ".\helpdesk-automation-system.zip" -Destination "C:\OneDrive\Shared"

# Or upload to S3
aws s3 cp .\helpdesk-automation-system.zip s3://my-backup-bucket/
```

### Create Backup
```powershell
# Create timestamped backup
$date = Get-Date -Format "yyyy-MM-dd-HHmmss"
Copy-Item ".\helpdesk-automation-system.zip" `
  -Destination ".\helpdesk-automation-system-backup-$date.zip"
```

### Push to GitHub (Alternative to ZIP)
```powershell
.\push-to-github.ps1 -RepoUrl "https://github.com/your-username/helpdesk-automation-system.git"

# Repository will include full history, branches, and all source code
```

---

## Complete Workflow Examples

### Scenario 1: Development Team Setup
```powershell
# Team lead creates ZIP and pushes to GitHub
.\create-deployment-package.ps1
.\push-to-github.ps1 -RepoUrl "https://github.com/myteam/helpdesk-automation-system.git"

# Team member clones and runs locally
git clone https://github.com/myteam/helpdesk-automation-system.git
cd helpdesk-automation-system
.\setup-local.ps1 -DBPassword "dev_password"
cd backend
mvn spring-boot:run
```

### Scenario 2: Production Deployment
```powershell
# Build production JAR
.\build-and-package.ps1 -Output ".\helpdesk-prod.jar"

# Upload to AWS
aws s3 cp .\helpdesk-prod.jar s3://prod-artifacts/helpdesk-app.jar

# Deploy via CloudFormation
aws cloudformation create-stack `
  --stack-name helpdesk-prod `
  --template-body file://deployment/aws/cloudformation-template.yml `
  --parameters ParameterKey=ApplicationJarUrl,ParameterValue=s3://prod-artifacts/helpdesk-app.jar `
  --capabilities CAPABILITY_IAM

# Monitor deployment
aws cloudformation describe-stacks --stack-name helpdesk-prod
```

### Scenario 3: Client Delivery
```powershell
# Create clean ZIP for delivery
.\create-deployment-package.ps1 -OutputPath "..\helpdesk-automation-system-v1.0.zip"

# Include setup instructions
Add-Content ".\INSTALL.txt" -Value @"
INSTALLATION INSTRUCTIONS
1. Extract ZIP
2. Run: .\setup-local.ps1
3. Run: cd .\backend && mvn spring-boot:run
4. Access: http://localhost:8080
"@

# Share both files with client
```

---

## Troubleshooting Deployment

| Issue | Solution |
|-------|----------|
| ZIP file too large | Run `.\create-deployment-package.ps1` to clean artifacts first |
| Git push fails | Check credentials: `git config --global user.name` |
| CloudFormation stack fails | Check CloudWatch logs for EC2 instance errors |
| Database connection in prod | Verify RDS security group allows EC2 access |
| Application won't start | Check `application-properties.yml` for correct DB URL |

---

## Checklist Before Deployment

- [ ] All source code committed to git
- [ ] Database scripts tested locally
- [ ] Maven build passes with no errors
- [ ] Application runs on localhost:8080
- [ ] API endpoints tested successfully
- [ ] Configuration updated for target environment
- [ ] Production JAR created and tested
- [ ] CloudFormation template reviewed
- [ ] AWS credentials configured
- [ ] S3 bucket prepared for artifacts
- [ ] Documentation updated
- [ ] Security review completed (passwords, keys)

---

## File Structure for Delivery

```
helpdesk-automation-system/
├── README.md                          # Start here
├── SETUP_SCRIPTS.md                   # Script documentation
├── DEPLOYMENT.md                      # This file
├── setup-local.ps1                    # Automated setup
├── test-endpoints.ps1                 # API testing
├── build-and-package.ps1              # JAR builder
├── create-deployment-package.ps1      # ZIP creator
├── push-to-github.ps1                 # GitHub uploader
├── backend/
│   ├── pom.xml
│   ├── README.md
│   └── src/main/java/...
├── database/
│   ├── schema.sql
│   └── init_data.sql
├── docs/
│   ├── architecture.md
│   ├── usage.md
├── deployment/aws/
│   ├── cloudformation-template.yml
│   └── readme-aws.md
└── .gitignore
```

---

## Support & Documentation

- **Getting Started:** See `README.md`
- **Local Setup:** Run `.\setup-local.ps1`
- **API Reference:** See `docs/usage.md`
- **Architecture:** See `docs/architecture.md`
- **AWS Deployment:** See `deployment/aws/readme-aws.md`
- **Script Help:** See `SETUP_SCRIPTS.md`

---

## Quick Commands Reference

```powershell
# Setup
.\setup-local.ps1 -DBPassword "your_password"

# Run
cd .\backend; mvn spring-boot:run

# Test
.\test-endpoints.ps1

# Build JAR
.\build-and-package.ps1

# Create ZIP
.\create-deployment-package.ps1

# Push to GitHub
.\push-to-github.ps1 -RepoUrl "https://github.com/you/repo.git"

# Deploy to AWS
aws cloudformation create-stack --stack-name helpdesk-prod `
  --template-body file://deployment/aws/cloudformation-template.yml `
  --capabilities CAPABILITY_IAM
```

---

**Last Updated:** November 11, 2025  
**Version:** 1.0
