# Architecture

## System Overview
The Helpdesk Automation System is a Spring Boot microservice designed to automate ticket intake, agent assignment, and SLA tracking for IT support operations.

## Technology Stack
- **Backend:** Java 11, Spring Boot 2.7.5, Spring Data JPA
- **Database:** PostgreSQL
- **Build Tool:** Maven
- **Deployment:** AWS (CloudFormation)
- **Container:** Docker (optional)

## Components

### 1. Controller Layer (`controller/`)
- **TicketController**: REST endpoints for ticket operations
  - `POST /tickets` - Create new ticket
  - `GET /tickets/{id}` - Retrieve ticket details

### 2. Service Layer (`service/`)
- **TicketService**: Business logic for ticket management
  - Creates tickets and auto-assigns to available agents based on skillset
  - Calculates SLA due dates (24 hours by default)
  - Retrieves ticket information

### 3. Repository Layer (`repository/`)
- **TicketRepository**: JPA repository for Ticket entity (CRUD operations)
- **AgentRepository**: JPA repository for Agent entity
  - Custom query: `findFirstBySkillsetContainingAndIsActiveTrue()` for agent matching

### 4. Model Layer (`model/`)
- **Agent**: JPA Entity representing support agents
  - Fields: agentId, name, skillset, isActive
  - One-to-Many relationship with Ticket

- **Ticket**: JPA Entity representing support tickets
  - Fields: ticketId, userId, category, description, status, createdAt, slaDueAt, resolvedAt, assignedAgentId
  - Many-to-One relationship with Agent

- **CreateTicketRequest**: DTO for incoming ticket requests
- **TicketDto**: DTO for ticket responses

## Database Schema

### agents table
```sql
CREATE TABLE agents (
  agent_id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  skillset VARCHAR(200),
  is_active BOOLEAN DEFAULT TRUE
);
```

### tickets table
```sql
CREATE TABLE tickets (
  ticket_id SERIAL PRIMARY KEY,
  user_id INT,
  category VARCHAR(100),
  description TEXT,
  status VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  assigned_agent_id INT,
  sla_due_at TIMESTAMP,
  resolved_at TIMESTAMP,
  FOREIGN KEY (assigned_agent_id) REFERENCES agents(agent_id)
);
```

## Application Flow

1. **Request Intake**: User submits ticket via POST `/tickets`
2. **Validation**: Request validated and DTO created
3. **Agent Assignment**: TicketService queries AgentRepository for matching skillset
4. **Ticket Creation**: Ticket entity created with:
   - Status: "Open"
   - CreatedAt: Current timestamp
   - SlaDueAt: Current timestamp + 24 hours
   - AssignedAgent: Matched agent
5. **Response**: Ticket saved to database and TicketDto returned to client

## Deployment Targets
- **Local Development**: Spring Boot embedded Tomcat (port 8080)
- **AWS**: EC2 with RDS PostgreSQL (see `deployment/aws/readme-aws.md`)

## Configuration
- **Properties File**: `backend/src/main/resources/application-properties.yml`
  - Database URL, username, password
  - JPA/Hibernate settings
  - Server port

## Future Enhancements
- Agent availability/capacity tracking
- Ticket priority levels and dynamic assignment
- Notification system (email/SMS)
- Ticket history and audit logging
- Dashboard for agent performance metrics
- Integration with external ticketing systems (Jira, ServiceNow)
