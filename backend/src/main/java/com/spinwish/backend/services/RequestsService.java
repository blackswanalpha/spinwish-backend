package com.spinwish.backend.services;

import com.spinwish.backend.controllers.RequestWebSocketBroadcaster;
import com.spinwish.backend.entities.Request;
import com.spinwish.backend.entities.Songs;
import com.spinwish.backend.entities.Users;
import com.spinwish.backend.exceptions.UserNotExistingException;
import com.spinwish.backend.models.requests.users.PlaySongRequest;
import com.spinwish.backend.models.responses.songs.SongResponse;
import com.spinwish.backend.models.responses.users.PlaySongResponse;
import com.spinwish.backend.repositories.RequestsRepository;
import com.spinwish.backend.repositories.SongRepository;
import com.spinwish.backend.repositories.UsersRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
public class RequestsService {
    @Autowired
    private RequestsRepository requestsRepository;

    @Autowired
    private UsersRepository usersRepository;

    @Autowired
    private SongRepository songRepository;

    @Autowired
    private RequestWebSocketBroadcaster broadcaster;

    @Autowired
    private RefundService refundService;

    @Autowired
    private SessionService sessionService;

    @Transactional
    public PlaySongResponse createRequest(PlaySongRequest playSongRequest) {
        // Extract email from authenticated user (client)
        String emailAddress = SecurityContextHolder.getContext().getAuthentication().getName();

        log.info("🎵 Creating request - Received sessionId: {}", playSongRequest.getSessionId());
        log.info("🎵 Creating request - Received message: {}", playSongRequest.getMessage());
        log.info("🎵 Creating request - Received amount: {}", playSongRequest.getAmount());

        // Fetch logged-in user (the client)
        Users client = usersRepository.findByEmailAddress(emailAddress);
        if (client == null) {
            throw new UserNotExistingException("Client not found from token.");
        }

        // Fetch the DJ by ID or email from request
        Users dj = null;
        if (playSongRequest.getDjId() != null) {
            // Use djId if provided
            UUID djUuid = playSongRequest.getDjIdAsUuid();
            if (djUuid != null) {
                dj = usersRepository.findById(djUuid).orElse(null);
            }
        } else if (playSongRequest.getDjEmailAddress() != null) {
            // Fallback to email for backward compatibility
            dj = usersRepository.findByEmailAddress(playSongRequest.getDjEmailAddress());
        }

        if (dj == null) {
            String identifier = playSongRequest.getDjId() != null ?
                "ID " + playSongRequest.getDjId() :
                "email " + playSongRequest.getDjEmailAddress();
            throw new UserNotExistingException("DJ with " + identifier + " not found.");
        }

        // Build the request
        Request request = new Request();
        request.setStatus(Request.RequestStatus.PENDING);
        request.setAmount(playSongRequest.getAmount() != null ? playSongRequest.getAmount() : 0.0);
        request.setClientId(client.getId());
        request.setDjId(dj.getId());
        request.setCreatedAt(LocalDateTime.now());
        request.setUpdatedAt(LocalDateTime.now());

        // Set session ID if provided
        if (playSongRequest.getSessionId() != null && !playSongRequest.getSessionId().trim().isEmpty()) {
            UUID sessionUuid = playSongRequest.getSessionIdAsUuid();
            if (sessionUuid != null) {
                request.setSessionId(sessionUuid);
                log.info("✅ Session ID set on request: {}", sessionUuid);
            } else {
                log.warn("⚠️ Failed to parse sessionId as UUID: {}", playSongRequest.getSessionId());
            }
        } else {
            log.warn("⚠️ No sessionId provided in request");
        }

        // Set message if provided
        if (playSongRequest.getMessage() != null && !playSongRequest.getMessage().trim().isEmpty()) {
            request.setMessage(playSongRequest.getMessage());
            log.info("✅ Message set on request: {}", playSongRequest.getMessage());
        }

        // Set the song(s)
        if (playSongRequest.getSongIds() != null && !playSongRequest.getSongIds().isEmpty()) {
            String joinedSongIds = String.join(",", playSongRequest.getSongIds());
            request.setSongId(joinedSongIds);
        } else if (playSongRequest.getSongId() != null) {
            request.setSongId(playSongRequest.getSongId());
        } else {
            throw new RuntimeException("At least one song ID must be provided.");
        }

        request.setDj(dj);
        request.setClient(client);

        Request savedRequest = requestsRepository.save(request);
        log.info("💾 Request saved to database with ID: {}, sessionId: {}", savedRequest.getId(), savedRequest.getSessionId());

        // Update session statistics
        if (savedRequest.getSessionId() != null) {
            sessionService.updateSessionOnRequestCreated(savedRequest.getSessionId());
        }

        PlaySongResponse response = convertPlayRequest(savedRequest);
        broadcaster.broadcastRequestUpdate(response);
        return response;
    }



