-- Insert sample agents
INSERT INTO agents (name, skillset, is_active) VALUES
('Alice Johnson', 'network', true),
('Bob Smith', 'software', true),
('Charlie Brown', 'hardware', true),
('Diana Prince', 'database', true),
('Eve Wilson', 'security', true);

-- Insert sample tickets
INSERT INTO tickets (user_id, category, description, status, assigned_agent_id, created_at, sla_due_at) VALUES
(101, 'network', 'VPN connection issues', 'Open', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(102, 'software', 'Application crash on startup', 'Open', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(103, 'hardware', 'Printer not responding', 'Open', 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(104, 'database', 'Slow query performance', 'Open', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(105, 'security', 'Suspicious login attempt detected', 'Open', 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '24 hours');
