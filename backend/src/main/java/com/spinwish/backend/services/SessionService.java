package com.spinwish.backend.services;

import com.spinwish.backend.entities.Request;
import com.spinwish.backend.entities.Session;
import com.spinwish.backend.entities.Users;
import com.spinwish.backend.models.responses.sessions.SessionAnalyticsResponse;
import com.spinwish.backend.repositories.RequestsRepository;
import com.spinwish.backend.repositories.SessionRepository;
import com.spinwish.backend.repositories.UsersRepository;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
@Slf4j
public class SessionService {

    @Autowired
    private SessionRepository sessionRepository;

    @Autowired
    private UsersRepository usersRepository;

    @Autowired
    private RequestsRepository requestsRepository;

    private final Path rootLocation = Paths.get("uploads/session-images");

    @PostConstruct
    public void init() {
        try {
            Files.createDirectories(rootLocation);
            Path absolutePath = rootLocation.toAbsolutePath();
            log.info("Session images upload directory initialized at: {}", absolutePath);
            log.info("Directory exists: {}, Is writable: {}",
                    Files.exists(absolutePath),
                    Files.isWritable(absolutePath));
        } catch (IOException e) {
            log.error("Failed to initialize folder for session image uploads at: {}",
                    rootLocation.toAbsolutePath(), e);
            throw new RuntimeException("Could not initialize folder for session image uploads!", e);
        }
    }

    // Create a new session
    public Session createSession(Session session) {
        // Validate DJ exists
        Optional<Users> dj = usersRepository.findById(session.getDjId());
        if (dj.isEmpty()) {
            throw new RuntimeException("DJ not found with id: " + session.getDjId());
        }

        // Set default values
        if (session.getStartTime() == null) {
            session.setStartTime(LocalDateTime.now());
        }
        if (session.getStatus() == null) {
            session.setStatus(Session.SessionStatus.PREPARING);
        }
        session.setListenerCount(session.getListenerCount() != null ? session.getListenerCount() : 0);
        session.setTotalEarnings(session.getTotalEarnings() != null ? session.getTotalEarnings() : 0.0);
        session.setTotalTips(session.getTotalTips() != null ? session.getTotalTips() : 0.0);
        session.setTotalRequests(session.getTotalRequests() != null ? session.getTotalRequests() : 0);
        session.setAcceptedRequests(session.getAcceptedRequests() != null ? session.getAcceptedRequests() : 0);
        session.setRejectedRequests(session.getRejectedRequests() != null ? session.getRejectedRequests() : 0);
        session.setIsAcceptingRequests(session.getIsAcceptingRequests() != null ? session.getIsAcceptingRequests() : true);
        session.setMinTipAmount(session.getMinTipAmount() != null ? session.getMinTipAmount() : 0.0);

        // Add placeholder images if not provided
        if (session.getImageUrl() == null || session.getImageUrl().isEmpty()) {
            session.setImageUrl(getPlaceholderImageUrl());
        }
        if (session.getThumbnailUrl() == null || session.getThumbnailUrl().isEmpty()) {
            session.setThumbnailUrl(getPlaceholderThumbnailUrl());
        }

        // Save session first to generate ID
        Session savedSession = sessionRepository.save(session);

        // Generate shareable link after ID is available
        if (savedSession.getShareableLink() == null) {
            savedSession.setShareableLink(generateShareableLink(savedSession.getId()));
            savedSession = sessionRepository.save(savedSession);
        }

        return savedSession;
    }

    /**
     * Get placeholder image URL for sessions without custom images
     */
    private String getPlaceholderImageUrl() {
        // Using Unsplash for high-quality placeholder images
        // These are free to use and don't require attribution for this use case
        String[] placeholders = {
            "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800&h=600&fit=crop",
            "https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=800&h=600&fit=crop",
            "https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=800&h=600&fit=crop",
            "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=600&fit=crop",
            "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&h=600&fit=crop"
        };
        // Return a random placeholder
        int index = (int) (Math.random() * placeholders.length);
        return placeholders[index];
    }

    /**
     * Get placeholder thumbnail URL for sessions without custom thumbnails
     */
    private String getPlaceholderThumbnailUrl() {
        // Using smaller versions for thumbnails
        String[] placeholders = {
            "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&h=300&fit=crop",
            "https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=400&h=300&fit=crop",
            "https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=400&h=300&fit=crop",
            "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=300&fit=crop",
            "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=400&h=300&fit=crop"
        };
        // Return a random placeholder
        int index = (int) (Math.random() * placeholders.length);
        return placeholders[index];
    }

