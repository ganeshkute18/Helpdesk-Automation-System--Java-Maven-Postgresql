# Helpdesk Automation System

Built by Ganesh  
**Stack:** Java 11 (Spring Boot 2.7.5), PostgreSQL, AWS (CloudFormation), Maven

## Overview

A Spring Boot microservice for automating IT support ticket intake, intelligent agent assignment, and SLA tracking. The system auto-assigns tickets to available agents based on skillset and manages SLA deadlines.

**Key Features:**
- ✅ REST API for ticket creation and retrieval
- ✅ Automatic agent assignment based on skillset
- ✅ SLA tracking (24-hour default)
- ✅ PostgreSQL persistence
- ✅ AWS CloudFormation deployment
- ✅ Load balancing and auto-scaling ready

---

## Quick Start (5 minutes)

### Prerequisites
- Java JDK 11+
- Maven 3.6+
- PostgreSQL 12+
- Git

### 1. Clone or download repository
```bash
git clone <repo-url>
cd helpdesk-automation-system
```

### 2. Setup Database (PowerShell)
```powershell
# Create database
psql -U postgres -c "CREATE DATABASE helpdeskdb;"

# Initialize schema and sample data
psql -U postgres -d helpdeskdb -f ".\database\schema.sql"
psql -U postgres -d helpdeskdb -f ".\database\init_data.sql"
```

### 3. Configure Application
Edit `backend/src/main/resources/application-properties.yml`:
```yaml
spring:
  datasource:
    username: postgres              # ← Your DB username
    password: your_password         # ← Your DB password
```

### 4. Build & Run (PowerShell)
```powershell
cd .\backend
mvn clean package
mvn spring-boot:run
```

Service starts on `http://localhost:8080` ✅

### 5. Test Endpoints (PowerShell)
```powershell
# Create ticket
$body = @{
    userId = 101
    category = "network"
    description = "VPN timeout"
} | ConvertTo-Json

Invoke-RestMethod -Uri http://localhost:8080/tickets `
  -Method Post -ContentType 'application/json' -Body $body

# Get ticket
Invoke-RestMethod -Uri http://localhost:8080/tickets/1
```

---

## Repository Structure

```
helpdesk-automation-system/
├── README.md                              # This file
├── .gitignore                             # Git ignore rules
├── backend/                               # Spring Boot application
│   ├── pom.xml                            # Maven dependencies
│   ├── README.md                          # Backend-specific docs
│   └── src/
│       ├── main/
│       │   ├── java/com/ganesh/helpdesk/
│       │   │   ├── HelpdeskApplication.java    # Entry point
│       │   │   ├── controller/
│       │   │   │   └── TicketController.java   # REST endpoints
│       │   │   ├── service/
│       │   │   │   └── TicketService.java      # Business logic
│       │   │   ├── repository/                 # Data layer
│       │   │   └── model/                      # Entities & DTOs
│       │   └── resources/
│       │       └── application-properties.yml  # Configuration
│       └── test/
├── database/                              # Database scripts
│   ├── schema.sql                         # Table definitions
│   └── init_data.sql                      # Sample data
├── docs/                                  # Documentation
│   ├── architecture.md                    # System design
│   └── usage.md                           # API usage guide
└── deployment/                            # Cloud deployment
    └── aws/
        ├── cloudformation-template.yml    # IaC template
        └── readme-aws.md                  # AWS deployment guide
```

---

## REST API Endpoints

### Create Ticket
```
POST /tickets
Content-Type: application/json

Request:
{
  "userId": 101,
  "category": "network",
  "description": "Cannot connect to VPN"
}

Response (201):
{
  "ticketId": 1,
  "userId": 101,
  "category": "network",
  "description": "Cannot connect to VPN",
  "status": "Open",
  "createdAt": "2025-11-11T10:30:00",
  "slaDueAt": "2025-11-12T10:30:00",
  "assignedAgentId": 1
}
```

### Get Ticket
```
GET /tickets/{id}

Response (200):
{
  "ticketId": 1,
  ...
}
```

---

## Architecture

**Components:**
- **Controller:** REST API endpoints
- **Service:** Business logic & agent assignment
- **Repository:** JPA data access layer
- **Model:** Ticket and Agent entities

**Database:**
- PostgreSQL with agents and tickets tables
- Foreign key relationships
- Indexed queries for performance

**Agent Categories:** network, software, hardware, database, security

For detailed architecture, see `docs/architecture.md`

---

## Configuration

### Application Settings
**File:** `backend/src/main/resources/application-properties.yml`

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/helpdeskdb
    username: postgres
    password: your_password
  jpa:
    hibernate:
      ddl-auto: update              # Change to 'validate' for production
    show-sql: true
server:
  port: 8080
```

