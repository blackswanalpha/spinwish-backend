package com.spinwish.backend.repositories;

import com.spinwish.backend.entities.Session;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SessionRepository extends JpaRepository<Session, UUID> {

    // Find sessions by DJ
    List<Session> findByDjId(UUID djId);

    // Find sessions by club
    List<Session> findByClubId(UUID clubId);

    // Find sessions by status
    List<Session> findByStatus(Session.SessionStatus status);

    // Find sessions by type
    List<Session> findByType(Session.SessionType type);

    // Find active sessions (LIVE or PREPARING status)
    @Query("SELECT s FROM Session s WHERE s.status IN ('LIVE', 'PREPARING')")
    List<Session> findActiveSessions();

    // Find live sessions
    List<Session> findByStatusOrderByStartTimeDesc(Session.SessionStatus status);

    // Find sessions by DJ and status
    List<Session> findByDjIdAndStatus(UUID djId, Session.SessionStatus status);

    // Find current live session for a DJ
    @Query("SELECT s FROM Session s WHERE s.djId = :djId AND s.status = 'LIVE' ORDER BY s.startTime DESC")
    Optional<Session> findCurrentLiveSessionByDj(@Param("djId") UUID djId);

    // Find sessions within a date range
    @Query("SELECT s FROM Session s WHERE s.startTime >= :startDate AND s.startTime <= :endDate")
    List<Session> findSessionsInDateRange(@Param("startDate") LocalDateTime startDate, 
                                        @Param("endDate") LocalDateTime endDate);

    // Find sessions by genre
    @Query("SELECT s FROM Session s JOIN s.genres g WHERE g = :genre")
    List<Session> findByGenre(@Param("genre") String genre);

    // Find sessions accepting requests
    List<Session> findByIsAcceptingRequestsTrue();

    // Find sessions with listener count greater than specified
    @Query("SELECT s FROM Session s WHERE s.listenerCount > :minListeners")
    List<Session> findSessionsWithMinListeners(@Param("minListeners") Integer minListeners);

    // Find top earning sessions
    @Query("SELECT s FROM Session s ORDER BY s.totalEarnings DESC")
    List<Session> findTopEarningSessions();

    // Count active sessions by DJ
    @Query("SELECT COUNT(s) FROM Session s WHERE s.djId = :djId AND s.status IN ('LIVE', 'PREPARING')")
    Long countActiveSessionsByDj(@Param("djId") UUID djId);
}
