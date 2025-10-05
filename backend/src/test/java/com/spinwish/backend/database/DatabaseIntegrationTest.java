package com.spinwish.backend.database;

import com.spinwish.backend.entities.*;
import com.spinwish.backend.repositories.*;
// import com.spinwish.backend.services.DatabaseVerificationService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Integration tests for database operations and PostgreSQL connectivity
 */
@SpringBootTest
@ActiveProfiles("test")
@Transactional
class DatabaseIntegrationTest {

    @Autowired
    private DataSource dataSource;



    @Autowired
    private UsersRepository usersRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private ArtistRepository artistRepository;

    @Autowired
    private SongRepository songRepository;

    @Autowired
    private RequestsRepository requestsRepository;

    @Autowired
    private ProfileRepository profileRepository;

    @Autowired
    private ClubRepository clubRepository;

    @Autowired
    private SessionRepository sessionRepository;

    @Test
    void testDatabaseConnection() throws Exception {
        try (Connection connection = dataSource.getConnection()) {
            assertTrue(connection.isValid(5));
            
            DatabaseMetaData metaData = connection.getMetaData();
            assertNotNull(metaData.getDatabaseProductName());
            assertNotNull(metaData.getURL());
            
            // In test environment, might be H2, but in production should be PostgreSQL
            String dbProduct = metaData.getDatabaseProductName().toLowerCase();
            assertTrue(dbProduct.contains("postgresql") || dbProduct.contains("h2"));
        }
    }

    @Test
    void testRepositoryOperations() {
        // Test that repositories are properly injected and can perform basic operations
        assertNotNull(usersRepository);
        assertNotNull(roleRepository);
        assertNotNull(artistRepository);
        assertNotNull(songRepository);

        // Test count operations (should not throw exceptions)
        assertDoesNotThrow(() -> {
            long userCount = usersRepository.count();
            long roleCount = roleRepository.count();
            long artistCount = artistRepository.count();
            long songCount = songRepository.count();

            // Counts should be non-negative
            assertTrue(userCount >= 0);
            assertTrue(roleCount >= 0);
            assertTrue(artistCount >= 0);
            assertTrue(songCount >= 0);
        });
    }

    @Test
    void testUserEntityPersistence() {
        // Create and save a role
        Roles testRole = new Roles();
        testRole.setRoleName("TEST_ROLE_" + System.currentTimeMillis());
        testRole.setDescription("Test role");
        Roles savedRole = roleRepository.save(testRole);
        
        assertNotNull(savedRole.getId());
        assertEquals(testRole.getRoleName(), savedRole.getRoleName());

        // Create and save a user
        Users testUser = new Users();
        testUser.setEmailAddress("test" + System.currentTimeMillis() + "@example.com");
        testUser.setActualUsername("testuser" + System.currentTimeMillis());
        testUser.setPassword("testpassword");
        testUser.setPhoneNumber("+254700" + (System.currentTimeMillis() % 1000000));
        testUser.setRole(savedRole);
        testUser.setEmailVerified(true);
        testUser.setPhoneVerified(true);
        
        Users savedUser = usersRepository.save(testUser);
        
        assertNotNull(savedUser.getId());
        assertEquals(testUser.getEmailAddress(), savedUser.getEmailAddress());
        assertEquals(savedRole.getId(), savedUser.getRole().getId());

        // Verify retrieval
        Optional<Users> retrievedUser = usersRepository.findById(savedUser.getId());
        assertTrue(retrievedUser.isPresent());
        assertEquals(savedUser.getEmailAddress(), retrievedUser.get().getEmailAddress());
    }

    @Test
    void testArtistAndSongPersistence() {
        // Create and save an artist
        Artists testArtist = new Artists();
        testArtist.setArtistName("Test Artist " + System.currentTimeMillis());
        testArtist.setGenre("Test Genre");
        testArtist.setCountry("Kenya");
        testArtist.setImageUrl("https://example.com/test-image.jpg");
        
        Artists savedArtist = artistRepository.save(testArtist);
        
        assertNotNull(savedArtist.getId());
        assertEquals(testArtist.getArtistName(), savedArtist.getArtistName());

        // Create and save a song
        Songs testSong = new Songs();
        testSong.setTitle("Test Song " + System.currentTimeMillis());
        testSong.setArtist(savedArtist);
        testSong.setGenre("Test Genre");
        testSong.setDuration(180);
        testSong.setReleaseYear(2024);
        testSong.setAudioUrl("https://example.com/test-song.mp3");
        testSong.setImageUrl("https://example.com/test-song-image.jpg");
        
        Songs savedSong = songRepository.save(testSong);
        
        assertNotNull(savedSong.getId());
        assertEquals(testSong.getTitle(), savedSong.getTitle());
        assertEquals(savedArtist.getId(), savedSong.getArtist().getId());

        // Verify retrieval with relationship
        Optional<Songs> retrievedSong = songRepository.findById(savedSong.getId());
        assertTrue(retrievedSong.isPresent());
        assertNotNull(retrievedSong.get().getArtist());
        assertEquals(savedArtist.getArtistName(), retrievedSong.get().getArtist().getArtistName());
    }

