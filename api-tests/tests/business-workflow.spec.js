const { test, expect } = require('@playwright/test');

test.describe('Complete Business Workflow Tests', () => {
  const baseURL = 'http://localhost:8080/api/v1';
  let clientToken = '';
  let djToken = '';
  let artistId = '';
  let songId = '';
  let requestId = '';
  let timestamp = '';

  test.beforeAll(async ({ request }) => {
    // Roles are automatically created by DataInitializer
    console.log('Roles should already exist from DataInitializer');
  });

  test('Complete SpinWish Workflow: User Registration → Artist Creation → Song Addition → Song Request → Payment', async ({ request }) => {

    timestamp = Date.now();

    // Step 1: Register a CLIENT user
    console.log('Step 1: Registering CLIENT user...');
    const clientResponse = await request.post(`${baseURL}/users/signup`, {
      data: {
        emailAddress: `client${timestamp}@spinwish.com`,
        username: `musiclover${timestamp}`,
        password: 'password123',
        roleName: 'CLIENT'
      }
    });
    
    expect(clientResponse.status()).toBe(201);
    const clientData = await clientResponse.json();
    console.log('✅ CLIENT user registered successfully');

    // Login to get token
    const clientLoginResponse = await request.post(`${baseURL}/users/login`, {
      data: {
        emailAddress: `client${timestamp}@spinwish.com`,
        password: 'password123'
      }
    });
    expect(clientLoginResponse.status()).toBe(200);
    const clientLoginData = await clientLoginResponse.json();
    clientToken = clientLoginData.token;

    // Step 2: Register a DJ user
    console.log('Step 2: Registering DJ user...');
    const djResponse = await request.post(`${baseURL}/users/signup`, {
      data: {
        emailAddress: `dj${timestamp}@spinwish.com`,
        username: `djmaster${timestamp}`,
        password: 'password123',
        roleName: 'DJ'
      }
    });
    
    expect(djResponse.status()).toBe(201);
    const djData = await djResponse.json();
    console.log('✅ DJ user registered successfully');

    // Login to get token
    const djLoginResponse = await request.post(`${baseURL}/users/login`, {
      data: {
        emailAddress: `dj${timestamp}@spinwish.com`,
        password: 'password123'
      }
    });
    expect(djLoginResponse.status()).toBe(200);
    const djLoginData = await djLoginResponse.json();
    djToken = djLoginData.token;

    // Step 3: DJ creates an artist
    console.log('Step 3: DJ creating an artist...');
    const artistResponse = await request.post(`${baseURL}/artists`, {
      headers: {
        'Authorization': `Bearer ${djToken}`
      },
      multipart: {
        name: `The Weeknd ${timestamp}`,
        bio: 'Canadian singer, songwriter, and record producer'
      }
    });
    
    expect(artistResponse.status()).toBe(200);
    const artistData = await artistResponse.json();
    artistId = artistData.id;
    console.log('✅ Artist created successfully:', artistData.name);

    // Step 4: DJ adds a song
    console.log('Step 4: DJ adding a song...');
    const songResponse = await request.post(`${baseURL}/songs`, {
      headers: {
        'Authorization': `Bearer ${djToken}`,
        'Content-Type': 'application/json'
      },
      data: {
        name: 'Blinding Lights',
        artistId: artistId,
        album: 'After Hours'
      }
    });
    
    expect(songResponse.status()).toBe(201);
    const songData = await songResponse.json();
    songId = songData.id;
    console.log('✅ Song added successfully:', songData.name);

    // Step 5: Client browses available songs
    console.log('Step 5: Client browsing available songs...');
    const songsListResponse = await request.get(`${baseURL}/songs`, {
      headers: {
        'Authorization': `Bearer ${clientToken}`
      }
    });
    
    expect(songsListResponse.status()).toBe(200);
    const songs = await songsListResponse.json();
    expect(songs.length).toBeGreaterThan(0);
    console.log('✅ Client can see available songs:', songs.length, 'songs found');

    // Step 6: Client makes a song request
    console.log('Step 6: Client making a song request...');
    const requestResponse = await request.post(`${baseURL}/requests`, {
      headers: {
        'Authorization': `Bearer ${clientToken}`,
        'Content-Type': 'application/json'
      },
      data: {
        djEmailAddress: `dj${timestamp}@spinwish.com`,
        songId: songId
      }
    });
    
    expect(requestResponse.status()).toBe(201);
    const requestData = await requestResponse.json();
    requestId = requestData.id;
    console.log('✅ Song request created successfully:', requestData);

    // Step 7: DJ views pending requests
    console.log('Step 7: DJ viewing pending requests...');
    const requestsListResponse = await request.get(`${baseURL}/requests`, {
      headers: {
        'Authorization': `Bearer ${djToken}`
      }
    });
    
    expect(requestsListResponse.status()).toBe(200);
    const requests = await requestsListResponse.json();
    expect(requests.length).toBeGreaterThan(0);
    console.log('✅ DJ can see pending requests:', requests.length, 'requests found');

    // Step 8: DJ approves the request
    console.log('Step 8: DJ approving the request...');
    const approveResponse = await request.put(`${baseURL}/requests/${requestId}/done`, {
      headers: {
        'Authorization': `Bearer ${djToken}`,
        'Content-Type': 'application/json'
      }
    });

    expect(approveResponse.status()).toBe(200);
    const approvedRequest = await approveResponse.json();
    expect(approvedRequest.status).toBe(true);
    console.log('✅ Request approved by DJ');

    // Step 9: Verify the complete workflow
    console.log('Step 9: Verifying complete workflow...');
    
    // Verify artist exists
    const artistVerifyResponse = await request.get(`${baseURL}/artists/${artistId}`, {
      headers: {
        'Authorization': `Bearer ${clientToken}`
      }
    });
    expect(artistVerifyResponse.status()).toBe(200);
    
    // Verify song exists
    const songVerifyResponse = await request.get(`${baseURL}/songs/${songId}`, {
      headers: {
        'Authorization': `Bearer ${clientToken}`
      }
    });
    expect(songVerifyResponse.status()).toBe(200);
    
    // Verify request exists and is approved
    const requestVerifyResponse = await request.get(`${baseURL}/requests/${requestId}`, {
      headers: {
        'Authorization': `Bearer ${clientToken}`
      }
    });
    expect(requestVerifyResponse.status()).toBe(200);
    const finalRequest = await requestVerifyResponse.json();
    expect(finalRequest.status).toBe(true);
    
    console.log('🎉 Complete SpinWish workflow executed successfully!');
    console.log('Summary:');
    console.log(`- Artist: ${artistData.name}`);
    console.log(`- Song: ${songData.name} by ${artistData.name}`);
    console.log(`- Request Amount: $${requestData.amount}`);
    console.log(`- Request Status: ${finalRequest.status}`);
  });

  test('should handle concurrent song requests', async ({ request }) => {
    // Create multiple concurrent requests to test system load
    const concurrentRequests = [];
    
    for (let i = 0; i < 5; i++) {
      concurrentRequests.push(
        request.post(`${baseURL}/requests`, {
          headers: {
            'Authorization': `Bearer ${clientToken}`,
            'Content-Type': 'application/json'
          },
          data: {
            djEmailAddress: `dj${timestamp}@spinwish.com`,
            songId: songId
          }
        })
      );
    }
    
    const responses = await Promise.all(concurrentRequests);
    
    // All requests should succeed
    responses.forEach((response, index) => {
      expect(response.status()).toBe(201);
      console.log(`✅ Concurrent request ${index + 1} successful`);
    });
    
    console.log('✅ System handled concurrent requests successfully');
  });
});
