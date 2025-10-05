package com.spinwish.backend.repositories;

import com.spinwish.backend.entities.Songs;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.UUID;

@Repository
public interface SongRepository extends JpaRepository<Songs, UUID> {
    boolean existsByNameAndArtistIdAndAlbum(String name, UUID artistId, String album);

}