**Options:**
- `ddl-auto: update` — Auto-create schema (dev only)
- `ddl-auto: validate` — Validate schema exists (production)
- `show-sql: true` — Log SQL queries

### Database Credentials
Set via environment variables or config file. For production, use AWS Secrets Manager.

---

## Development Workflow

### Build
```bash
cd backend
mvn clean package          # Creates JAR
```

### Run Locally
```bash
mvn spring-boot:run        # Runs with Spring Boot embedded server
```

### Run JAR
```bash
java -jar target/helpdesk-backend-0.0.1-SNAPSHOT.jar
```

### Testing
```powershell
# Test via PowerShell
Invoke-RestMethod -Uri http://localhost:8080/tickets/1

# Test via cURL (Git Bash / WSL)
curl -X GET http://localhost:8080/tickets/1
```

---

## Deployment

### Local Development
See **Quick Start** above.

### AWS Production
See `deployment/aws/readme-aws.md` for:
- CloudFormation template
- RDS PostgreSQL setup
- EC2 Auto Scaling
- Application Load Balancer
- Cost optimization

**Deploy with:**
```powershell
aws cloudformation create-stack --stack-name helpdesk-stack `
  --template-body file://deployment/aws/cloudformation-template.yml
```

---

## Troubleshooting

### Database Connection Error
```
PSQLException: Connection to localhost:5432 refused
```
**Fix:** Start PostgreSQL service
```powershell
Restart-Service PostgreSQL-x64-15  # Windows
brew services start postgresql@15   # macOS
sudo systemctl start postgresql     # Linux
```

### Port 8080 Already in Use
**Fix:** Change port in `application-properties.yml` or kill process
```powershell
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

### Maven Not Found
```powershell
mvn -v
# If not found, add to PATH or use full path
```

### "No agent available" Error
**Fix:** Ensure agents exist with matching skillset
```sql
SELECT * FROM agents WHERE is_active = true;
```

See `docs/usage.md` for more troubleshooting.

---

## File Upload & Sharing

### Create Deployment Package
```powershell
# Zip entire project
Compress-Archive -Path .\helpdesk-automation-system -DestinationPath .\helpdesk-automation-system.zip

# Size: ~10-20 MB (includes source, docs, config)
```

### Push to GitHub
```powershell
cd .\helpdesk-automation-system
git init
git add .
git commit -m "Initial: helpdesk automation system"
git branch -M main
git remote add origin https://github.com/<username>/helpdesk-automation-system.git
git push -u origin main
```

---

## Next Steps

1. **Extend API:** Add PUT/DELETE endpoints, pagination, filtering
2. **Add Security:** Implement OAuth2, JWT authentication
3. **Add Logging:** Integrate SLF4J/Logback for production
4. **Add Tests:** Write unit tests with JUnit 5, integration tests
5. **Add Monitoring:** CloudWatch dashboards, alarms
6. **Add CI/CD:** GitHub Actions, AWS CodePipeline

---

## Documentation

- 📄 `docs/architecture.md` — System design & components
- 📄 `docs/usage.md` — API guide with cURL/PowerShell examples
- 📄 `backend/README.md` — Backend-specific development guide
- 📄 `deployment/aws/readme-aws.md` — AWS CloudFormation deployment

---

## Technology Stack

| Component     | Technology       | Version   |
|---------------|------------------|-----------|
| Language      | Java             | 11+       |
| Framework     | Spring Boot      | 2.7.5     |
| ORM           | Spring Data JPA  | Latest    |
| Database      | PostgreSQL       | 12+       |
| Build Tool    | Maven            | 3.6+      |
| Cloud         | AWS              | -         |
| IaC           | CloudFormation   | -         |

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit changes (`git commit -am 'Add feature'`)
4. Push to branch (`git push origin feature/your-feature`)
5. Open a Pull Request

---

## License

MIT License — See LICENSE file for details

---

## Support

For issues, questions, or suggestions, open an issue on GitHub or contact the development team.

**Built with ❤️ for IT support automation**