    // Get session by ID
    public Optional<Session> getSessionById(UUID id) {
        return sessionRepository.findById(id);
    }

    // Get all sessions
    public List<Session> getAllSessions() {
        return sessionRepository.findAll();
    }

    // Get sessions by DJ
    public List<Session> getSessionsByDj(UUID djId) {
        return sessionRepository.findByDjId(djId);
    }

    // Get sessions by club
    public List<Session> getSessionsByClub(UUID clubId) {
        return sessionRepository.findByClubId(clubId);
    }

    // Get active sessions
    public List<Session> getActiveSessions() {
        return sessionRepository.findActiveSessions();
    }

    // Get live sessions
    public List<Session> getLiveSessions() {
        return sessionRepository.findByStatusOrderByStartTimeDesc(Session.SessionStatus.LIVE);
    }

    // Get current live session for DJ
    public Optional<Session> getCurrentLiveSessionByDj(UUID djId) {
        return sessionRepository.findCurrentLiveSessionByDj(djId);
    }

    // Start session (change status to LIVE)
    public Session startSession(UUID sessionId) {
        Optional<Session> sessionOpt = sessionRepository.findById(sessionId);
        if (sessionOpt.isEmpty()) {
            throw new RuntimeException("Session not found with id: " + sessionId);
        }

        Session session = sessionOpt.get();
        session.setStatus(Session.SessionStatus.LIVE);
        session.setStartTime(LocalDateTime.now());

        // Update DJ's live status
        Optional<Users> djOpt = usersRepository.findById(session.getDjId());
        if (djOpt.isPresent()) {
            Users dj = djOpt.get();
            dj.setIsLive(true);
            usersRepository.save(dj);
        }

        return sessionRepository.save(session);
    }

    // End session
    public Session endSession(UUID sessionId) {
        Optional<Session> sessionOpt = sessionRepository.findById(sessionId);
        if (sessionOpt.isEmpty()) {
            throw new RuntimeException("Session not found with id: " + sessionId);
        }

        Session session = sessionOpt.get();
        session.setStatus(Session.SessionStatus.ENDED);
        session.setEndTime(LocalDateTime.now());

        // Update DJ's live status
        Optional<Users> djOpt = usersRepository.findById(session.getDjId());
        if (djOpt.isPresent()) {
            Users dj = djOpt.get();
            dj.setIsLive(false);
            usersRepository.save(dj);
        }

        return sessionRepository.save(session);
    }

    // Pause session
    public Session pauseSession(UUID sessionId) {
        Optional<Session> sessionOpt = sessionRepository.findById(sessionId);
        if (sessionOpt.isEmpty()) {
            throw new RuntimeException("Session not found with id: " + sessionId);
        }

        Session session = sessionOpt.get();
        session.setStatus(Session.SessionStatus.PAUSED);
        return sessionRepository.save(session);
    }

    // Update session
    public Session updateSession(UUID sessionId, Session updatedSession) {
        Optional<Session> sessionOpt = sessionRepository.findById(sessionId);
        if (sessionOpt.isEmpty()) {
            throw new RuntimeException("Session not found with id: " + sessionId);
        }

        Session session = sessionOpt.get();
        
        // Update fields
        if (updatedSession.getTitle() != null) {
            session.setTitle(updatedSession.getTitle());
        }
        if (updatedSession.getDescription() != null) {
            session.setDescription(updatedSession.getDescription());
        }
        if (updatedSession.getIsAcceptingRequests() != null) {
            session.setIsAcceptingRequests(updatedSession.getIsAcceptingRequests());
        }
        if (updatedSession.getMinTipAmount() != null) {
            session.setMinTipAmount(updatedSession.getMinTipAmount());
        }
        if (updatedSession.getGenres() != null) {
            session.setGenres(updatedSession.getGenres());
        }
        if (updatedSession.getCurrentSongId() != null) {
            session.setCurrentSongId(updatedSession.getCurrentSongId());
        }

        return sessionRepository.save(session);
    }

    // Update listener count
    public Session updateListenerCount(UUID sessionId, Integer listenerCount) {
        Optional<Session> sessionOpt = sessionRepository.findById(sessionId);
        if (sessionOpt.isEmpty()) {
            throw new RuntimeException("Session not found with id: " + sessionId);
        }

        Session session = sessionOpt.get();
        session.setListenerCount(listenerCount);
        return sessionRepository.save(session);
    }

