package com.spinwish.backend.repositories;

import com.spinwish.backend.entities.Request;
import com.spinwish.backend.entities.Users;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface RequestsRepository extends JpaRepository<Request, UUID> {

    // Find requests by client (user who made the request)
    List<Request> findByClientOrderByCreatedAtDesc(Users client);

    // Find requests by DJ (who received the request)
    List<Request> findByDjOrderByCreatedAtDesc(Users dj);

    // Find requests by client and status
    List<Request> findByClientAndStatusOrderByCreatedAtDesc(Users client, Request.RequestStatus status);

    // Find requests by DJ and status
    List<Request> findByDjAndStatusOrderByCreatedAtDesc(Users dj, Request.RequestStatus status);

    // Find pending requests for a DJ
    List<Request> findByDjAndStatusOrderByCreatedAtAsc(Users dj, Request.RequestStatus status);

    // Count requests by client
    long countByClient(Users client);

    // Count requests by DJ
    long countByDj(Users dj);

    // Find recent requests by client
    List<Request> findTop10ByClientOrderByCreatedAtDesc(Users client);

    // Find recent requests by DJ
    List<Request> findTop10ByDjOrderByCreatedAtDesc(Users dj);

    // Find requests by DJ ID and status (for priority queue management)
    List<Request> findByDjIdAndStatus(UUID djId, Request.RequestStatus status);

    // Find requests by DJ ID and status ordered by queue position
    List<Request> findByDjIdAndStatusOrderByQueuePositionAsc(UUID djId, Request.RequestStatus status);

    // Find requests by session ID
    List<Request> findBySessionIdOrderByCreatedAtDesc(UUID sessionId);
}
