package com.ganesh.helpdesk.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ganesh.helpdesk.model.Ticket;
import com.ganesh.helpdesk.model.Agent;
import com.ganesh.helpdesk.repository.TicketRepository;
import com.ganesh.helpdesk.repository.AgentRepository;
import com.ganesh.helpdesk.model.TicketDto;
import com.ganesh.helpdesk.model.CreateTicketRequest;

import java.time.LocalDateTime;

@Service
public class TicketService {

    @Autowired
    private TicketRepository ticketRepository;

    @Autowired
    private AgentRepository agentRepository;

    public TicketDto createTicket(CreateTicketRequest req) {
        Agent agent = agentRepository.findFirstBySkillsetContainingAndIsActiveTrue(req.getCategory())
                .orElseThrow(() -> new RuntimeException("No agent available"));

        Ticket ticket = new Ticket();
        ticket.setUserId(req.getUserId());
        ticket.setCategory(req.getCategory());
        ticket.setDescription(req.getDescription());
        ticket.setStatus("Open");
        ticket.setCreatedAt(LocalDateTime.now());
        ticket.setAssignedAgent(agent);
        ticket.setSlaDueAt(LocalDateTime.now().plusHours(24));

        ticketRepository.save(ticket);

        return new TicketDto(ticket);
    }

    public TicketDto getTicket(Long id) {
        Ticket ticket = ticketRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Ticket not found"));
        return new TicketDto(ticket);
    }
}