    // Add earnings to session
    public Session addEarnings(UUID sessionId, Double amount) {
        Optional<Session> sessionOpt = sessionRepository.findById(sessionId);
        if (sessionOpt.isEmpty()) {
            throw new RuntimeException("Session not found with id: " + sessionId);
        }

        Session session = sessionOpt.get();
        session.setTotalEarnings(session.getTotalEarnings() + amount);
        return sessionRepository.save(session);
    }

    // Add tips to session
    public Session addTips(UUID sessionId, Double amount) {
        Optional<Session> sessionOpt = sessionRepository.findById(sessionId);
        if (sessionOpt.isEmpty()) {
            throw new RuntimeException("Session not found with id: " + sessionId);
        }

        Session session = sessionOpt.get();
        session.setTotalTips(session.getTotalTips() + amount);
        return sessionRepository.save(session);
    }

    // Get sessions by date range
    public List<Session> getSessionsByDateRange(String startDate, String endDate) {
        try {
            LocalDateTime startDateTime = LocalDate.parse(startDate).atStartOfDay();
            LocalDateTime endDateTime = LocalDate.parse(endDate).atTime(23, 59, 59);
            return sessionRepository.findSessionsInDateRange(startDateTime, endDateTime);
        } catch (Exception e) {
            throw new RuntimeException("Invalid date format. Use yyyy-MM-dd format.");
        }
    }

    // Get today's live sessions
    public List<Session> getTodaysLiveSessions() {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = LocalDate.now().atTime(23, 59, 59);
        List<Session> todaySessions = sessionRepository.findSessionsInDateRange(startOfDay, endOfDay);
        return todaySessions.stream()
                .filter(session -> session.getStatus() == Session.SessionStatus.LIVE)
                .collect(Collectors.toList());
    }

    // Delete session
    public void deleteSession(UUID sessionId) {
        sessionRepository.deleteById(sessionId);
    }

    // Helper method to generate shareable link
    private String generateShareableLink(UUID sessionId) {
        return "https://spinwish.app/session/" + sessionId.toString();
    }

    // Get sessions by genre
    public List<Session> getSessionsByGenre(String genre) {
        return sessionRepository.findByGenre(genre);
    }

    // Get sessions accepting requests
    public List<Session> getSessionsAcceptingRequests() {
        return sessionRepository.findByIsAcceptingRequestsTrue();
    }

    // Get sessions by status
    public List<Session> getSessionsByStatus(Session.SessionStatus status) {
        return sessionRepository.findByStatus(status);
    }

    // Get sessions by type
    public List<Session> getSessionsByType(Session.SessionType type) {
        return sessionRepository.findByType(type);
    }

    // Upload session image
    public Session uploadSessionImage(UUID sessionId, MultipartFile imageFile) throws IOException {
        log.info("Starting image upload for session: {}", sessionId);
        log.debug("Image file details - Name: {}, Size: {} bytes, Content-Type: {}",
                imageFile.getOriginalFilename(),
                imageFile.getSize(),
                imageFile.getContentType());

        Optional<Session> sessionOpt = sessionRepository.findById(sessionId);
        if (sessionOpt.isEmpty()) {
            log.error("Session not found with id: {}", sessionId);
            throw new RuntimeException("Session not found with id: " + sessionId);
        }

        Session session = sessionOpt.get();

        // Validate image file
        try {
            validateImageFile(imageFile);
            log.debug("Image file validation passed");
        } catch (Exception e) {
            log.error("Image file validation failed: {}", e.getMessage());
            throw e;
        }

        String originalFilename = imageFile.getOriginalFilename();
        if (originalFilename == null || originalFilename.trim().isEmpty()) {
            log.error("Invalid or empty filename");
            throw new RuntimeException("Invalid filename");
        }

        String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
        String newFileName = UUID.randomUUID() + fileExtension;
        log.debug("Generated new filename: {}", newFileName);

        Path destinationFile = this.rootLocation.resolve(Paths.get(newFileName)).normalize().toAbsolutePath();
        log.debug("Destination file path: {}", destinationFile);

        // Ensure the path is within the upload directory (security check)
        if (!destinationFile.getParent().equals(this.rootLocation.toAbsolutePath())) {
            log.error("Security violation: Attempted to store file outside upload directory. Destination: {}, Root: {}",
                    destinationFile.getParent(),
                    this.rootLocation.toAbsolutePath());
            throw new RuntimeException("Cannot store file outside current directory.");
        }

        // Ensure the directory exists
        if (!Files.exists(this.rootLocation)) {
            log.warn("Upload directory does not exist, creating: {}", this.rootLocation.toAbsolutePath());
            Files.createDirectories(this.rootLocation);
        }

        try {
            Files.copy(imageFile.getInputStream(), destinationFile, StandardCopyOption.REPLACE_EXISTING);
            log.info("Successfully saved image file to: {}", destinationFile);
        } catch (IOException e) {
            log.error("Failed to save image file to: {}. Error: {}", destinationFile, e.getMessage(), e);
            throw new IOException("Failed to save image file: " + e.getMessage(), e);
        }

        String imageUrl = "/uploads/session-images/" + newFileName;
        session.setImageUrl(imageUrl);
        session.setThumbnailUrl(imageUrl); // For now, use same image

        Session savedSession = sessionRepository.save(session);
        log.info("Successfully updated session {} with image URL: {}", sessionId, imageUrl);

        return savedSession;
    }

