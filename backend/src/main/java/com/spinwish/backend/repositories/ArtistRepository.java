package com.spinwish.backend.repositories;

import com.spinwish.backend.entities.Artists;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface ArtistRepository extends JpaRepository<Artists, UUID> {
    Optional<Artists> findByName(String name);
}