    public PlaySongResponse getRequestById(UUID id) {
        Optional<Request> request = requestsRepository.findById(id);
        if (request.isPresent()) {
            return convertPlayRequest(request.get());
        } else {
            throw new RuntimeException("Request not found with id: " + id);
        }
    }

    public List<PlaySongResponse> getAllRequests() {
        List<Request> all = requestsRepository.findAll();
        return all.stream().map(this::convertPlayRequest).collect(Collectors.toList());
    }

    @Transactional
    public PlaySongResponse updateRequest(UUID id, PlaySongRequest playSongRequest) {
        String emailAddress = SecurityContextHolder.getContext().getAuthentication().getName();
        Users client = usersRepository.findByEmailAddress(emailAddress);

        // Fetch the DJ by ID or email from request
        Users dj = null;
        if (playSongRequest.getDjId() != null) {
            // Use djId if provided
            UUID djUuid = playSongRequest.getDjIdAsUuid();
            if (djUuid != null) {
                dj = usersRepository.findById(djUuid).orElse(null);
            }
        } else if (playSongRequest.getDjEmailAddress() != null) {
            // Fallback to email for backward compatibility
            dj = usersRepository.findByEmailAddress(playSongRequest.getDjEmailAddress());
        }

        if (dj == null) {
            String identifier = playSongRequest.getDjId() != null ?
                "ID " + playSongRequest.getDjId() :
                "email " + playSongRequest.getDjEmailAddress();
            throw new RuntimeException("DJ with " + identifier + " not found.");
        }

        Optional<Request> existingOpt = requestsRepository.findById(id);
        if (existingOpt.isEmpty()) {
            throw new RuntimeException("Request not found with id: " + id);
        }

        Request request = existingOpt.get();
        request.setStatus(Request.RequestStatus.PENDING);
        request.setDjId(dj.getId());
        request.setClientId(client.getId());
        // Set the song(s)
        if (playSongRequest.getSongIds() != null && !playSongRequest.getSongIds().isEmpty()) {
            String joinedSongIds = String.join(",", playSongRequest.getSongIds());
            request.setSongId(joinedSongIds);
        } else if (playSongRequest.getSongId() != null) {
            request.setSongId(playSongRequest.getSongId());
        } else {
            throw new RuntimeException("At least one song ID must be provided.");
        }
        request.setUpdatedAt(LocalDateTime.now());

        requestsRepository.save(request);
        PlaySongResponse response = convertPlayRequest(request);
        broadcaster.broadcastRequestUpdate(response);
        return response;
    }

    @Transactional
    public PlaySongResponse markRequestAsDone(UUID requestId) {
        Request request = requestsRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found with ID: " + requestId));

        request.setStatus(Request.RequestStatus.PLAYED);
        request.setUpdatedAt(LocalDateTime.now());

        requestsRepository.save(request);
        PlaySongResponse response = convertPlayRequest(request);
        broadcaster.broadcastRequestUpdate(response);

        return response;
    }

    @Transactional
    public PlaySongResponse acceptRequest(UUID requestId) {
        Request request = requestsRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found with ID: " + requestId));

        // Verify the current user is the DJ for this request
        String emailAddress = SecurityContextHolder.getContext().getAuthentication().getName();
        Users currentDJ = usersRepository.findByEmailAddress(emailAddress);
        if (currentDJ == null || !currentDJ.getId().equals(request.getDjId())) {
            throw new RuntimeException("Unauthorized: You can only accept requests for your own sessions");
        }

        // Update request status to ACCEPTED
        request.setStatus(Request.RequestStatus.ACCEPTED);
        request.setUpdatedAt(LocalDateTime.now());

        requestsRepository.save(request);

        // Update session statistics
        if (request.getSessionId() != null) {
            sessionService.updateSessionOnRequestAccepted(request.getSessionId(), request.getAmount());
        }

        // Payment is automatically captured when request is accepted
        // The payment was already processed when the request was created
        // No additional action needed - earnings will be calculated from ACCEPTED requests
        log.info("✅ Request {} accepted by DJ {}. Payment captured for amount: KSH {}",
                 requestId, currentDJ.getActualUsername(), request.getAmount());

        PlaySongResponse response = convertPlayRequest(request);
        broadcaster.broadcastRequestUpdate(response);

        return response;
    }