    // Validate image file
    private void validateImageFile(MultipartFile file) {
        // Check file size (max 10MB for session images)
        long maxSize = 10 * 1024 * 1024; // 10MB in bytes
        if (file.getSize() > maxSize) {
            throw new RuntimeException("File size exceeds maximum allowed size of 10MB");
        }

        // Check file type
        String contentType = file.getContentType();
        if (contentType != null) {
            contentType = contentType.toLowerCase();
        }

        boolean isValidType = contentType != null && (
            contentType.equals("image/jpeg") ||
            contentType.equals("image/jpg") ||
            contentType.equals("image/pjpeg") ||
            contentType.equals("image/png") ||
            contentType.equals("image/gif") ||
            contentType.equals("image/webp")
        );

        // Check filename and extension as fallback
        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null || originalFilename.trim().isEmpty()) {
            throw new RuntimeException("Invalid filename");
        }

        if (!originalFilename.contains(".")) {
            throw new RuntimeException("File must have an extension");
        }

        String extension = originalFilename.substring(originalFilename.lastIndexOf(".")).toLowerCase();
        boolean hasValidExtension = extension.equals(".jpg") || extension.equals(".jpeg") ||
                                   extension.equals(".png") || extension.equals(".gif") ||
                                   extension.equals(".webp");

