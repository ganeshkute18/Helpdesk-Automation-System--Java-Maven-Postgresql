CREATE TABLE agents (
  agent_id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  skillset VARCHAR(200),
  is_active BOOLEAN DEFAULT TRUE
);

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

CREATE INDEX idx_tickets_status ON tickets(status);
