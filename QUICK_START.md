# QUICK START - 5 Minutes to Running Application

## 🎯 Goal
Get the Helpdesk Automation System running locally in 5 minutes.

---

## Prerequisites (Install if missing)
- ✅ **Java JDK 11+** — [Download](https://www.oracle.com/java/technologies/downloads/)
- ✅ **Maven 3.6+** — [Download](https://maven.apache.org/download.cgi)
- ✅ **PostgreSQL 12+** — [Download](https://www.postgresql.org/download/)

**Verify installed (PowerShell):**
```powershell
java -version
mvn -v
psql --version
```

---

## Step 1: Automated Setup (2 minutes)

Run the setup script:
```powershell
.\setup-local.ps1 -DBPassword "your_password"
```

This automatically:
- ✓ Creates PostgreSQL database
- ✓ Initializes schema
- ✓ Loads sample data
- ✓ Builds the application

**Expected output:**
```
=== Setup Complete ===
Next: cd .\backend && mvn spring-boot:run
```

---

## Step 2: Start Application (1 minute)

```powershell
cd .\backend
mvn spring-boot:run
```

Wait for:
```
Started HelpdeskApplication in X.XXs
```

Application is ready on: **http://localhost:8080**

---

## Step 3: Test Endpoints (1 minute)

Open **new PowerShell window** in project root:
```powershell
.\test-endpoints.ps1
```

**Expected output:**
```
TEST 1: Create Ticket (POST /tickets)
✓ Ticket created successfully
  Ticket ID: 1
  Status: Open

TEST 2: Get Ticket (GET /tickets/1)
✓ Ticket retrieved successfully
  Created At: 2025-11-11T10:30:00

=== All Tests Completed ===
```

---

## Step 4: Explore the API (1 minute)

### Create Ticket (PowerShell)
```powershell
$body = @{
    userId = 101
    category = "network"
    description = "Cannot connect to VPN"
} | ConvertTo-Json

Invoke-RestMethod -Uri http://localhost:8080/tickets `
  -Method Post `
  -ContentType 'application/json' `
  -Body $body
```

### Get Ticket (PowerShell)
```powershell
Invoke-RestMethod -Uri http://localhost:8080/tickets/1 -Method Get
```

### cURL (Git Bash / WSL)
```bash
# Create
curl -X POST http://localhost:8080/tickets \
  -H "Content-Type: application/json" \
  -d '{"userId":101,"category":"network","description":"Test"}'

# Get
curl http://localhost:8080/tickets/1
```

---

## Sample Categories

These agents auto-assign based on ticket category:
- **network** → Alice Johnson
- **software** → Bob Smith
- **hardware** → Charlie Brown
- **database** → Diana Prince
- **security** → Eve Wilson

Try creating tickets with different categories!

---

## Troubleshooting

### ❌ "Cannot connect to database"
```powershell
# Restart PostgreSQL service
Restart-Service PostgreSQL-x64-15  # Windows
brew services restart postgresql@15 # macOS
sudo systemctl restart postgresql   # Linux
```

### ❌ "Port 8080 already in use"
Edit `backend\src\main\resources\application-properties.yml`:
```yaml
server:
  port: 9090  # Change to different port
```

### ❌ "Maven command not found"
Add Maven to PATH or use full path:
```powershell
$env:PATH += ";C:\Program Files\Apache\maven-3.9.0\bin"
```

---

## Next Steps

After running locally:

1. **Explore Code** → `backend/src/main/java/com/ganesh/helpdesk/`
2. **Read Docs** → `docs/architecture.md`
3. **API Guide** → `docs/usage.md`
4. **Package** → Run `.\create-deployment-package.ps1`
5. **Deploy to AWS** → See `deployment/aws/readme-aws.md`

---

## Complete File Guide

| File | Purpose |
|------|---------|
| `README.md` | Project overview |
| `QUICK_START.md` | This file (5-min setup) |
| `DEPLOYMENT.md` | Package & deploy guide |
| `SETUP_SCRIPTS.md` | Script documentation |
| `setup-local.ps1` | Automated setup script |
| `test-endpoints.ps1` | API testing script |
| `build-and-package.ps1` | Build production JAR |
| `create-deployment-package.ps1` | Create ZIP file |
| `push-to-github.ps1` | Push to GitHub |

---

## 🚀 You're Ready!

The application is running and ready to use. Have fun building! 

**Questions?** See README.md or docs/ folder.

---

**Time Spent:** ~5 minutes ✅  
**Status:** Ready for development/testing
