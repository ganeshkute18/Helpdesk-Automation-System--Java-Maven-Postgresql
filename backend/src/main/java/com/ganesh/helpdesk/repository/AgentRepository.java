package com.ganesh.helpdesk.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.ganesh.helpdesk.model.Agent;
import java.util.Optional;

public interface AgentRepository extends JpaRepository<Agent, Long> {
    Optional<Agent> findFirstBySkillsetContainingAndIsActiveTrue(String skillset);
}
