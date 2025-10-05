package com.spinwish.backend.repositories;

import com.spinwish.backend.entities.Club;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ClubRepository extends JpaRepository<Club, UUID> {

    // Find clubs by name (case-insensitive)
    @Query("SELECT c FROM Club c WHERE LOWER(c.name) LIKE LOWER(CONCAT('%', :name, '%'))")
    List<Club> findByNameContainingIgnoreCase(@Param("name") String name);

    // Find clubs by location
    @Query("SELECT c FROM Club c WHERE LOWER(c.location) LIKE LOWER(CONCAT('%', :location, '%'))")
    List<Club> findByLocationContainingIgnoreCase(@Param("location") String location);

    // Find active clubs
    List<Club> findByIsActiveTrue();

    // Find clubs by capacity range
    @Query("SELECT c FROM Club c WHERE c.capacity >= :minCapacity AND c.capacity <= :maxCapacity")
    List<Club> findByCapacityBetween(@Param("minCapacity") Integer minCapacity, 
                                   @Param("maxCapacity") Integer maxCapacity);

    // Find clubs within a geographical radius (simplified - would need more complex geo queries in production)
    @Query("SELECT c FROM Club c WHERE c.latitude IS NOT NULL AND c.longitude IS NOT NULL " +
           "AND c.latitude BETWEEN :minLat AND :maxLat " +
           "AND c.longitude BETWEEN :minLng AND :maxLng")
    List<Club> findClubsInArea(@Param("minLat") Double minLat, @Param("maxLat") Double maxLat,
                              @Param("minLng") Double minLng, @Param("maxLng") Double maxLng);

    // Find club by exact name
    Optional<Club> findByNameIgnoreCase(String name);

    // Find clubs with email
    List<Club> findByEmailIsNotNull();

    // Find clubs with website
    List<Club> findByWebsiteIsNotNull();

    // Count active clubs
    @Query("SELECT COUNT(c) FROM Club c WHERE c.isActive = true")
    Long countActiveClubs();
}
