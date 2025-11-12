package com.ganesh.helpdesk.model;

import java.time.LocalDateTime;

public class TicketDto {
    private Long ticketId;
    private Integer userId;
    private String category;
    private String description;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime slaDueAt;
    private Long assignedAgentId;

    public TicketDto(Ticket t) {
        this.ticketId = t.getTicketId();
        this.userId = t.getUserId();
        this.category = t.getCategory();
        this.description = t.getDescription();
        this.status = t.getStatus();
        this.createdAt = t.getCreatedAt();
        this.slaDueAt = t.getSlaDueAt();
        this.assignedAgentId = (t.getAssignedAgent()!=null ? t.getAssignedAgent().getAgentId() : null);
    }

    // getters & setters
    public Long getTicketId() {
        return ticketId;
    }

    public void setTicketId(Long ticketId) {
        this.ticketId = ticketId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getSlaDueAt() {
        return slaDueAt;
    }

    public void setSlaDueAt(LocalDateTime slaDueAt) {
        this.slaDueAt = slaDueAt;
    }

    public Long getAssignedAgentId() {
        return assignedAgentId;
    }

    public void setAssignedAgentId(Long assignedAgentId) {
        this.assignedAgentId = assignedAgentId;
    }
}
