# Backend - Helpdesk Automation System

This is the Spring Boot backend service for the Helpdesk Automation System.

## Quick Start

### Prerequisites
- Java JDK 11+
- Maven 3.6+
- PostgreSQL 12+

### Build
```bash
mvn clean package
```

### Run
```bash
mvn spring-boot:run
```

Application will start on `http://localhost:8080`

## Project Structure

```
backend/
├── pom.xml                                    # Maven configuration
├── src/
│   ├── main/
│   │   ├── java/com/ganesh/helpdesk/
│   │   │   ├── HelpdeskApplication.java       # Spring Boot entry point
│   │   │   ├── controller/
│   │   │   │   └── TicketController.java      # REST endpoints
│   │   │   ├── service/
│   │   │   │   └── TicketService.java         # Business logic
│   │   │   ├── repository/
│   │   │   │   ├── TicketRepository.java      # JPA repository
│   │   │   │   └── AgentRepository.java       # JPA repository
│   │   │   └── model/
│   │   │       ├── Ticket.java                # Ticket entity
│   │   │       ├── Agent.java                 # Agent entity
│   │   │       ├── TicketDto.java             # Ticket response DTO
│   │   │       └── CreateTicketRequest.java   # Ticket request DTO
│   │   └── resources/
│   │       └── application-properties.yml     # Configuration
│   └── test/
│       └── java/com/ganesh/helpdesk/          # Unit tests (if added)
└── target/                                    # Build output
```

## Configuration

### Database Configuration
Edit `src/main/resources/application-properties.yml`:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/helpdeskdb
    username: postgres
    password: your_password
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
server:
  port: 8080
```

- `ddl-auto: update` - Automatically creates/updates schema (use `validate` in production)
- `show-sql: true` - Logs SQL queries to console (disable in production)

## REST API

### Create Ticket
```
POST /tickets
Content-Type: application/json

{
  "userId": 101,
  "category": "network",
  "description": "VPN connection timeout"
}
```

**Response (201 Created):**
```json
{
  "ticketId": 1,
  "userId": 101,
  "category": "network",
  "description": "VPN connection timeout",
  "status": "Open",
  "createdAt": "2025-11-11T10:30:00",
  "slaDueAt": "2025-11-12T10:30:00",
  "assignedAgentId": 1
}
```

### Get Ticket
```
GET /tickets/1
```

**Response (200 OK):**
```json
{
  "ticketId": 1,
  "userId": 101,
  "category": "network",
  "description": "VPN connection timeout",
  "status": "Open",
  "createdAt": "2025-11-11T10:30:00",
  "slaDueAt": "2025-11-12T10:30:00",
  "assignedAgentId": 1
}
```

## Dependencies

- **Spring Boot 2.7.5**
  - spring-boot-starter-web: REST API
  - spring-boot-starter-data-jpa: ORM/Database access
  - spring-boot-starter-test: Testing framework

- **PostgreSQL Driver**: For database connectivity

See `pom.xml` for exact versions.

## Building for Production

```bash
# Build optimized JAR (skips tests)
mvn clean package -DskipTests

# JAR file: target/helpdesk-backend-0.0.1-SNAPSHOT.jar
```

## Running JAR Directly

```bash
java -jar target/helpdesk-backend-0.0.1-SNAPSHOT.jar
```

## Extending the Application

### Add a New Endpoint
1. Add method to `TicketController`:
```java
@GetMapping
public ResponseEntity<List<TicketDto>> listTickets() {
    // Implementation
}
```

2. Add repository method if needed:
```java
// In TicketRepository
List<Ticket> findByStatus(String status);
```

3. Add service method:
```java
// In TicketService
public List<TicketDto> listTickets() {
    // Implementation
}
```

### Add Business Logic
Modify `TicketService.createTicket()`:
- Add priority logic
- Add escalation rules
- Add notification logic
- Add validation

## Troubleshooting

### Connection Error
```
org.postgresql.util.PSQLException: Connection to localhost:5432 refused
```
**Solution:** Ensure PostgreSQL is running and database exists

### Schema Error
```
ERROR: relation "agents" does not exist
```
**Solution:** Run database initialization scripts:
```bash
psql -U postgres -d helpdeskdb -f ../database/schema.sql
psql -U postgres -d helpdeskdb -f ../database/init_data.sql
```

### Port Already in Use
```
Address already in use: bind
```
**Solution:** Change port in `application-properties.yml` or kill existing process

## Development Tips

- Use `@RestController` and `@GetMapping`/`@PostMapping` for endpoints
- Use Spring dependency injection with `@Autowired`
- Use `@Entity` for JPA mapping
- Use DTOs (`*Dto`) to separate API contracts from internal models
- Add `@Transactional` to service methods for database transactions

## Performance Considerations

- Add indexes on frequently queried columns (done in `schema.sql`)
- Use pagination for large result sets
- Cache agent lookups if called frequently
- Monitor slow queries with `show-sql: true` during development

## Security Notes

- Never commit passwords to version control
- Use environment variables or config servers for production credentials
- Add authentication (@EnableWebSecurity) before production
- Add input validation to request DTOs
- Use HTTPS in production

## Next Steps

1. Add authentication (OAuth2, JWT)
2. Add API documentation (Swagger/OpenAPI)
3. Add unit tests with JUnit 5 and Mockito
4. Add logging framework (SLF4J, Logback)
5. Add exception handling (ControllerAdvice)
6. Add pagination and filtering to GET endpoints
