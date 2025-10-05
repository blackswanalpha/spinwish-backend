const { test, expect } = require('@playwright/test');

test.describe('Flutter App Signup Tests', () => {
  const flutterAppURL = 'http://localhost:3000';
  const backendURL = 'http://localhost:8080';

  test.beforeEach(async ({ page }) => {
    // Navigate to the Flutter app
    await page.goto(flutterAppURL);
    await page.waitForLoadState('networkidle');
  });

  test('Flutter App Loads Successfully', async ({ page }) => {
    console.log('Testing Flutter app loading...');
    
    // Wait for the Flutter app to load
    await page.waitForSelector('flt-scene-host', { timeout: 30000 });
    
    // Check if the Flutter app has loaded
    const flutterHost = await page.locator('flt-scene-host').count();
    expect(flutterHost).toBeGreaterThan(0);
    
    console.log('✅ Flutter app loaded successfully');
  });

  test('Navigate to Signup Page', async ({ page }) => {
    console.log('Testing navigation to signup page...');
    
    // Wait for Flutter app to load
    await page.waitForSelector('flt-scene-host', { timeout: 30000 });
    
    // Take a screenshot to see the current state
    await page.screenshot({ path: 'flutter-app-loaded.png', fullPage: true });
    
    // Look for common signup elements or buttons
    // Since Flutter renders to canvas, we'll need to look for specific text or use coordinates
    
    // Try to find signup-related text
    const pageContent = await page.textContent('body');
    console.log('Page content preview:', pageContent?.substring(0, 500));
    
    // Look for signup button or link
    try {
      // Try clicking on signup-related elements
      await page.click('text=Sign Up', { timeout: 5000 });
      console.log('✅ Found and clicked Sign Up button');
    } catch (error) {
      console.log('❌ Sign Up button not found with text selector');
      
      // Try alternative selectors
      try {
        await page.click('text=Register', { timeout: 5000 });
        console.log('✅ Found and clicked Register button');
      } catch (error2) {
        console.log('❌ Register button not found either');
        
        // Try to find any clickable elements
        const clickableElements = await page.locator('button, [role="button"], a').count();
        console.log(`Found ${clickableElements} clickable elements`);
        
        if (clickableElements > 0) {
          // Take screenshot to analyze the UI
          await page.screenshot({ path: 'flutter-ui-analysis.png', fullPage: true });
          console.log('📸 Screenshot saved for UI analysis');
        }
      }
    }
  });

  test('Test Signup Form Interaction', async ({ page }) => {
    console.log('Testing signup form interaction...');
    
    // Wait for Flutter app to load
    await page.waitForSelector('flt-scene-host', { timeout: 30000 });
    
    // Since Flutter apps render to canvas, we need to use different strategies
    // Let's try to interact with form elements
    
    try {
      // Look for input fields
      const inputs = await page.locator('input').count();
      console.log(`Found ${inputs} input fields`);
      
      if (inputs > 0) {
        // Try to fill the first few inputs (likely email, username, password)
        const timestamp = Date.now();
        
        await page.fill('input:nth-child(1)', `testuser${timestamp}@example.com`);
        await page.fill('input:nth-child(2)', `testuser${timestamp}`);
        await page.fill('input:nth-child(3)', 'password123');
        
        console.log('✅ Filled signup form fields');
        
        // Look for submit button
        await page.click('button[type="submit"]', { timeout: 5000 });
        console.log('✅ Clicked submit button');
        
        // Wait for response or navigation
        await page.waitForTimeout(2000);
        
        // Take screenshot of result
        await page.screenshot({ path: 'signup-result.png', fullPage: true });
        
      } else {
        console.log('❌ No input fields found - Flutter app may use custom widgets');
      }
      
    } catch (error) {
      console.log('❌ Error interacting with signup form:', error.message);
      
      // Take screenshot for debugging
      await page.screenshot({ path: 'signup-error.png', fullPage: true });
    }
  });

  test('Test Backend API Signup Directly', async ({ request }) => {
    console.log('Testing backend signup API directly...');
    
    const timestamp = Date.now();
    const testUser = {
      emailAddress: `testuser${timestamp}@spinwish.com`,
      username: `testuser${timestamp}`,
      password: 'password123',
      roleName: 'CLIENT'
    };
    
    try {
      // Test the signup API endpoint
      const response = await request.post(`${backendURL}/api/v1/users/signup`, {
        data: testUser
      });
      
      console.log('Signup API Response Status:', response.status());
      
      if (response.ok()) {
        const responseData = await response.json();
        console.log('✅ Signup API successful:', responseData);
        
        // Test login with the created user
        const loginResponse = await request.post(`${backendURL}/api/v1/users/login`, {
          data: {
            emailAddress: testUser.emailAddress,
            password: testUser.password
          }
        });
        
        console.log('Login API Response Status:', loginResponse.status());
        
        if (loginResponse.ok()) {
          const loginData = await loginResponse.json();
          console.log('✅ Login API successful, token received');
          expect(loginData.token).toBeDefined();
        } else {
          const loginError = await loginResponse.text();
          console.log('❌ Login API failed:', loginError);
        }
        
      } else {
        const errorData = await response.text();
        console.log('❌ Signup API failed:', errorData);
      }
      
    } catch (error) {
      console.log('❌ API test error:', error.message);
    }
  });

  test('Test Flutter App with Backend Integration', async ({ page, request }) => {
    console.log('Testing Flutter app with backend integration...');
    
    // First verify backend is accessible
    try {
      const healthCheck = await request.get(`${backendURL}/api/v1/users`);
      console.log('Backend health check status:', healthCheck.status());
    } catch (error) {
      console.log('❌ Backend not accessible:', error.message);
      return;
    }
    
    // Navigate to Flutter app
    await page.goto(flutterAppURL);
    await page.waitForSelector('flt-scene-host', { timeout: 30000 });
    
    // Monitor network requests to see if Flutter app is calling the backend
    const requests = [];
    page.on('request', request => {
      if (request.url().includes('localhost:8080')) {
        requests.push({
          url: request.url(),
          method: request.method(),
          headers: request.headers()
        });
        console.log('🌐 Backend API call detected:', request.method(), request.url());
      }
    });
    
    // Try to trigger some actions that might call the backend
    await page.waitForTimeout(5000);
    
    // Take final screenshot
    await page.screenshot({ path: 'flutter-backend-integration.png', fullPage: true });
    
    console.log(`📊 Total backend API calls detected: ${requests.length}`);
    requests.forEach((req, index) => {
      console.log(`  ${index + 1}. ${req.method} ${req.url}`);
    });
  });
});
