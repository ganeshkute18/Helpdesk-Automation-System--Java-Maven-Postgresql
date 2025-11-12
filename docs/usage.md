# Usage Guide

## Quick Start

### Prerequisites
- Java JDK 11 or later
- Maven 3.6+
- PostgreSQL 12+ (or compatible database)
- VS Code with Java/Maven extensions (optional but recommended)

### 1. Database Setup

#### Windows PowerShell
```powershell
# Create database
psql -U postgres -c "CREATE DATABASE helpdeskdb;"

# Initialize schema
psql -U postgres -d helpdeskdb -f ".\database\schema.sql"

# Load sample data
psql -U postgres -d helpdeskdb -f ".\database\init_data.sql"
```

#### macOS/Linux
```bash
# Create database
psql -U postgres -c "CREATE DATABASE helpdeskdb;"

# Initialize schema
psql -U postgres -d helpdeskdb -f "./database/schema.sql"

# Load sample data
psql -U postgres -d helpdeskdb -f "./database/init_data.sql"
```

### 2. Configure Application

Edit `backend/src/main/resources/application-properties.yml`:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/helpdeskdb
    username: postgres          # ← Update with your username
    password: your_password     # ← Update with your password
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
server:
  port: 8080
```

### 3. Build Backend

```powershell
cd .\backend
mvn clean package
```

Expected output ends with:
```
[INFO] BUILD SUCCESS
[INFO] Total time: XX.XXXs
```

### 4. Run Backend

```powershell
# From backend folder
mvn spring-boot:run
```

Expected output:
```
Started HelpdeskApplication in X.XXXs
```

The service is now running on `http://localhost:8080`

---

## API Endpoints

### Create Ticket
**POST** `/tickets`

Request:
```json
{
  "userId": 101,
  "category": "network",
  "description": "Cannot connect to company WiFi"
}
```

Response (201 Created):
```json
{
  "ticketId": 1,
  "userId": 101,
  "category": "network",
  "description": "Cannot connect to company WiFi",
  "status": "Open",
  "createdAt": "2025-11-11T10:30:00",
  "slaDueAt": "2025-11-12T10:30:00",
  "assignedAgentId": 1
}
```

### Get Ticket
**GET** `/tickets/{id}`

Example: `GET /tickets/1`

Response (200 OK):
```json
{
  "ticketId": 1,
  "userId": 101,
  "category": "network",
  "description": "Cannot connect to company WiFi",
  "status": "Open",
  "createdAt": "2025-11-11T10:30:00",
  "slaDueAt": "2025-11-12T10:30:00",
  "assignedAgentId": 1
}
```

---

## Testing with PowerShell

### Test Create Ticket
```powershell
$body = @{
    userId = 101
    category = "network"
    description = "VPN connection timeout"
} | ConvertTo-Json

Invoke-RestMethod -Uri http://localhost:8080/tickets `
  -Method Post `
  -ContentType 'application/json' `
  -Body $body
```

### Test Get Ticket
```powershell
Invoke-RestMethod -Uri http://localhost:8080/tickets/1 -Method Get
```

---

## Testing with cURL

### Create Ticket
```bash
curl -X POST http://localhost:8080/tickets \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 102,
    "category": "software",
    "description": "Application crashes on startup"
  }'
```

### Get Ticket
```bash
curl -X GET http://localhost:8080/tickets/1
```

---

## Troubleshooting

### Issue: Connection refused (database)
**Solution:** Ensure PostgreSQL is running
```powershell
# Windows
Restart-Service PostgreSQL-x64-15  # or your version

# macOS
brew services start postgresql@15

# Linux
sudo systemctl start postgresql
```

### Issue: Maven command not found
**Solution:** Add Maven to PATH or use full path
```powershell
# Check Maven installation
mvn --version

# If not in PATH, add it:
$env:PATH += ";C:\Program Files\Apache\maven-3.9.0\bin"
```

### Issue: Port 8080 already in use
**Solution:** Change port in `application-properties.yml`
```yaml
server:
  port: 9090  # Use different port
```

### Issue: "No agent available" error
**Solution:** Ensure sample data is loaded and agent skillset matches category
```sql
-- Check agents
SELECT * FROM agents WHERE is_active = true;

-- Available skillsets: network, software, hardware, database, security
```

---

## Sample Agent Categories

Based on `init_data.sql`, available categories for auto-assignment:
- **network** → Alice Johnson (Agent 1)
- **software** → Bob Smith (Agent 2)
- **hardware** → Charlie Brown (Agent 3)
- **database** → Diana Prince (Agent 4)
- **security** → Eve Wilson (Agent 5)

---

## Next Steps
- Review `docs/architecture.md` for system design details
- Check `deployment/aws/readme-aws.md` for cloud deployment
- Extend TicketService with additional business logic (priority, escalation, etc.)
- Add more endpoints (update, delete, list all tickets)
- Implement authentication/authorization
