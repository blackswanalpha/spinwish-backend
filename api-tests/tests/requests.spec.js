const { test, expect } = require('@playwright/test');

test.describe('Song Requests API Tests', () => {
  const baseURL = 'http://localhost:8080/api/v1';
  let authToken = '';
  let artistId = '';
  let songId = '';
  let requestId = '';

  test.beforeAll(async ({ request }) => {
    // Create role and user for authentication
    await request.post(`${baseURL}/roles`, {
      data: { roleName: 'CLIENT' }
    });

    const userResponse = await request.post(`${baseURL}/users/signup`, {
      data: {
        emailAddress: 'request-test@example.com',
        username: 'requesttester',
        password: 'password123',
        roleName: 'CLIENT'
      }
    });

    const userData = await userResponse.json();

    // Login to get token
    const loginResponse = await request.post(`${baseURL}/users/login`, {
      data: {
        emailAddress: 'request-test@example.com',
        password: 'password123'
      }
    });
    const loginData = await loginResponse.json();
    authToken = loginData.token;

    // Create an artist
    const artistResponse = await request.post(`${baseURL}/artists`, {
      headers: {
        'Authorization': `Bearer ${authToken}`
      },
      multipart: {
        name: 'Request Test Artist',
        bio: 'Artist for request testing'
      }
    });

    const artistData = await artistResponse.json();
    artistId = artistData.id;

    // Create a song
    const songResponse = await request.post(`${baseURL}/songs`, {
      headers: {
        'Authorization': `Bearer ${authToken}`,
        'Content-Type': 'application/json'
      },
      data: {
        name: 'Request Test Song',
        artistId: artistId,
        album: 'Request Test Album'
      }
    });

    const songData = await songResponse.json();
    songId = songData.id;
  });

  test('should create a song request', async ({ request }) => {
    // First create a DJ user to send requests to
    await request.post(`${baseURL}/users/signup`, {
      data: {
        emailAddress: 'dj-for-requests@example.com',
        username: 'djforrequests',
        password: 'password123',
        roleName: 'DJ'
      }
    });

    const response = await request.post(`${baseURL}/requests`, {
      headers: {
        'Authorization': `Bearer ${authToken}`,
        'Content-Type': 'application/json'
      },
      data: {
        djEmailAddress: 'dj-for-requests@example.com',
        songId: songId
      }
    });

    expect(response.status()).toBe(201);
    const responseBody = await response.json();

    expect(responseBody).toHaveProperty('id');
    expect(responseBody).toHaveProperty('songResponse');
    expect(responseBody.songResponse[0]).toHaveProperty('id', songId);

    requestId = responseBody.id;
    console.log('Song request created successfully:', responseBody);
  });

  test('should get all requests', async ({ request }) => {
    const response = await request.get(`${baseURL}/requests`, {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    });

    expect(response.status()).toBe(200);
    const requests = await response.json();
    expect(Array.isArray(requests)).toBeTruthy();
    expect(requests.length).toBeGreaterThan(0);
    
    console.log('Retrieved requests:', requests);
  });

  test('should get request by ID', async ({ request }) => {
    const response = await request.get(`${baseURL}/requests/${requestId}`, {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    });

    expect(response.status()).toBe(200);
    const songRequest = await response.json();
    
    expect(songRequest).toHaveProperty('id', requestId);
    expect(songRequest).toHaveProperty('songId', songId);
    expect(songRequest).toHaveProperty('message', 'Please play this song!');
    
    console.log('Retrieved request by ID:', songRequest);
  });

  test('should update request status', async ({ request }) => {
    const response = await request.put(`${baseURL}/requests/${requestId}`, {
      headers: {
        'Authorization': `Bearer ${authToken}`,
        'Content-Type': 'application/json'
      },
      data: {
        djEmailAddress: 'dj-for-requests@example.com',
        songId: songId
      }
    });

    expect(response.status()).toBe(200);
    const updatedRequest = await response.json();

    expect(updatedRequest).toHaveProperty('id', requestId);
    expect(updatedRequest).toHaveProperty('songResponse');

    console.log('Request updated successfully:', updatedRequest);
  });

  test('should fail to create request without authentication', async ({ request }) => {
    const response = await request.post(`${baseURL}/requests`, {
      headers: {
        'Content-Type': 'application/json'
      },
      data: {
        djEmailAddress: 'dj-for-requests@example.com',
        songId: songId
      }
    });

    expect(response.status()).toBe(401);
  });

  test('should fail to create request with invalid DJ email', async ({ request }) => {
    const response = await request.post(`${baseURL}/requests`, {
      headers: {
        'Authorization': `Bearer ${authToken}`,
        'Content-Type': 'application/json'
      },
      data: {
        djEmailAddress: 'nonexistent@example.com',
        songId: songId
      }
    });

    expect(response.status()).toBe(404);
  });

  test('should fail to create request without song ID', async ({ request }) => {
    const response = await request.post(`${baseURL}/requests`, {
      headers: {
        'Authorization': `Bearer ${authToken}`,
        'Content-Type': 'application/json'
      },
      data: {
        djEmailAddress: 'dj-for-requests@example.com'
        // Missing songId
      }
    });

    expect(response.status()).toBe(500);
  });
});