    @Transactional
    public PlaySongResponse rejectRequest(UUID requestId) {
        Request request = requestsRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found with ID: " + requestId));

        // Verify the current user is the DJ for this request
        String emailAddress = SecurityContextHolder.getContext().getAuthentication().getName();
        Users currentDJ = usersRepository.findByEmailAddress(emailAddress);
        if (currentDJ == null || !currentDJ.getId().equals(request.getDjId())) {
            throw new RuntimeException("Unauthorized: You can only reject requests for your own sessions");
        }

        // Update request status to REJECTED
        request.setStatus(Request.RequestStatus.REJECTED);
        request.setUpdatedAt(LocalDateTime.now());

        requestsRepository.save(request);

        // Update session statistics
        if (request.getSessionId() != null) {
            sessionService.updateSessionOnRequestRejected(request.getSessionId());
        }

        // Process automatic refund for rejected request
        log.info("🔄 Processing refund for rejected request ID: {}", requestId);
        boolean refundSuccess = refundService.processRefundForRejectedRequest(request);

        if (refundSuccess) {
            log.info("✅ Refund processed successfully for request {} - Amount: KSH {}",
                     requestId, request.getAmount());
        } else {
            log.warn("⚠️ Refund processing failed or no payment found for request {}", requestId);
        }

        PlaySongResponse response = convertPlayRequest(request);
        broadcaster.broadcastRequestUpdate(response);

        return response;
    }


    public void delete(UUID id) {
        requestsRepository.deleteById(id);
    }

    private PlaySongResponse convertPlayRequest(Request request) {
        PlaySongResponse response = new PlaySongResponse();
        response.setId(request.getId());
        response.setDjName(request.getDj().getActualUsername());
        response.setClientName(request.getClient().getActualUsername());
        response.setStatus(request.getStatus() == Request.RequestStatus.ACCEPTED || request.getStatus() == Request.RequestStatus.PLAYED);

        List<SongResponse> songs = new ArrayList<>();

        if (request.getSongId() != null && !request.getSongId().isEmpty()) {
            List<UUID> songIds = Arrays.stream(request.getSongId().split(","))
                    .map(UUID::fromString)
                    .toList();

            List<Songs> songEntities = songRepository.findAllById(songIds);

            for (Songs song : songEntities) {
                SongResponse sr = new SongResponse();
                sr.setId(song.getId());
                sr.setName(song.getName());
                sr.setAlbum(song.getAlbum());
                sr.setCreatedAt(song.getCreatedAt());
                sr.setUpdatedAt(song.getUpdatedAt());

                if (song.getArtist() != null) {
                    sr.setArtistId(song.getArtist().getId());
                    sr.setArtistName(song.getArtist().getName());
                }

                songs.add(sr);
            }
        }

        response.setSongResponse(songs);
        response.setCreatedAt(request.getCreatedAt());
        response.setUpdatedAt(request.getUpdatedAt());
        response.setAmount(request.getAmount());
        response.setMessage(request.getMessage());
        response.setQueuePosition(request.getQueuePosition());
        response.setSessionId(request.getSessionId());

        return response;
    }

    // Get current user's requests
    public List<PlaySongResponse> getCurrentUserRequests() {
        String emailAddress = SecurityContextHolder.getContext().getAuthentication().getName();
        Users user = usersRepository.findByEmailAddress(emailAddress);
        if (user == null) {
            throw new UserNotExistingException("User not found from token.");
        }

        List<Request> userRequests = requestsRepository.findByClientOrderByCreatedAtDesc(user);
        return userRequests.stream().map(this::convertPlayRequest).collect(Collectors.toList());
    }

    // Get current DJ's requests
    public List<PlaySongResponse> getCurrentDJRequests() {
        String emailAddress = SecurityContextHolder.getContext().getAuthentication().getName();
        Users dj = usersRepository.findByEmailAddress(emailAddress);
        if (dj == null) {
            throw new UserNotExistingException("DJ not found from token.");
        }

        List<Request> djRequests = requestsRepository.findByDjOrderByCreatedAtDesc(dj);
        return djRequests.stream().map(this::convertPlayRequest).collect(Collectors.toList());
    }

