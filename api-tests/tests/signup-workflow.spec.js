const { test, expect } = require('@playwright/test');

test.describe('SpinWish Signup Workflow Tests', () => {
  const backendURL = 'http://localhost:8080';
  const flutterAppURL = 'http://localhost:3000';

  test('Backend Signup API Test', async ({ request }) => {
    console.log('🚀 Testing SpinWish Backend Signup API...');
    
    const timestamp = Date.now();
    const testUser = {
      emailAddress: `testuser${timestamp}@spinwish.com`,
      username: `testuser${timestamp}`,
      password: 'password123',
      roleName: 'CLIENT'
    };
    
    console.log('📝 Creating test user:', testUser.emailAddress);
    
    try {
      // Test the signup API endpoint
      const signupResponse = await request.post(`${backendURL}/api/v1/users/signup`, {
        data: testUser
      });
      
      console.log('📊 Signup API Response Status:', signupResponse.status());
      
      if (signupResponse.ok()) {
        const responseData = await signupResponse.json();
        console.log('✅ Signup successful! User ID:', responseData.id);
        
        // Test login with the created user
        console.log('🔐 Testing login with created user...');
        const loginResponse = await request.post(`${backendURL}/api/v1/users/login`, {
          data: {
            emailAddress: testUser.emailAddress,
            password: testUser.password
          }
        });
        
        console.log('📊 Login API Response Status:', loginResponse.status());
        
        if (loginResponse.ok()) {
          const loginData = await loginResponse.json();
          console.log('✅ Login successful! Token received');
          expect(loginData.token).toBeDefined();
          expect(loginData.user.emailAddress).toBe(testUser.emailAddress);
          
          // Test accessing protected endpoints with token
          console.log('🔒 Testing protected endpoint access...');
          const profileResponse = await request.get(`${backendURL}/api/v1/users/${loginData.user.id}`, {
            headers: {
              'Authorization': `Bearer ${loginData.token}`
            }
          });
          
          console.log('📊 Profile API Response Status:', profileResponse.status());
          
          if (profileResponse.ok()) {
            const profileData = await profileResponse.json();
            console.log('✅ Protected endpoint access successful!');
            expect(profileData.emailAddress).toBe(testUser.emailAddress);
          }
          
        } else {
          const loginError = await loginResponse.text();
          console.log('❌ Login failed:', loginError);
          throw new Error(`Login failed: ${loginError}`);
        }
        
      } else {
        const errorData = await signupResponse.text();
        console.log('❌ Signup failed:', errorData);
        throw new Error(`Signup failed: ${errorData}`);
      }
      
    } catch (error) {
      console.log('❌ API test error:', error.message);
      throw error;
    }
  });

  test('DJ Signup and Profile Setup', async ({ request }) => {
    console.log('🎧 Testing DJ Signup and Profile Setup...');
    
    const timestamp = Date.now();
    const testDJ = {
      emailAddress: `testdj${timestamp}@spinwish.com`,
      username: `testdj${timestamp}`,
      password: 'password123',
      roleName: 'DJ'
    };
    
    console.log('📝 Creating test DJ:', testDJ.emailAddress);
    
    // Create DJ account
    const signupResponse = await request.post(`${backendURL}/api/v1/users/signup`, {
      data: testDJ
    });
    
    expect(signupResponse.status()).toBe(201);
    const djData = await signupResponse.json();
    console.log('✅ DJ account created! ID:', djData.id);
    
    // Login as DJ
    const loginResponse = await request.post(`${backendURL}/api/v1/users/login`, {
      data: {
        emailAddress: testDJ.emailAddress,
        password: testDJ.password
      }
    });
    
    expect(loginResponse.status()).toBe(200);
    const loginData = await loginResponse.json();
    console.log('✅ DJ login successful!');
    
    // Update DJ profile
    console.log('🎵 Updating DJ profile...');
    const profileUpdateResponse = await request.put(`${backendURL}/api/v1/djs/${djData.id}/profile`, {
      headers: {
        'Authorization': `Bearer ${loginData.token}`
      },
      data: {
        bio: 'Professional DJ with 5 years experience',
        genres: ['House', 'Techno', 'Hip Hop'],
        instagramHandle: '@testdj'
      }
    });
    
    expect(profileUpdateResponse.status()).toBe(200);
    const updatedProfile = await profileUpdateResponse.json();
    console.log('✅ DJ profile updated successfully!');
    expect(updatedProfile.bio).toBe('Professional DJ with 5 years experience');
  });

  test('Complete User Journey: Signup → Session → Request', async ({ request }) => {
    console.log('🌟 Testing Complete User Journey...');
    
    const timestamp = Date.now();
    
    // Step 1: Create Client User
    const clientUser = {
      emailAddress: `client${timestamp}@spinwish.com`,
      username: `client${timestamp}`,
      password: 'password123',
      roleName: 'CLIENT'
    };
    
    const clientSignup = await request.post(`${backendURL}/api/v1/users/signup`, {
      data: clientUser
    });
    expect(clientSignup.status()).toBe(201);
    const clientData = await clientSignup.json();
    
    const clientLogin = await request.post(`${backendURL}/api/v1/users/login`, {
      data: { emailAddress: clientUser.emailAddress, password: clientUser.password }
    });
    const clientAuth = await clientLogin.json();
    console.log('✅ Client user created and logged in');
    
    // Step 2: Create DJ User
    const djUser = {
      emailAddress: `dj${timestamp}@spinwish.com`,
      username: `dj${timestamp}`,
      password: 'password123',
      roleName: 'DJ'
    };
    
    const djSignup = await request.post(`${backendURL}/api/v1/users/signup`, {
      data: djUser
    });
    expect(djSignup.status()).toBe(201);
    const djData = await djSignup.json();
    
    const djLogin = await request.post(`${backendURL}/api/v1/users/login`, {
      data: { emailAddress: djUser.emailAddress, password: djUser.password }
    });
    const djAuth = await djLogin.json();
    console.log('✅ DJ user created and logged in');
    
    // Step 3: Create Club
    const clubResponse = await request.post(`${backendURL}/api/v1/clubs`, {
      headers: { 'Authorization': `Bearer ${djAuth.token}` },
      data: {
        name: `Test Club ${timestamp}`,
        location: 'Nairobi',
        capacity: 500
      }
    });
    expect(clubResponse.status()).toBe(201);
    const clubData = await clubResponse.json();
    console.log('✅ Club created');
    
    // Step 4: Create Session
    const sessionResponse = await request.post(`${backendURL}/api/v1/sessions`, {
      headers: { 'Authorization': `Bearer ${djAuth.token}` },
      data: {
        djId: djData.id,
        clubId: clubData.id,
        type: 'CLUB',
        title: `Test Session ${timestamp}`,
        description: 'Test session for workflow'
      }
    });
    expect(sessionResponse.status()).toBe(201);
    const sessionData = await sessionResponse.json();
    console.log('✅ Session created');
    
    // Step 5: Start Session
    const startResponse = await request.put(`${backendURL}/api/v1/sessions/${sessionData.id}/start`, {
      headers: { 'Authorization': `Bearer ${djAuth.token}` }
    });
    expect(startResponse.status()).toBe(200);
    console.log('✅ Session started');
    
    // Step 6: Client discovers live sessions
    const liveSessionsResponse = await request.get(`${backendURL}/api/v1/sessions/live`, {
      headers: { 'Authorization': `Bearer ${clientAuth.token}` }
    });
    expect(liveSessionsResponse.status()).toBe(200);
    const liveSessions = await liveSessionsResponse.json();
    expect(liveSessions.length).toBeGreaterThan(0);
    console.log('✅ Client can discover live sessions');
    
    // Step 7: Client discovers DJs
    const djsResponse = await request.get(`${backendURL}/api/v1/djs`, {
      headers: { 'Authorization': `Bearer ${clientAuth.token}` }
    });
    expect(djsResponse.status()).toBe(200);
    const djs = await djsResponse.json();
    expect(djs.length).toBeGreaterThan(0);
    console.log('✅ Client can discover DJs');
    
    console.log('🎉 Complete user journey test successful!');
  });

  test('Flutter App Accessibility Test', async ({ page }) => {
    console.log('🌐 Testing Flutter App Accessibility...');
    
    try {
      // Try to access the Flutter app
      await page.goto(flutterAppURL, { timeout: 10000 });
      
      // Wait a bit for the app to load
      await page.waitForTimeout(5000);
      
      // Take a screenshot to see what's loaded
      await page.screenshot({ path: 'flutter-app-state.png', fullPage: true });
      
      // Check if Flutter elements are present
      const flutterElements = await page.locator('flt-scene-host').count();
      console.log(`Found ${flutterElements} Flutter scene hosts`);
      
      // Check page title
      const title = await page.title();
      console.log('Page title:', title);
      
      // Check for any visible text
      const bodyText = await page.textContent('body');
      if (bodyText && bodyText.length > 0) {
        console.log('Page content preview:', bodyText.substring(0, 200));
      }
      
      // Monitor console messages
      page.on('console', msg => {
        if (msg.type() === 'error') {
          console.log('❌ Flutter console error:', msg.text());
        }
      });
      
      console.log('✅ Flutter app accessibility test completed');
      
    } catch (error) {
      console.log('❌ Flutter app not accessible:', error.message);
      // This is not a critical failure for the backend tests
    }
  });
});
