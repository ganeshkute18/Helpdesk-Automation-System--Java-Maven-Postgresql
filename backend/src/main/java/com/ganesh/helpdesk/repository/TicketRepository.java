package com.ganesh.helpdesk.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.ganesh.helpdesk.model.Ticket;

public interface TicketRepository extends JpaRepository<Ticket, Long> {
}
