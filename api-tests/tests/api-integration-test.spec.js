const { test, expect } = require('@playwright/test');

test.describe('API Integration Test', () => {
  const backendURL = 'http://localhost:8080';
  const flutterAppURL = 'http://localhost:3000';

  test('should verify API endpoints are accessible from Flutter app', async ({ page }) => {
    console.log('🔗 Testing API integration from Flutter app...');
    
    try {
      // Navigate to Flutter app
      await page.goto(flutterAppURL);
      await page.waitForLoadState('networkidle');
      await page.waitForTimeout(3000);
      
      // Test API call from browser context (simulating Flutter app)
      const apiResponse = await page.evaluate(async () => {
        try {
          const response = await fetch('http://localhost:8080/api/v1/users/login', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              emailAddress: 'test@example.com',
              password: 'password123'
            })
          });
          
          const data = await response.json();
          return {
            status: response.status,
            data: data,
            headers: Object.fromEntries(response.headers.entries())
          };
        } catch (error) {
          return {
            error: error.message
          };
        }
      });
      
      console.log('📊 API Response:', JSON.stringify(apiResponse, null, 2));
      
      if (apiResponse.error) {
        console.log('❌ API call failed:', apiResponse.error);
        throw new Error(`API call failed: ${apiResponse.error}`);
      }
      
      // Verify successful response
      expect(apiResponse.status).toBe(200);
      expect(apiResponse.data).toHaveProperty('token');
      expect(apiResponse.data).toHaveProperty('userDetails');
      expect(apiResponse.data.userDetails).toHaveProperty('emailAddress', 'test@example.com');
      
      console.log('✅ API integration test successful!');
      console.log('🔑 JWT Token received:', apiResponse.data.token.substring(0, 50) + '...');
      
    } catch (error) {
      console.log('❌ API integration test failed:', error.message);
      await page.screenshot({ path: 'api-integration-error.png', fullPage: true });
      throw error;
    }
  });

  test('should test signup API from Flutter app context', async ({ page }) => {
    console.log('📝 Testing signup API integration...');
    
    try {
      await page.goto(flutterAppURL);
      await page.waitForLoadState('networkidle');
      await page.waitForTimeout(3000);
      
      // Generate unique user for signup test
      const timestamp = Date.now();
      const testUser = {
        emailAddress: `apitest${timestamp}@example.com`,
        username: `apitest${timestamp}`,
        password: 'TestPass123!',
        roleName: 'CLIENT'
      };
      
      const signupResponse = await page.evaluate(async (user) => {
        try {
          const response = await fetch('http://localhost:8080/api/v1/users/signup', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(user)
          });
          
          const data = await response.json();
          return {
            status: response.status,
            data: data
          };
        } catch (error) {
          return {
            error: error.message
          };
        }
      }, testUser);
      
      console.log('📊 Signup Response:', JSON.stringify(signupResponse, null, 2));
      
      if (signupResponse.error) {
        console.log('❌ Signup API call failed:', signupResponse.error);
        throw new Error(`Signup API call failed: ${signupResponse.error}`);
      }
      
      // Verify successful signup
      expect(signupResponse.status).toBe(201);
      expect(signupResponse.data).toHaveProperty('emailAddress', testUser.emailAddress);
      expect(signupResponse.data).toHaveProperty('username', testUser.username);
      
      console.log('✅ Signup API integration test successful!');
      
      // Now test login with the new user
      const loginResponse = await page.evaluate(async (user) => {
        try {
          const response = await fetch('http://localhost:8080/api/v1/users/login', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              emailAddress: user.emailAddress,
              password: user.password
            })
          });
          
          const data = await response.json();
          return {
            status: response.status,
            data: data
          };
        } catch (error) {
          return {
            error: error.message
          };
        }
      }, testUser);
      
      console.log('📊 Login Response:', JSON.stringify(loginResponse, null, 2));
      
      if (loginResponse.error) {
        console.log('❌ Login API call failed:', loginResponse.error);
        throw new Error(`Login API call failed: ${loginResponse.error}`);
      }
      
      // Verify successful login
      expect(loginResponse.status).toBe(200);
      expect(loginResponse.data).toHaveProperty('token');
      expect(loginResponse.data.userDetails).toHaveProperty('emailAddress', testUser.emailAddress);
      
      console.log('✅ Complete signup -> login flow successful!');
      
    } catch (error) {
      console.log('❌ Signup API integration test failed:', error.message);
      await page.screenshot({ path: 'signup-api-integration-error.png', fullPage: true });
      throw error;
    }
  });
});
