const { test, expect } = require('@playwright/test');

test.describe('Enhanced SpinWish Workflow Tests', () => {
  const baseURL = 'http://localhost:8080/api/v1';
  let clientToken = '';
  let djToken = '';
  let userId = '';
  let djId = '';
  let songId = '';
  let requestId = '';
  let sessionId = '';
  let clubId = '';
  let timestamp = '';

  test.beforeAll(async ({ request }) => {
    timestamp = Date.now();
    console.log('Starting enhanced workflow tests...');
  });

  test('Complete Enhanced Workflow: Registration → Club → Session → DJ Profile → Song Request → Payment', async ({ request }) => {

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
    userId = clientData.id;
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
    djId = djData.id;
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

    // Step 3: Create a club
    console.log('Step 3: Creating a club...');
    const clubResponse = await request.post(`${baseURL}/clubs`, {
      headers: {
        'Authorization': `Bearer ${djToken}`
      },
      data: {
        name: `Test Club ${timestamp}`,
        location: 'Nairobi',
        address: '123 Test Street',
        description: 'A great place for music',
        capacity: 500
      }
    });

    expect(clubResponse.status()).toBe(201);
    const clubData = await clubResponse.json();
    clubId = clubData.id;
    console.log('✅ Club created successfully:', clubData.name);

    // Step 4: Update DJ profile
    console.log('Step 4: Updating DJ profile...');
    const profileResponse = await request.put(`${baseURL}/djs/${djId}/profile`, {
      headers: {
        'Authorization': `Bearer ${djToken}`
      },
      data: {
        bio: 'Professional DJ with 5 years experience',
        genres: ['House', 'Techno', 'Hip Hop'],
        instagramHandle: '@testdj'
      }
    });

    expect(profileResponse.status()).toBe(200);
    const profileData = await profileResponse.json();
    console.log('✅ DJ profile updated successfully');

    // Step 5: Create a DJ session
    console.log('Step 5: Creating a DJ session...');
    const sessionResponse = await request.post(`${baseURL}/sessions`, {
      headers: {
        'Authorization': `Bearer ${djToken}`
      },
      data: {
        djId: djId,
        clubId: clubId,
        type: 'CLUB',
        title: `Friday Night Mix ${timestamp}`,
        description: 'Best house music in town',
        genres: ['House', 'Techno']
      }
    });

    expect(sessionResponse.status()).toBe(201);
    const sessionData = await sessionResponse.json();
    sessionId = sessionData.id;
    console.log('✅ Session created successfully:', sessionData.title);

    // Step 6: Start the session
    console.log('Step 6: Starting the session...');
    const startResponse = await request.put(`${baseURL}/sessions/${sessionId}/start`, {
      headers: {
        'Authorization': `Bearer ${djToken}`
      }
    });

    expect(startResponse.status()).toBe(200);
    const startData = await startResponse.json();
    expect(startData.status).toBe('LIVE');
    console.log('✅ Session started successfully');

    // Step 7: Client discovers live sessions
    console.log('Step 7: Client discovering live sessions...');
    const liveSessionsResponse = await request.get(`${baseURL}/sessions/live`, {
      headers: {
        'Authorization': `Bearer ${clientToken}`
      }
    });

    expect(liveSessionsResponse.status()).toBe(200);
    const liveSessionsData = await liveSessionsResponse.json();
    expect(Array.isArray(liveSessionsData)).toBe(true);
    expect(liveSessionsData.length).toBeGreaterThan(0);
    console.log('✅ Client can see live sessions:', liveSessionsData.length, 'sessions found');

    // Step 8: Client discovers DJs
    console.log('Step 8: Client discovering DJs...');
    const djsResponse = await request.get(`${baseURL}/djs`, {
      headers: {
        'Authorization': `Bearer ${clientToken}`
      }
    });

    expect(djsResponse.status()).toBe(200);
    const djsData = await djsResponse.json();
    expect(Array.isArray(djsData)).toBe(true);
    expect(djsData.length).toBeGreaterThan(0);
    console.log('✅ Client can see DJs:', djsData.length, 'DJs found');

    // Step 9: Client discovers live DJs
    console.log('Step 9: Client discovering live DJs...');
    const liveDjsResponse = await request.get(`${baseURL}/djs/live`, {
      headers: {
        'Authorization': `Bearer ${clientToken}`
      }
    });

    expect(liveDjsResponse.status()).toBe(200);
    const liveDjsData = await liveDjsResponse.json();
    expect(Array.isArray(liveDjsData)).toBe(true);
    console.log('✅ Client can see live DJs:', liveDjsData.length, 'live DJs found');

    // Step 10: Client browses songs
    console.log('Step 10: Client browsing songs...');
    const songsResponse = await request.get(`${baseURL}/songs`, {
      headers: {
        'Authorization': `Bearer ${clientToken}`
      }
    });

    expect(songsResponse.status()).toBe(200);
    const songsData = await songsResponse.json();
    expect(Array.isArray(songsData)).toBe(true);
    console.log('✅ Client can see songs:', songsData.length, 'songs found');

    // If there are songs, use the first one for request
    if (songsData.length > 0) {
      songId = songsData[0].id;

      // Step 11: Client makes a song request
      console.log('Step 11: Client making a song request...');
      const requestResponse = await request.post(`${baseURL}/requests`, {
        headers: {
          'Authorization': `Bearer ${clientToken}`
        },
        data: {
          djId: djId,
          sessionId: sessionId,
          songId: songId,
          amount: 100.0,
          message: 'Please play this song!'
        }
      });

      expect(requestResponse.status()).toBe(201);
      const requestData = await requestResponse.json();
      requestId = requestData.id;
      console.log('✅ Song request made successfully');

      // Step 12: DJ views requests
      console.log('Step 12: DJ viewing requests...');
      const djRequestsResponse = await request.get(`${baseURL}/requests/dj/${djId}`, {
        headers: {
          'Authorization': `Bearer ${djToken}`
        }
      });

      expect(djRequestsResponse.status()).toBe(200);
      const djRequestsData = await djRequestsResponse.json();
      expect(Array.isArray(djRequestsData)).toBe(true);
      console.log('✅ DJ can see requests:', djRequestsData.length, 'requests found');

      // Step 13: DJ accepts the request
      console.log('Step 13: DJ accepting the request...');
      const acceptResponse = await request.put(`${baseURL}/requests/${requestId}/accept`, {
        headers: {
          'Authorization': `Bearer ${djToken}`
        }
      });

      expect(acceptResponse.status()).toBe(200);
      const acceptData = await acceptResponse.json();
      console.log('✅ Request accepted successfully');

      // Step 14: Client checks request status
      console.log('Step 14: Client checking request status...');
      const userRequestsResponse = await request.get(`${baseURL}/requests/user/${userId}`, {
        headers: {
          'Authorization': `Bearer ${clientToken}`
        }
      });

      expect(userRequestsResponse.status()).toBe(200);
      const userRequestsData = await userRequestsResponse.json();
      expect(Array.isArray(userRequestsData)).toBe(true);
      console.log('✅ Client can see their requests:', userRequestsData.length, 'requests found');
    }

    // Step 15: End the session
    console.log('Step 15: Ending the session...');
    const endResponse = await request.put(`${baseURL}/sessions/${sessionId}/end`, {
      headers: {
        'Authorization': `Bearer ${djToken}`
      }
    });

    expect(endResponse.status()).toBe(200);
    const endData = await endResponse.json();
    expect(endData.status).toBe('ENDED');
    console.log('✅ Session ended successfully');

    console.log('🎉 Enhanced workflow test completed successfully!');
  });

  test('Club Management Workflow', async ({ request }) => {
    console.log('Testing club management workflow...');

    // Get all clubs
    const clubsResponse = await request.get(`${baseURL}/clubs`, {
      headers: {
        'Authorization': `Bearer ${djToken}`
      }
    });

    expect(clubsResponse.status()).toBe(200);
    const clubsData = await clubsResponse.json();
    expect(Array.isArray(clubsData)).toBe(true);
    console.log('✅ Can retrieve all clubs');

    // Get active clubs
    const activeClubsResponse = await request.get(`${baseURL}/clubs/active`, {
      headers: {
        'Authorization': `Bearer ${djToken}`
      }
    });

    expect(activeClubsResponse.status()).toBe(200);
    const activeClubsData = await activeClubsResponse.json();
    expect(Array.isArray(activeClubsData)).toBe(true);
    console.log('✅ Can retrieve active clubs');

    // Search clubs by location
    const locationSearchResponse = await request.get(`${baseURL}/clubs/search/location/Nairobi`, {
      headers: {
        'Authorization': `Bearer ${djToken}`
      }
    });

    expect(locationSearchResponse.status()).toBe(200);
    const locationSearchData = await locationSearchResponse.json();
    expect(Array.isArray(locationSearchData)).toBe(true);
    console.log('✅ Can search clubs by location');
  });

  test('DJ Discovery and Management', async ({ request }) => {
    console.log('Testing DJ discovery and management...');

    // Get DJs by genre
    const genreDjsResponse = await request.get(`${baseURL}/djs/genre/House`, {
      headers: {
        'Authorization': `Bearer ${clientToken}`
      }
    });

    expect(genreDjsResponse.status()).toBe(200);
    const genreDjsData = await genreDjsResponse.json();
    expect(Array.isArray(genreDjsData)).toBe(true);
    console.log('✅ Can search DJs by genre');

    // Get top rated DJs
    const topRatedResponse = await request.get(`${baseURL}/djs/top-rated?limit=5`, {
      headers: {
        'Authorization': `Bearer ${clientToken}`
      }
    });

    expect(topRatedResponse.status()).toBe(200);
    const topRatedData = await topRatedResponse.json();
    expect(Array.isArray(topRatedData)).toBe(true);
    console.log('✅ Can get top rated DJs');

    // Follow a DJ
    const followResponse = await request.post(`${baseURL}/djs/${djId}/follow`, {
      headers: {
        'Authorization': `Bearer ${clientToken}`
      }
    });

    expect(followResponse.status()).toBe(200);
    const followData = await followResponse.json();
    console.log('✅ Can follow a DJ');

    // Get DJ stats
    const statsResponse = await request.get(`${baseURL}/djs/${djId}/stats`, {
      headers: {
        'Authorization': `Bearer ${clientToken}`
      }
    });

    expect(statsResponse.status()).toBe(200);
    const statsData = await statsResponse.json();
    expect(statsData.djId).toBe(djId);
    console.log('✅ Can get DJ statistics');
  });
});