    // Get current user's requests by status
    public List<PlaySongResponse> getCurrentUserRequestsByStatus(String status) {
        String emailAddress = SecurityContextHolder.getContext().getAuthentication().getName();
        Users user = usersRepository.findByEmailAddress(emailAddress);
        if (user == null) {
            throw new UserNotExistingException("User not found from token.");
        }

        try {
            Request.RequestStatus requestStatus = Request.RequestStatus.valueOf(status.toUpperCase());
            List<Request> userRequests = requestsRepository.findByClientAndStatusOrderByCreatedAtDesc(user, requestStatus);
            return userRequests.stream().map(this::convertPlayRequest).collect(Collectors.toList());
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid status: " + status);
        }
    }

    // ===== ENHANCED QUEUE MANAGEMENT METHODS =====

    /**
     * Get DJ's request queue with priority ordering
     * Priority is calculated based on tip amount and time decay
     */
    public List<PlaySongResponse> getDJRequestQueueWithPriority(UUID djId) {
        List<Request> pendingRequests = requestsRepository.findByDjIdAndStatus(djId, Request.RequestStatus.PENDING);

        // Sort by priority score (higher score = higher priority)
        List<Request> prioritizedRequests = pendingRequests.stream()
            .sorted((r1, r2) -> Double.compare(calculatePriorityScore(r2), calculatePriorityScore(r1)))
            .collect(Collectors.toList());

        // Update queue positions
        updateQueuePositions(prioritizedRequests);

        return prioritizedRequests.stream()
            .map(this::convertPlayRequest)
            .collect(Collectors.toList());
    }

    /**
     * Calculate priority score for a request
     * Formula: (tip_amount * tip_weight) + (time_decay_factor * time_weight)
     */
    private double calculatePriorityScore(Request request) {
        // Configuration constants
        final double TIP_WEIGHT = 0.7;
        final double TIME_WEIGHT = 0.3;
        final double MAX_TIME_BONUS = 10.0; // Maximum bonus for waiting time
        final long MAX_WAIT_MINUTES = 60; // After 60 minutes, time bonus is maxed

        // Tip amount component (normalized to 0-10 scale)
        double tipScore = Math.min(request.getAmount() != null ? request.getAmount() : 0.0, 10.0);

        // Time decay component (newer requests get slight bonus, older requests get more bonus)
        long minutesWaiting = ChronoUnit.MINUTES.between(request.getCreatedAt(), LocalDateTime.now());
        double timeBonus = Math.min((double) minutesWaiting / MAX_WAIT_MINUTES * MAX_TIME_BONUS, MAX_TIME_BONUS);

        return (tipScore * TIP_WEIGHT) + (timeBonus * TIME_WEIGHT);
    }

    /**
     * Update queue positions for a list of requests
     */
    @Transactional
    public void updateQueuePositions(List<Request> requests) {
        for (int i = 0; i < requests.size(); i++) {
            Request request = requests.get(i);
            if (request.getQueuePosition() == null || !request.getQueuePosition().equals(i + 1)) {
                request.setQueuePosition(i + 1);
                request.setUpdatedAt(LocalDateTime.now());
                requestsRepository.save(request);
            }
        }
    }

    /**
     * Reorder queue manually (DJ can drag and drop)
     */
    @Transactional
    public List<PlaySongResponse> reorderQueue(UUID djId, List<UUID> requestIds) {
        // Verify DJ ownership
        String emailAddress = SecurityContextHolder.getContext().getAuthentication().getName();
        Users currentDJ = usersRepository.findByEmailAddress(emailAddress);
        if (currentDJ == null || !currentDJ.getId().equals(djId)) {
            throw new RuntimeException("Unauthorized: You can only reorder your own queue");
        }

        List<Request> requests = new ArrayList<>();
        for (int i = 0; i < requestIds.size(); i++) {
            UUID requestId = requestIds.get(i);
            Request request = requestsRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found: " + requestId));

            // Verify request belongs to this DJ
            if (!request.getDjId().equals(djId)) {
                throw new RuntimeException("Request does not belong to this DJ: " + requestId);
            }

            request.setQueuePosition(i + 1);
            request.setUpdatedAt(LocalDateTime.now());
            requests.add(request);
        }

        requestsRepository.saveAll(requests);

        // Broadcast queue update
        List<PlaySongResponse> responses = requests.stream()
            .map(this::convertPlayRequest)
            .collect(Collectors.toList());

        responses.forEach(broadcaster::broadcastRequestUpdate);

        return responses;
    }

    /**
     * Check for duplicate songs in queue
     */
    public boolean isDuplicateSong(UUID djId, String songId) {
        List<Request> pendingRequests = requestsRepository.findByDjIdAndStatus(djId, Request.RequestStatus.PENDING);
        return pendingRequests.stream()
            .anyMatch(request -> songId.equals(request.getSongId()));
    }

