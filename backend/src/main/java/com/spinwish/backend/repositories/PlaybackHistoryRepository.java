package com.spinwish.backend.repositories;

import com.spinwish.backend.entities.PlaybackHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PlaybackHistoryRepository extends JpaRepository<PlaybackHistory, String> {}
