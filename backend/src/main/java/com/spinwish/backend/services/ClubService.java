package com.spinwish.backend.services;

import com.spinwish.backend.entities.Club;
import com.spinwish.backend.repositories.ClubRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@Transactional
public class ClubService {

    @Autowired
    private ClubRepository clubRepository;

    // Create a new club
    public Club createClub(Club club) {
        // Validate required fields
        if (club.getName() == null || club.getName().trim().isEmpty()) {
            throw new RuntimeException("Club name is required");
        }

        // Check if club with same name already exists
        Optional<Club> existingClub = clubRepository.findByNameIgnoreCase(club.getName());
        if (existingClub.isPresent()) {
            throw new RuntimeException("Club with name '" + club.getName() + "' already exists");
        }

        // Set default values
        if (club.getIsActive() == null) {
            club.setIsActive(true);
        }

        return clubRepository.save(club);
    }

    // Get club by ID
    public Optional<Club> getClubById(UUID id) {
        return clubRepository.findById(id);
    }

    // Get all clubs
    public List<Club> getAllClubs() {
        return clubRepository.findAll();
    }

    // Get active clubs
    public List<Club> getActiveClubs() {
        return clubRepository.findByIsActiveTrue();
    }

    // Search clubs by name
    public List<Club> searchClubsByName(String name) {
        return clubRepository.findByNameContainingIgnoreCase(name);
    }

    // Search clubs by location
    public List<Club> searchClubsByLocation(String location) {
        return clubRepository.findByLocationContainingIgnoreCase(location);
    }

    // Get clubs by capacity range
    public List<Club> getClubsByCapacityRange(Integer minCapacity, Integer maxCapacity) {
        return clubRepository.findByCapacityBetween(minCapacity, maxCapacity);
    }

    // Get clubs in geographical area
    public List<Club> getClubsInArea(Double minLat, Double maxLat, Double minLng, Double maxLng) {
        return clubRepository.findClubsInArea(minLat, maxLat, minLng, maxLng);
    }

    // Update club
    public Club updateClub(UUID clubId, Club updatedClub) {
        Optional<Club> clubOpt = clubRepository.findById(clubId);
        if (clubOpt.isEmpty()) {
            throw new RuntimeException("Club not found with id: " + clubId);
        }

        Club club = clubOpt.get();

        // Update fields
        if (updatedClub.getName() != null && !updatedClub.getName().trim().isEmpty()) {
            // Check if new name conflicts with existing club
            Optional<Club> existingClub = clubRepository.findByNameIgnoreCase(updatedClub.getName());
            if (existingClub.isPresent() && !existingClub.get().getId().equals(clubId)) {
                throw new RuntimeException("Club with name '" + updatedClub.getName() + "' already exists");
            }
            club.setName(updatedClub.getName());
        }
        if (updatedClub.getLocation() != null) {
            club.setLocation(updatedClub.getLocation());
        }
        if (updatedClub.getAddress() != null) {
            club.setAddress(updatedClub.getAddress());
        }
        if (updatedClub.getDescription() != null) {
            club.setDescription(updatedClub.getDescription());
        }
        if (updatedClub.getImageUrl() != null) {
            club.setImageUrl(updatedClub.getImageUrl());
        }
        if (updatedClub.getPhoneNumber() != null) {
            club.setPhoneNumber(updatedClub.getPhoneNumber());
        }
        if (updatedClub.getEmail() != null) {
            club.setEmail(updatedClub.getEmail());
        }
        if (updatedClub.getWebsite() != null) {
            club.setWebsite(updatedClub.getWebsite());
        }
        if (updatedClub.getCapacity() != null) {
            club.setCapacity(updatedClub.getCapacity());
        }
        if (updatedClub.getIsActive() != null) {
            club.setIsActive(updatedClub.getIsActive());
        }
        if (updatedClub.getLatitude() != null) {
            club.setLatitude(updatedClub.getLatitude());
        }
        if (updatedClub.getLongitude() != null) {
            club.setLongitude(updatedClub.getLongitude());
        }

        return clubRepository.save(club);
    }

    // Activate club
    public Club activateClub(UUID clubId) {
        Optional<Club> clubOpt = clubRepository.findById(clubId);
        if (clubOpt.isEmpty()) {
            throw new RuntimeException("Club not found with id: " + clubId);
        }

        Club club = clubOpt.get();
        club.setIsActive(true);
        return clubRepository.save(club);
    }

    // Deactivate club
    public Club deactivateClub(UUID clubId) {
        Optional<Club> clubOpt = clubRepository.findById(clubId);
        if (clubOpt.isEmpty()) {
            throw new RuntimeException("Club not found with id: " + clubId);
        }

        Club club = clubOpt.get();
        club.setIsActive(false);
        return clubRepository.save(club);
    }

    // Delete club
    public void deleteClub(UUID clubId) {
        if (!clubRepository.existsById(clubId)) {
            throw new RuntimeException("Club not found with id: " + clubId);
        }
        clubRepository.deleteById(clubId);
    }

    // Get clubs with email
    public List<Club> getClubsWithEmail() {
        return clubRepository.findByEmailIsNotNull();
    }

    // Get clubs with website
    public List<Club> getClubsWithWebsite() {
        return clubRepository.findByWebsiteIsNotNull();
    }

    // Count active clubs
    public Long countActiveClubs() {
        return clubRepository.countActiveClubs();
    }

    // Check if club exists by name
    public boolean clubExistsByName(String name) {
        return clubRepository.findByNameIgnoreCase(name).isPresent();
    }
}
