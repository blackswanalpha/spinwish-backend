const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

test.describe('Artists API Tests', () => {
  const baseURL = 'http://localhost:8080/api/v1';
  let authToken = '';
  let artistId = '';

  test.beforeAll(async ({ request }) => {
    // Create role and user for authentication
    await request.post(`${baseURL}/roles`, {
      data: { roleName: 'CLIENT' }
    });

    const userResponse = await request.post(`${baseURL}/users/signup`, {
      data: {
        emailAddress: 'artist-test@example.com',
        username: 'artisttester',
        password: 'password123',
        roleName: 'CLIENT'
      }
    });

    const userData = await userResponse.json();

    // Login to get token
    const loginResponse = await request.post(`${baseURL}/users/login`, {
      data: {
        emailAddress: 'artist-test@example.com',
        password: 'password123'
      }
    });
    const loginData = await loginResponse.json();
    authToken = loginData.token;
  });

  test('should create a new artist', async ({ request }) => {
    const response = await request.post(`${baseURL}/artists`, {
      headers: {
        'Authorization': `Bearer ${authToken}`
      },
      multipart: {
        name: 'Test Artist',
        bio: 'A test artist for API testing',
        // Note: In a real test, you'd include an actual image file
        // image: fs.createReadStream(path.join(__dirname, 'test-image.jpg'))
      }
    });

    expect(response.status()).toBe(200);
    const responseBody = await response.json();
    
    expect(responseBody).toHaveProperty('id');
    expect(responseBody).toHaveProperty('name', 'Test Artist');
    expect(responseBody).toHaveProperty('bio', 'A test artist for API testing');
    
    artistId = responseBody.id;
    console.log('Artist created successfully:', responseBody);
  });

  test('should get all artists', async ({ request }) => {
    const response = await request.get(`${baseURL}/artists`, {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    });

    expect(response.status()).toBe(200);
    const artists = await response.json();
    expect(Array.isArray(artists)).toBeTruthy();
    expect(artists.length).toBeGreaterThan(0);
    
    console.log('Retrieved artists:', artists);
  });

  test('should get artist by ID', async ({ request }) => {
    const response = await request.get(`${baseURL}/artists/${artistId}`, {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    });

    expect(response.status()).toBe(200);
    const artist = await response.json();
    
    expect(artist).toHaveProperty('id', artistId);
    expect(artist).toHaveProperty('name', 'Test Artist');
    expect(artist).toHaveProperty('bio', 'A test artist for API testing');
    
    console.log('Retrieved artist by ID:', artist);
  });

  test('should update artist', async ({ request }) => {
    const response = await request.put(`${baseURL}/artists/${artistId}`, {
      headers: {
        'Authorization': `Bearer ${authToken}`
      },
      multipart: {
        name: 'Updated Test Artist',
        bio: 'Updated bio for test artist'
      }
    });

    expect(response.status()).toBe(200);
    const updatedArtist = await response.json();
    
    expect(updatedArtist).toHaveProperty('name', 'Updated Test Artist');
    expect(updatedArtist).toHaveProperty('bio', 'Updated bio for test artist');
    
    console.log('Artist updated successfully:', updatedArtist);
  });

  test('should fail to create artist without authentication', async ({ request }) => {
    const response = await request.post(`${baseURL}/artists`, {
      multipart: {
        name: 'Unauthorized Artist',
        bio: 'This should fail'
      }
    });

    expect(response.status()).toBe(401);
  });

  test('should fail to get non-existent artist', async ({ request }) => {
    const fakeId = '00000000-0000-0000-0000-000000000000';
    const response = await request.get(`${baseURL}/artists/${fakeId}`, {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    });

    expect(response.status()).toBe(404);
  });
});
