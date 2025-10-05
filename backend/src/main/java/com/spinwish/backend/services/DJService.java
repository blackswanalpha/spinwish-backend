package com.spinwish.backend.services;

import com.spinwish.backend.entities.Users;
import com.spinwish.backend.entities.Roles;
import com.spinwish.backend.repositories.UsersRepository;
import com.spinwish.backend.repositories.RoleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class DJService {

    @Autowired
    private UsersRepository usersRepository;

    @Autowired
    private RoleRepository roleRepository;

    // Get all DJs
    public List<Users> getAllDJs() {
        Roles djRole = roleRepository.findByRoleName("DJ");
        if (djRole == null) {
            throw new RuntimeException("DJ role not found");
        }
        return usersRepository.findAll().stream()
                .filter(user -> user.getRole() != null && "DJ".equals(user.getRole().getRoleName()))
                .collect(Collectors.toList());
    }

    // Get DJ by ID
    public Optional<Users> getDJById(UUID djId) {
        Optional<Users> user = usersRepository.findById(djId);
        if (user.isPresent() && isDJ(user.get())) {
            return user;
        }
        return Optional.empty();
    }

    // Get live DJs
    public List<Users> getLiveDJs() {
        return getAllDJs().stream()
                .filter(dj -> dj.getIsLive() != null && dj.getIsLive())
                .collect(Collectors.toList());
    }

    // Get DJs by genre
    public List<Users> getDJsByGenre(String genre) {
        return getAllDJs().stream()
                .filter(dj -> dj.getGenres() != null && dj.getGenres().contains(genre))
                .collect(Collectors.toList());
    }

    // Get top rated DJs
    public List<Users> getTopRatedDJs(int limit) {
        return getAllDJs().stream()
                .filter(dj -> dj.getRating() != null)
                .sorted((dj1, dj2) -> Double.compare(dj2.getRating(), dj1.getRating()))
                .limit(limit)
                .collect(Collectors.toList());
    }

    // Get DJs with most followers
    public List<Users> getMostFollowedDJs(int limit) {
        return getAllDJs().stream()
                .sorted((dj1, dj2) -> Integer.compare(dj2.getFollowers(), dj1.getFollowers()))
                .limit(limit)
                .collect(Collectors.toList());
    }

    // Update DJ profile
    public Users updateDJProfile(UUID djId, Users updatedDJ) {
        Optional<Users> djOpt = getDJById(djId);
        if (djOpt.isEmpty()) {
            throw new RuntimeException("DJ not found with id: " + djId);
        }

        Users dj = djOpt.get();

        // Update DJ-specific fields
        if (updatedDJ.getBio() != null) {
            dj.setBio(updatedDJ.getBio());
        }
        if (updatedDJ.getProfileImage() != null) {
            dj.setProfileImage(updatedDJ.getProfileImage());
        }
        if (updatedDJ.getGenres() != null) {
            dj.setGenres(updatedDJ.getGenres());
        }
        if (updatedDJ.getInstagramHandle() != null) {
            dj.setInstagramHandle(updatedDJ.getInstagramHandle());
        }
        if (updatedDJ.getActualUsername() != null) {
            dj.setActualUsername(updatedDJ.getActualUsername());
        }

        return usersRepository.save(dj);
    }

    // Set DJ live status
    public Users setDJLiveStatus(UUID djId, boolean isLive) {
        Optional<Users> djOpt = getDJById(djId);
        if (djOpt.isEmpty()) {
            throw new RuntimeException("DJ not found with id: " + djId);
        }

        Users dj = djOpt.get();
        dj.setIsLive(isLive);
        return usersRepository.save(dj);
    }

    // Update DJ rating
    public Users updateDJRating(UUID djId, double newRating) {
        Optional<Users> djOpt = getDJById(djId);
        if (djOpt.isEmpty()) {
            throw new RuntimeException("DJ not found with id: " + djId);
        }

        Users dj = djOpt.get();
        
        // Simple rating update - in production, you might want to calculate average from multiple ratings
        if (newRating >= 0.0 && newRating <= 5.0) {
            dj.setRating(newRating);
        } else {
            throw new RuntimeException("Rating must be between 0.0 and 5.0");
        }

        return usersRepository.save(dj);
    }

    // Add follower to DJ
    public Users addFollower(UUID djId) {
        Optional<Users> djOpt = getDJById(djId);
        if (djOpt.isEmpty()) {
            throw new RuntimeException("DJ not found with id: " + djId);
        }

        Users dj = djOpt.get();
        int currentFollowers = dj.getFollowers() != null ? dj.getFollowers() : 0;
        dj.setFollowers(currentFollowers + 1);
        return usersRepository.save(dj);
    }

    // Remove follower from DJ
    public Users removeFollower(UUID djId) {
        Optional<Users> djOpt = getDJById(djId);
        if (djOpt.isEmpty()) {
            throw new RuntimeException("DJ not found with id: " + djId);
        }

        Users dj = djOpt.get();
        int currentFollowers = dj.getFollowers() != null ? dj.getFollowers() : 0;
        if (currentFollowers > 0) {
            dj.setFollowers(currentFollowers - 1);
        }
        return usersRepository.save(dj);
    }

    // Search DJs by name
    public List<Users> searchDJsByName(String name) {
        return getAllDJs().stream()
                .filter(dj -> dj.getActualUsername().toLowerCase().contains(name.toLowerCase()))
                .collect(Collectors.toList());
    }

    // Get DJs by rating range
    public List<Users> getDJsByRatingRange(double minRating, double maxRating) {
        return getAllDJs().stream()
                .filter(dj -> dj.getRating() != null && 
                             dj.getRating() >= minRating && 
                             dj.getRating() <= maxRating)
                .collect(Collectors.toList());
    }

    // Get DJs by follower count range
    public List<Users> getDJsByFollowerRange(int minFollowers, int maxFollowers) {
        return getAllDJs().stream()
                .filter(dj -> dj.getFollowers() >= minFollowers && 
                             dj.getFollowers() <= maxFollowers)
                .collect(Collectors.toList());
    }

    // Get current authenticated user's DJ profile
    public Users getCurrentDJProfile() {
        String emailAddress = SecurityContextHolder.getContext().getAuthentication().getName();
        Users user = usersRepository.findByEmailAddress(emailAddress);

        if (user == null) {
            throw new RuntimeException("User not found");
        }

        if (!isDJ(user)) {
            throw new RuntimeException("Current user is not a DJ");
        }

        return user;
    }

    // Check if user is a DJ
    private boolean isDJ(Users user) {
        return user.getRole() != null && "DJ".equals(user.getRole().getRoleName());
    }

    // Get DJ statistics
    public DJStats getDJStats(UUID djId) {
        Optional<Users> djOpt = getDJById(djId);
        if (djOpt.isEmpty()) {
            throw new RuntimeException("DJ not found with id: " + djId);
        }

        Users dj = djOpt.get();

        // TODO: Calculate actual earnings from payments
        double totalEarnings = 0.0; // Placeholder until earnings service is integrated
        int totalSessions = 0; // Placeholder until session counting is implemented
        int totalRequests = 0; // Placeholder until request counting is implemented

        return new DJStats(
            dj.getId(),
            dj.getActualUsername(),
            dj.getFollowers(),
            dj.getRating(),
            dj.getIsLive(),
            dj.getGenres() != null ? dj.getGenres().size() : 0,
            totalEarnings,
            totalSessions,
            totalRequests
        );
    }

    // Inner class for DJ statistics
    public static class DJStats {
        private UUID djId;
        private String username;
        private Integer followers;
        private Double rating;
        private Boolean isLive;
        private Integer genreCount;
        private Double totalEarnings;
        private Integer totalSessions;
        private Integer totalRequests;

        public DJStats(UUID djId, String username, Integer followers, Double rating, Boolean isLive,
                      Integer genreCount, Double totalEarnings, Integer totalSessions, Integer totalRequests) {
            this.djId = djId;
            this.username = username;
            this.followers = followers;
            this.rating = rating;
            this.isLive = isLive;
            this.genreCount = genreCount;
            this.totalEarnings = totalEarnings;
            this.totalSessions = totalSessions;
            this.totalRequests = totalRequests;
        }

        // Getters
        public UUID getDjId() { return djId; }
        public String getUsername() { return username; }
        public Integer getFollowers() { return followers; }
        public Double getRating() { return rating; }
        public Boolean getIsLive() { return isLive; }
        public Integer getGenreCount() { return genreCount; }
        public Double getTotalEarnings() { return totalEarnings; }
        public Integer getTotalSessions() { return totalSessions; }
        public Integer getTotalRequests() { return totalRequests; }
        public Double getAverageRating() { return rating; } // Alias for compatibility
        public Integer getSongsPlayed() { return 0; } // Placeholder
    }
}
