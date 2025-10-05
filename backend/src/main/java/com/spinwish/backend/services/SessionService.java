package com.spinwish.backend.services;

import com.spinwish.backend.entities.Session;
import com.spinwish.backend.entities.Users;
import com.spinwish.backend.repositories.SessionRepository;
import com.spinwish.backend.repositories.UsersRepository;
import jakarta.annotation.PostConstruct;
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
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class SessionService {

    @Autowired
    private SessionRepository sessionRepository;

    @Autowired
    private UsersRepository usersRepository;

    private final Path rootLocation = Paths.get("uploads/session-images");

    @PostConstruct
    public void init() {
        try {
            Files.createDirectories(rootLocation);
        } catch (IOException e) {
            throw new RuntimeException("Could not initialize folder for session image uploads!");
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

        // Save session first to generate ID
        Session savedSession = sessionRepository.save(session);

        // Generate shareable link after ID is available
        if (savedSession.getShareableLink() == null) {
            savedSession.setShareableLink(generateShareableLink(savedSession.getId()));
            savedSession = sessionRepository.save(savedSession);
        }

        return savedSession;
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
        Optional<Session> sessionOpt = sessionRepository.findById(sessionId);
        if (sessionOpt.isEmpty()) {
            throw new RuntimeException("Session not found with id: " + sessionId);
        }

        Session session = sessionOpt.get();

        // Validate image file
        validateImageFile(imageFile);

        String originalFilename = imageFile.getOriginalFilename();
        if (originalFilename == null || originalFilename.trim().isEmpty()) {
            throw new RuntimeException("Invalid filename");
        }

        String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
        String newFileName = UUID.randomUUID() + fileExtension;

        Path destinationFile = this.rootLocation.resolve(Paths.get(newFileName)).normalize().toAbsolutePath();

        // Ensure the path is within the upload directory (security check)
        if (!destinationFile.getParent().equals(this.rootLocation.toAbsolutePath())) {
            throw new RuntimeException("Cannot store file outside current directory.");
        }

        Files.copy(imageFile.getInputStream(), destinationFile, StandardCopyOption.REPLACE_EXISTING);

        session.setImageUrl("/uploads/session-images/" + newFileName);
        session.setThumbnailUrl("/uploads/session-images/" + newFileName); // For now, use same image

        return sessionRepository.save(session);
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
}