    @Test
    void testProfilePersistence() {
        // Create user first
        Roles testRole = new Roles();
        testRole.setRoleName("TEST_ROLE_" + System.currentTimeMillis());
        testRole.setDescription("Test role");
        Roles savedRole = roleRepository.save(testRole);

        Users testUser = new Users();
        testUser.setEmailAddress("test" + System.currentTimeMillis() + "@example.com");
        testUser.setActualUsername("testuser" + System.currentTimeMillis());
        testUser.setPassword("testpassword");
        testUser.setPhoneNumber("+254700" + (System.currentTimeMillis() % 1000000));
        testUser.setRole(savedRole);
        testUser.setEmailVerified(true);
        testUser.setPhoneVerified(true);
        Users savedUser = usersRepository.save(testUser);

        // Create and save profile
        Profile testProfile = new Profile();
        testProfile.setUser(savedUser);
        testProfile.setFirstName("Test");
        testProfile.setLastName("User");
        testProfile.setDateOfBirth(LocalDateTime.now().minusYears(25));
        testProfile.setGender("Other");
        testProfile.setCounty("Test County");
        testProfile.setGenres(Arrays.asList("Rock", "Pop"));
        
        Profile savedProfile = profileRepository.save(testProfile);
        
        assertNotNull(savedProfile.getId());
        assertEquals(testProfile.getFirstName(), savedProfile.getFirstName());
        assertEquals(savedUser.getId(), savedProfile.getUser().getId());
        assertNotNull(savedProfile.getGenres());
        assertEquals(2, savedProfile.getGenres().size());
    }

    @Test
    void testComplexEntityRelationships() {
        // Create all required entities for a complete request
        
        // 1. Create role
        Roles djRole = new Roles();
        djRole.setRoleName("DJ_" + System.currentTimeMillis());
        djRole.setDescription("DJ role");
        Roles savedDjRole = roleRepository.save(djRole);

        // 2. Create users (client and DJ)
        Users client = new Users();
        client.setEmailAddress("client" + System.currentTimeMillis() + "@example.com");
        client.setActualUsername("client" + System.currentTimeMillis());
        client.setPassword("password");
        client.setPhoneNumber("+254700" + (System.currentTimeMillis() % 1000000));
        client.setRole(savedDjRole);
        client.setEmailVerified(true);
        client.setPhoneVerified(true);
        Users savedClient = usersRepository.save(client);

        Users dj = new Users();
        dj.setEmailAddress("dj" + System.currentTimeMillis() + "@example.com");
        dj.setActualUsername("dj" + System.currentTimeMillis());
        dj.setPassword("password");
        dj.setPhoneNumber("+254701" + (System.currentTimeMillis() % 1000000));
        dj.setRole(savedDjRole);
        dj.setEmailVerified(true);
        dj.setPhoneVerified(true);
        Users savedDj = usersRepository.save(dj);

        // 3. Create artist and song
        Artists artist = new Artists();
        artist.setArtistName("Test Artist " + System.currentTimeMillis());
        artist.setGenre("Pop");
        artist.setCountry("Kenya");
        Artists savedArtist = artistRepository.save(artist);

        Songs song = new Songs();
        song.setTitle("Test Song " + System.currentTimeMillis());
        song.setArtist(savedArtist);
        song.setGenre("Pop");
        song.setDuration(200);
        song.setReleaseYear(2024);
        Songs savedSong = songRepository.save(song);

        // 4. Create club
        Club club = new Club();
        club.setClubName("Test Club " + System.currentTimeMillis());
        club.setLocation("Test Location");
        club.setDescription("Test club");
        Club savedClub = clubRepository.save(club);

        // 5. Create session
        Session session = new Session();
        session.setSessionName("Test Session " + System.currentTimeMillis());
        session.setDj(savedDj);
        session.setClub(savedClub);
        session.setStartTime(LocalDateTime.now());
        session.setEndTime(LocalDateTime.now().plusHours(4));
        session.setIsActive(true);
        Session savedSession = sessionRepository.save(session);

        // 6. Create request
        Request request = new Request();
        request.setClient(savedClient);
        request.setDj(savedDj);
        request.setSong(savedSong);
        request.setSession(savedSession);
        request.setRequestTime(LocalDateTime.now());
        request.setStatus("PENDING");
        request.setMessage("Test request");
        Request savedRequest = requestsRepository.save(request);

        // Verify all relationships
        assertNotNull(savedRequest.getId());
        assertEquals(savedClient.getId(), savedRequest.getClient().getId());
        assertEquals(savedDj.getId(), savedRequest.getDj().getId());
        assertEquals(savedSong.getId(), savedRequest.getSong().getId());
        assertEquals(savedSession.getId(), savedRequest.getSession().getId());
        assertEquals(savedArtist.getId(), savedRequest.getSong().getArtist().getId());
        assertEquals(savedClub.getId(), savedRequest.getSession().getClub().getId());

        // Verify retrieval with all relationships
        Optional<Request> retrievedRequest = requestsRepository.findById(savedRequest.getId());
        assertTrue(retrievedRequest.isPresent());
        
        Request fullRequest = retrievedRequest.get();
        assertNotNull(fullRequest.getClient());
        assertNotNull(fullRequest.getDj());
        assertNotNull(fullRequest.getSong());
        assertNotNull(fullRequest.getSession());
        assertNotNull(fullRequest.getSong().getArtist());
        assertNotNull(fullRequest.getSession().getClub());
    }
}