        if (!isValidType && !hasValidExtension) {
            throw new RuntimeException("Invalid file type. Only JPEG, PNG, GIF, and WebP images are allowed");
        }
    }

    // Delete session image
    public Session deleteSessionImage(UUID sessionId) {
        Optional<Session> sessionOpt = sessionRepository.findById(sessionId);
        if (sessionOpt.isEmpty()) {
            throw new RuntimeException("Session not found with id: " + sessionId);
        }

        Session session = sessionOpt.get();

        // Delete the physical file if it exists
        if (session.getImageUrl() != null && !session.getImageUrl().isEmpty()) {
            try {
                String filename = session.getImageUrl().substring(session.getImageUrl().lastIndexOf("/") + 1);
                Path filePath = rootLocation.resolve(filename);
                Files.deleteIfExists(filePath);
            } catch (IOException e) {
                // Log error but don't fail the operation
                System.err.println("Failed to delete image file: " + e.getMessage());
            }
        }

        session.setImageUrl(null);
        session.setThumbnailUrl(null);

        return sessionRepository.save(session);
    }

    // Get session analytics
    public SessionAnalyticsResponse getSessionAnalytics(UUID sessionId) {
        Optional<Session> sessionOpt = sessionRepository.findById(sessionId);
        if (sessionOpt.isEmpty()) {
            throw new RuntimeException("Session not found with id: " + sessionId);
        }

        Session session = sessionOpt.get();

        // Get all requests for this session
        List<Request> allRequests = requestsRepository.findBySessionIdOrderByCreatedAtDesc(sessionId);

        // Calculate request metrics
        int totalRequests = allRequests.size();
        long pendingRequests = allRequests.stream()
                .filter(r -> r.getStatus() == Request.RequestStatus.PENDING)
                .count();
        long acceptedRequests = allRequests.stream()
                .filter(r -> r.getStatus() == Request.RequestStatus.ACCEPTED)
                .count();
        long rejectedRequests = allRequests.stream()
                .filter(r -> r.getStatus() == Request.RequestStatus.REJECTED)
                .count();

        // Calculate earnings metrics
        double totalRequestPayments = allRequests.stream()
                .filter(r -> r.getStatus() == Request.RequestStatus.ACCEPTED)
                .mapToDouble(r -> r.getAmount() != null ? r.getAmount() : 0.0)
                .sum();

        double totalEarnings = totalRequestPayments + (session.getTotalTips() != null ? session.getTotalTips() : 0.0);

        // Calculate averages
        double averageRequestAmount = acceptedRequests > 0 ?
                totalRequestPayments / acceptedRequests : 0.0;
        double averageTipAmount = session.getTotalTips() != null && session.getTotalTips() > 0 ?
                session.getTotalTips() : 0.0;

        // Calculate acceptance rate
        double acceptanceRate = totalRequests > 0 ?
                (acceptedRequests * 100.0) / totalRequests : 0.0;

        // Calculate session duration and rates
        long sessionDurationMinutes = 0;
        double earningsPerHour = 0.0;
        double requestsPerHour = 0.0;

        if (session.getStartTime() != null) {
            LocalDateTime endTime = session.getEndTime() != null ?
                    session.getEndTime() : LocalDateTime.now();
            sessionDurationMinutes = ChronoUnit.MINUTES.between(session.getStartTime(), endTime);

            if (sessionDurationMinutes > 0) {
                double hours = sessionDurationMinutes / 60.0;
                earningsPerHour = totalEarnings / hours;
                requestsPerHour = totalRequests / hours;
            }
        }

        // Build response
        SessionAnalyticsResponse analytics = new SessionAnalyticsResponse();
        analytics.setSessionId(session.getId());
        analytics.setTitle(session.getTitle());
        analytics.setStatus(session.getStatus().name());
        analytics.setStartTime(session.getStartTime());
        analytics.setEndTime(session.getEndTime());

        analytics.setActiveListeners(session.getListenerCount());
        analytics.setPeakListeners(session.getListenerCount()); // TODO: Track peak separately

        analytics.setTotalRequests(totalRequests);
        analytics.setPendingRequests((int) pendingRequests);
        analytics.setAcceptedRequests((int) acceptedRequests);
        analytics.setRejectedRequests((int) rejectedRequests);

        analytics.setTotalEarnings(totalEarnings);
        analytics.setTotalTips(session.getTotalTips());
        analytics.setTotalRequestPayments(totalRequestPayments);
        analytics.setAverageTipAmount(averageTipAmount);
        analytics.setAverageRequestAmount(averageRequestAmount);

        analytics.setAcceptanceRate(acceptanceRate);
        analytics.setSessionDurationMinutes(sessionDurationMinutes);
        analytics.setEarningsPerHour(earningsPerHour);
        analytics.setRequestsPerHour(requestsPerHour);

        return analytics;
    }

    // Update session statistics when a request is accepted
    @Transactional
    public void updateSessionOnRequestAccepted(UUID sessionId, Double amount) {
        Optional<Session> sessionOpt = sessionRepository.findById(sessionId);
        if (sessionOpt.isEmpty()) {
            log.warn("Session not found with id: {} when updating on request accepted", sessionId);
            return;
        }

        Session session = sessionOpt.get();

        // Update earnings
        double currentEarnings = session.getTotalEarnings() != null ? session.getTotalEarnings() : 0.0;
        session.setTotalEarnings(currentEarnings + (amount != null ? amount : 0.0));

        // Update request counts
        int currentAccepted = session.getAcceptedRequests() != null ? session.getAcceptedRequests() : 0;
        session.setAcceptedRequests(currentAccepted + 1);

        sessionRepository.save(session);
        log.info("Updated session {} on request accepted: earnings={}, acceptedRequests={}",
                sessionId, session.getTotalEarnings(), session.getAcceptedRequests());
    }

    // Update session statistics when a request is rejected
    @Transactional
    public void updateSessionOnRequestRejected(UUID sessionId) {
        Optional<Session> sessionOpt = sessionRepository.findById(sessionId);
        if (sessionOpt.isEmpty()) {
            log.warn("Session not found with id: {} when updating on request rejected", sessionId);
            return;
        }

        Session session = sessionOpt.get();

        // Update request counts
        int currentRejected = session.getRejectedRequests() != null ? session.getRejectedRequests() : 0;
        session.setRejectedRequests(currentRejected + 1);

        sessionRepository.save(session);
        log.info("Updated session {} on request rejected: rejectedRequests={}",
                sessionId, session.getRejectedRequests());
    }

    // Update session statistics when a request is created
    @Transactional
    public void updateSessionOnRequestCreated(UUID sessionId) {
        Optional<Session> sessionOpt = sessionRepository.findById(sessionId);
        if (sessionOpt.isEmpty()) {
            log.warn("Session not found with id: {} when updating on request created", sessionId);
            return;
        }

        Session session = sessionOpt.get();

        // Update total request count
        int currentTotal = session.getTotalRequests() != null ? session.getTotalRequests() : 0;
        session.setTotalRequests(currentTotal + 1);

        sessionRepository.save(session);
        log.info("Updated session {} on request created: totalRequests={}",
                sessionId, session.getTotalRequests());
    }
}
