const { test, expect } = require('@playwright/test');

test.describe('Songs API Tests', () => {
  const baseURL = 'http://localhost:8080/api/v1';
  let authToken = '';
  let artistId = '';
  let songId = '';

  test.beforeAll(async ({ request }) => {
    // Create role and user for authentication
    await request.post(`${baseURL}/roles`, {
      data: { roleName: 'CLIENT' }
    });

    const userResponse = await request.post(`${baseURL}/users/signup`, {
      data: {
        emailAddress: 'song-test@example.com',
        username: 'songtester',
        password: 'password123',
        roleName: 'CLIENT'
      }
    });

    const userData = await userResponse.json();

    // Login to get token
    const loginResponse = await request.post(`${baseURL}/users/login`, {
      data: {
        emailAddress: 'song-test@example.com',
        password: 'password123'
      }
    });
    const loginData = await loginResponse.json();
    authToken = loginData.token;

    // Create an artist for the songs
    const artistResponse = await request.post(`${baseURL}/artists`, {
      headers: {
        'Authorization': `Bearer ${authToken}`
      },
      multipart: {
        name: 'Song Test Artist',
        bio: 'Artist for song testing'
      }
    });

    const artistData = await artistResponse.json();
    artistId = artistData.id;
  });

  test('should create a new song', async ({ request }) => {
    const response = await request.post(`${baseURL}/songs`, {
      headers: {
        'Authorization': `Bearer ${authToken}`,
        'Content-Type': 'application/json'
      },
      data: {
        name: 'Test Song',
        artistId: artistId,
        album: 'Test Album'
      }
    });

    expect(response.status()).toBe(201);
    const responseBody = await response.json();
    
    expect(responseBody).toHaveProperty('id');
    expect(responseBody).toHaveProperty('name', 'Test Song');
    expect(responseBody).toHaveProperty('artistId', artistId);
    expect(responseBody).toHaveProperty('album', 'Test Album');
    
    songId = responseBody.id;
    console.log('Song created successfully:', responseBody);
  });

  test('should get all songs', async ({ request }) => {
    const response = await request.get(`${baseURL}/songs`, {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    });

    expect(response.status()).toBe(200);
    const songs = await response.json();
    expect(Array.isArray(songs)).toBeTruthy();
    expect(songs.length).toBeGreaterThan(0);
    
    console.log('Retrieved songs:', songs);
  });

  test('should get song by ID', async ({ request }) => {
    const response = await request.get(`${baseURL}/songs/${songId}`, {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    });

    expect(response.status()).toBe(200);
    const song = await response.json();
    
    expect(song).toHaveProperty('id', songId);
    expect(song).toHaveProperty('name', 'Test Song');
    expect(song).toHaveProperty('artistId', artistId);
    expect(song).toHaveProperty('album', 'Test Album');
    
    console.log('Retrieved song by ID:', song);
  });

  test('should update song', async ({ request }) => {
    const response = await request.put(`${baseURL}/songs/${songId}`, {
      headers: {
        'Authorization': `Bearer ${authToken}`,
        'Content-Type': 'application/json'
      },
      data: {
        name: 'Updated Test Song',
        artistId: artistId,
        album: 'Updated Test Album'
      }
    });

    expect(response.status()).toBe(200);
    const updatedSong = await response.json();
    
    expect(updatedSong).toHaveProperty('name', 'Updated Test Song');
    expect(updatedSong).toHaveProperty('album', 'Updated Test Album');
    
    console.log('Song updated successfully:', updatedSong);
  });

  test('should delete song', async ({ request }) => {
    const response = await request.delete(`${baseURL}/songs/${songId}`, {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    });

    expect(response.status()).toBe(204);
    console.log('Song deleted successfully');
  });

  test('should fail to create song without authentication', async ({ request }) => {
    const response = await request.post(`${baseURL}/songs`, {
      headers: {
        'Content-Type': 'application/json'
      },
      data: {
        name: 'Unauthorized Song',
        artistId: artistId,
        album: 'Unauthorized Album'
      }
    });

    expect(response.status()).toBe(401);
  });

  test('should fail to create song with invalid artist ID', async ({ request }) => {
    const response = await request.post(`${baseURL}/songs`, {
      headers: {
        'Authorization': `Bearer ${authToken}`,
        'Content-Type': 'application/json'
      },
      data: {
        name: 'Invalid Artist Song',
        artistId: '00000000-0000-0000-0000-000000000000',
        album: 'Test Album'
      }
    });

    expect(response.status()).toBe(400);
  });
});