    /**
     * Get queue statistics for analytics
     */
    public Map<String, Object> getQueueStatistics(UUID djId) {
        List<Request> pendingRequests = requestsRepository.findByDjIdAndStatus(djId, Request.RequestStatus.PENDING);

        if (pendingRequests.isEmpty()) {
            return Map.of(
                "queueLength", 0,
                "averageTipAmount", 0.0,
                "totalQueueValue", 0.0,
                "averageWaitTime", 0.0,
                "oldestRequestAge", 0L
            );
        }

        double averageTip = pendingRequests.stream()
            .mapToDouble(r -> r.getAmount() != null ? r.getAmount() : 0.0)
            .average()
            .orElse(0.0);

        double totalValue = pendingRequests.stream()
            .mapToDouble(r -> r.getAmount() != null ? r.getAmount() : 0.0)
            .sum();

        long oldestRequestAge = pendingRequests.stream()
            .mapToLong(r -> ChronoUnit.MINUTES.between(r.getCreatedAt(), LocalDateTime.now()))
            .max()
            .orElse(0L);

        double averageWaitTime = pendingRequests.stream()
            .mapToLong(r -> ChronoUnit.MINUTES.between(r.getCreatedAt(), LocalDateTime.now()))
            .average()
            .orElse(0.0);

        return Map.of(
            "queueLength", pendingRequests.size(),
            "averageTipAmount", Math.round(averageTip * 100.0) / 100.0,
            "totalQueueValue", Math.round(totalValue * 100.0) / 100.0,
            "averageWaitTime", Math.round(averageWaitTime * 100.0) / 100.0,
            "oldestRequestAge", oldestRequestAge
        );
    }

    /**
     * Get all requests for a specific session
     */
    public List<PlaySongResponse> getRequestsBySessionId(UUID sessionId) {
        log.info("📋 Fetching requests for session: {}", sessionId);
        List<Request> requests = requestsRepository.findBySessionIdOrderByCreatedAtDesc(sessionId);
        log.info("📋 Found {} requests for session {}", requests.size(), sessionId);

        // Log details of each request
        for (Request req : requests) {
            log.info("  - Request ID: {}, SessionId: {}, Status: {}, Amount: {}",
                req.getId(), req.getSessionId(), req.getStatus(), req.getAmount());
        }

        return requests.stream()
                .map(this::convertPlayRequest)
                .collect(Collectors.toList());
    }

    /**
     * Get pending requests for a session (PENDING status only)
     */
    public List<PlaySongResponse> getPendingRequestsBySessionId(UUID sessionId) {
        log.info("⏳ Fetching pending requests for session: {}", sessionId);
        List<Request> requests = requestsRepository.findBySessionIdOrderByCreatedAtDesc(sessionId);

        // Filter for PENDING status only
        List<Request> pendingRequests = requests.stream()
                .filter(r -> r.getStatus() == Request.RequestStatus.PENDING)
                .collect(Collectors.toList());

        log.info("⏳ Found {} pending requests for session {}", pendingRequests.size(), sessionId);

        return pendingRequests.stream()
                .map(this::convertPlayRequest)
                .collect(Collectors.toList());
    }

    /**
     * Get session queue (accepted requests ordered by queue position)
     */
    public List<PlaySongResponse> getSessionQueue(UUID sessionId) {
        log.info("🎵 Fetching queue for session: {}", sessionId);
        // Get all requests for the session
        List<Request> allRequests = requestsRepository.findBySessionIdOrderByCreatedAtDesc(sessionId);
        log.info("🎵 Found {} total requests for session {}", allRequests.size(), sessionId);

        // Filter for accepted requests and sort by queue position
        List<Request> acceptedRequests = allRequests.stream()
                .filter(r -> r.getStatus() == Request.RequestStatus.ACCEPTED)
                .sorted((r1, r2) -> {
                    // Handle null queue positions - put them at the end
                    if (r1.getQueuePosition() == null && r2.getQueuePosition() == null) {
                        return r1.getCreatedAt().compareTo(r2.getCreatedAt());
                    }
                    if (r1.getQueuePosition() == null) return 1;
                    if (r2.getQueuePosition() == null) return -1;
                    return r1.getQueuePosition().compareTo(r2.getQueuePosition());
                })
                .collect(Collectors.toList());

        return acceptedRequests.stream()
                .map(this::convertPlayRequest)
                .collect(Collectors.toList());
    }

}
