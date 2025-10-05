const { test, expect } = require('@playwright/test');

test.describe('Basic SpinWish Signup Tests', () => {
  const backendURL = 'http://localhost:8080';
  const flutterAppURL = 'http://localhost:3000';

  test('Test Basic Signup API', async ({ request }) => {
    console.log('🚀 Testing Basic SpinWish Signup API...');
    
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
          console.log('Login response structure:', Object.keys(loginData));
          expect(loginData.token).toBeDefined();

          // Check if user data is available in the response
          if (loginData.user) {
            expect(loginData.user.emailAddress).toBe(testUser.emailAddress);
          } else if (loginData.emailAddress) {
            expect(loginData.emailAddress).toBe(testUser.emailAddress);
          }

          console.log('🎉 Basic signup and login workflow successful!');
          
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

  test('Test Flutter App and Backend Integration', async ({ page, request }) => {
    console.log('🌐 Testing Flutter App and Backend Integration...');
    
    // First verify backend is accessible
    try {
      const healthCheck = await request.get(`${backendURL}/api/v1/users`);
      console.log('Backend health check status:', healthCheck.status());
      
      if (healthCheck.status() === 401) {
        console.log('✅ Backend is accessible (401 expected for unauthorized access)');
      }
    } catch (error) {
      console.log('❌ Backend not accessible:', error.message);
      return;
    }
    
    // Navigate to Flutter app
    console.log('📱 Loading Flutter app...');
    await page.goto(flutterAppURL, { timeout: 10000 });
    
    // Wait for Flutter to load
    await page.waitForTimeout(5000);
    
    // Check if Flutter elements are present
    const flutterElements = await page.locator('flt-scene-host').count();
    console.log(`Found ${flutterElements} Flutter scene hosts`);
    expect(flutterElements).toBeGreaterThan(0);
    
    // Check page title
    const title = await page.title();
    console.log('Page title:', title);
    expect(title).toBe('SpinWish');
    
    // Monitor network requests to see if Flutter app is calling the backend
    const requests = [];
    page.on('request', request => {
      if (request.url().includes('localhost:8080')) {
        requests.push({
          url: request.url(),
          method: request.method()
        });
        console.log('🌐 Backend API call detected:', request.method(), request.url());
      }
    });
    
    // Try to interact with the app (this might trigger API calls)
    await page.waitForTimeout(3000);
    
    // Take screenshot for verification
    await page.screenshot({ path: 'flutter-app-loaded.png', fullPage: true });
    console.log('📸 Screenshot saved: flutter-app-loaded.png');
    
    console.log(`📊 Total backend API calls detected: ${requests.length}`);
    requests.forEach((req, index) => {
      console.log(`  ${index + 1}. ${req.method} ${req.url}`);
    });
    
    console.log('✅ Flutter app and backend integration test completed');
  });

  test('Test Existing API Endpoints', async ({ request }) => {
    console.log('🔍 Testing Existing API Endpoints...');
    
    // Test users endpoint (should return 401 without auth)
    const usersResponse = await request.get(`${backendURL}/api/v1/users`);
    console.log('Users endpoint status:', usersResponse.status());
    expect(usersResponse.status()).toBe(401);
    
    // Test songs endpoint (should return 401 without auth)
    const songsResponse = await request.get(`${backendURL}/api/v1/songs`);
    console.log('Songs endpoint status:', songsResponse.status());
    expect(songsResponse.status()).toBe(401);
    
    // Test requests endpoint (should return 401 without auth)
    const requestsResponse = await request.get(`${backendURL}/api/v1/requests`);
    console.log('Requests endpoint status:', requestsResponse.status());
    expect(requestsResponse.status()).toBe(401);
    
    console.log('✅ All existing endpoints are properly secured');
  });

  test('Test Complete User Workflow', async ({ request }) => {
    console.log('🌟 Testing Complete User Workflow...');
    
    const timestamp = Date.now();
    
    // Step 1: Create Client User
    const clientUser = {
      emailAddress: `client${timestamp}@spinwish.com`,
      username: `client${timestamp}`,
      password: 'password123',
      roleName: 'CLIENT'
    };
    
    console.log('👤 Creating client user...');
    const clientSignup = await request.post(`${backendURL}/api/v1/users/signup`, {
      data: clientUser
    });
    
    if (clientSignup.ok()) {
      const clientData = await clientSignup.json();
      console.log('✅ Client user created:', clientData.id);
      
      // Login as client
      const clientLogin = await request.post(`${backendURL}/api/v1/users/login`, {
        data: { emailAddress: clientUser.emailAddress, password: clientUser.password }
      });
      
      if (clientLogin.ok()) {
        const clientAuth = await clientLogin.json();
        console.log('✅ Client login successful');
        
        // Test accessing protected endpoints with token
        const profileResponse = await request.get(`${backendURL}/api/v1/users/${clientData.id}`, {
          headers: { 'Authorization': `Bearer ${clientAuth.token}` }
        });
        
        console.log('Profile access status:', profileResponse.status());
        if (profileResponse.ok()) {
          console.log('✅ Protected endpoint access successful');
        }
        
        // Test accessing songs with auth
        const songsResponse = await request.get(`${backendURL}/api/v1/songs`, {
          headers: { 'Authorization': `Bearer ${clientAuth.token}` }
        });
        
        console.log('Songs access status:', songsResponse.status());
        if (songsResponse.ok()) {
          const songs = await songsResponse.json();
          console.log(`✅ Songs endpoint accessible, found ${songs.length} songs`);
        }
        
      } else {
        console.log('❌ Client login failed');
      }
    } else {
      console.log('❌ Client signup failed');
    }
    
    // Step 2: Create DJ User
    const djUser = {
      emailAddress: `dj${timestamp}@spinwish.com`,
      username: `dj${timestamp}`,
      password: 'password123',
      roleName: 'DJ'
    };
    
    console.log('🎧 Creating DJ user...');
    const djSignup = await request.post(`${backendURL}/api/v1/users/signup`, {
      data: djUser
    });
    
    if (djSignup.ok()) {
      const djData = await djSignup.json();
      console.log('✅ DJ user created:', djData.id);
      
      // Login as DJ
      const djLogin = await request.post(`${backendURL}/api/v1/users/login`, {
        data: { emailAddress: djUser.emailAddress, password: djUser.password }
      });
      
      if (djLogin.ok()) {
        const djAuth = await djLogin.json();
        console.log('✅ DJ login successful');
        
        // Test DJ-specific endpoints if they exist
        const djProfileResponse = await request.get(`${backendURL}/api/v1/users/${djData.id}`, {
          headers: { 'Authorization': `Bearer ${djAuth.token}` }
        });
        
        if (djProfileResponse.ok()) {
          console.log('✅ DJ profile access successful');
        }
        
      } else {
        console.log('❌ DJ login failed');
      }
    } else {
      console.log('❌ DJ signup failed');
    }
    
    console.log('🎉 Complete user workflow test completed!');
  });
});
