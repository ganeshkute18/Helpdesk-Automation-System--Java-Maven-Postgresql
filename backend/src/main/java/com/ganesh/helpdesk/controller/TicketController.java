package com.ganesh.helpdesk.controller;

import com.ganesh.helpdesk.model.CreateTicketRequest;
import com.ganesh.helpdesk.model.TicketDto;
import com.ganesh.helpdesk.service.TicketService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/tickets")
public class TicketController {

    @Autowired
    private TicketService ticketService;

    @PostMapping
    public ResponseEntity<TicketDto> createTicket(@RequestBody CreateTicketRequest req) {
        TicketDto dto = ticketService.createTicket(req);
        return ResponseEntity.status(201).body(dto);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TicketDto> getTicket(@PathVariable Long id) {
        TicketDto dto = ticketService.getTicket(id);
        return ResponseEntity.ok(dto);
    }
}
