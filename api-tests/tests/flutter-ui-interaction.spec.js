const { test, expect } = require('@playwright/test');

test.describe('Flutter UI Interaction Tests', () => {
  const flutterAppURL = 'http://localhost:3000';
  const backendURL = 'http://localhost:8080';

  test.beforeEach(async ({ page }) => {
    // Navigate to the Flutter app
    await page.goto(flutterAppURL);
    await page.waitForLoadState('networkidle');
    
    // Wait for Flutter to fully load
    await page.waitForSelector('flt-scene-host', { timeout: 30000 });
    await page.waitForTimeout(3000);
  });

  test('Flutter App UI Analysis and Interaction', async ({ page }) => {
    console.log('🔍 Analyzing Flutter App UI...');
    
    // Take initial screenshot
    await page.screenshot({ path: 'flutter-initial-state.png', fullPage: true });
    console.log('📸 Initial screenshot saved');
    
    // Check page title
    const title = await page.title();
    console.log('📄 Page title:', title);
    expect(title).toBe('SpinWish');
    
    // Check for Flutter elements
    const flutterHosts = await page.locator('flt-scene-host').count();
    console.log(`🎯 Found ${flutterHosts} Flutter scene hosts`);
    expect(flutterHosts).toBeGreaterThan(0);
    
    // Try to find any visible text content
    const bodyText = await page.textContent('body');
    if (bodyText && bodyText.trim().length > 0) {
      console.log('📝 Page text content (first 200 chars):', bodyText.substring(0, 200));
    }
    
    // Look for common UI elements that might be clickable
    const buttons = await page.locator('button').count();
    const links = await page.locator('a').count();
    const inputs = await page.locator('input').count();
    const clickableElements = await page.locator('[role="button"], [tabindex="0"]').count();
    
    console.log(`🎛️  UI Elements found:`);
    console.log(`   - Buttons: ${buttons}`);
    console.log(`   - Links: ${links}`);
    console.log(`   - Inputs: ${inputs}`);
    console.log(`   - Clickable elements: ${clickableElements}`);
    
    // Try to interact with the Flutter canvas
    const canvas = await page.locator('canvas').first();
    if (await canvas.count() > 0) {
      console.log('🎨 Flutter canvas found, attempting interaction...');
      
      // Get canvas dimensions
      const canvasBox = await canvas.boundingBox();
      if (canvasBox) {
        console.log(`📐 Canvas dimensions: ${canvasBox.width}x${canvasBox.height}`);
        
        // Try clicking in different areas of the canvas
        const centerX = canvasBox.x + canvasBox.width / 2;
        const centerY = canvasBox.y + canvasBox.height / 2;
        
        console.log('🖱️  Clicking center of canvas...');
        await page.click(`canvas`, { position: { x: canvasBox.width / 2, y: canvasBox.height / 2 } });
        await page.waitForTimeout(1000);
        
        // Try clicking in upper area (might be navigation/header)
        console.log('🖱️  Clicking upper area...');
        await page.click(`canvas`, { position: { x: canvasBox.width / 2, y: canvasBox.height * 0.2 } });
        await page.waitForTimeout(1000);
        
        // Try clicking in lower area (might be buttons)
        console.log('🖱️  Clicking lower area...');
        await page.click(`canvas`, { position: { x: canvasBox.width / 2, y: canvasBox.height * 0.8 } });
        await page.waitForTimeout(1000);
        
        // Take screenshot after interactions
        await page.screenshot({ path: 'flutter-after-clicks.png', fullPage: true });
        console.log('📸 Screenshot after interactions saved');
      }
    }
    
    // Monitor for any network requests during interaction
    const requests = [];
    page.on('request', request => {
      if (request.url().includes('localhost:8080')) {
        requests.push({
          url: request.url(),
          method: request.method(),
          timestamp: new Date().toISOString()
        });
        console.log('🌐 Backend API call:', request.method(), request.url());
      }
    });
    
    // Try keyboard interactions
    console.log('⌨️  Trying keyboard interactions...');
    await page.keyboard.press('Tab');
    await page.waitForTimeout(500);
    await page.keyboard.press('Enter');
    await page.waitForTimeout(500);
    await page.keyboard.press('Escape');
    await page.waitForTimeout(500);
    
    // Check for any console messages
    const consoleMessages = [];
    page.on('console', msg => {
      consoleMessages.push({
        type: msg.type(),
        text: msg.text(),
        timestamp: new Date().toISOString()
      });
      if (msg.type() === 'error') {
        console.log('❌ Console error:', msg.text());
      } else if (msg.type() === 'log') {
        console.log('📝 Console log:', msg.text());
      }
    });
    
    // Wait a bit more to see if any delayed interactions occur
    await page.waitForTimeout(3000);
    
    // Final screenshot
    await page.screenshot({ path: 'flutter-final-state.png', fullPage: true });
    console.log('📸 Final screenshot saved');
    
    // Summary
    console.log(`📊 Interaction Summary:`);
    console.log(`   - Backend API calls: ${requests.length}`);
    console.log(`   - Console messages: ${consoleMessages.length}`);
    
    if (requests.length > 0) {
      console.log('🌐 API Calls made:');
      requests.forEach((req, index) => {
        console.log(`   ${index + 1}. ${req.method} ${req.url}`);
      });
    }
    
    console.log('✅ Flutter UI interaction test completed');
  });

  test('Flutter App Signup Flow Simulation', async ({ page, request }) => {
    console.log('📝 Simulating Flutter App Signup Flow...');
    
    // First create a user via API to simulate successful signup
    const timestamp = Date.now();
    const testUser = {
      emailAddress: `fluttertest${timestamp}@spinwish.com`,
      username: `fluttertest${timestamp}`,
      password: 'password123',
      roleName: 'CLIENT'
    };
    
    console.log('🔧 Creating test user via API:', testUser.emailAddress);
    
    const signupResponse = await request.post(`${backendURL}/api/v1/users/signup`, {
      data: testUser
    });
    
    if (signupResponse.ok()) {
      const userData = await signupResponse.json();
      console.log('✅ Test user created successfully');
      
      // Now try to simulate login in the Flutter app
      console.log('📱 Attempting to interact with Flutter app for login...');
      
      // Take screenshot of current state
      await page.screenshot({ path: 'flutter-before-login-attempt.png', fullPage: true });
      
      // Try to find and interact with potential login elements
      // Since Flutter renders to canvas, we'll try different approaches
      
      // Approach 1: Look for HTML input elements (if any)
      const inputs = await page.locator('input').count();
      if (inputs > 0) {
        console.log(`📝 Found ${inputs} input fields, attempting to fill them...`);
        
        try {
          // Try to fill potential email/username field
          await page.fill('input:first-child', testUser.emailAddress);
          await page.waitForTimeout(500);
          
          // Try to fill potential password field
          if (inputs > 1) {
            await page.fill('input:nth-child(2)', testUser.password);
            await page.waitForTimeout(500);
          }
          
          // Look for submit button
          const buttons = await page.locator('button').count();
          if (buttons > 0) {
            await page.click('button:first-child');
            console.log('✅ Clicked submit button');
          }
          
        } catch (error) {
          console.log('❌ Error filling form fields:', error.message);
        }
      }
      
      // Approach 2: Try canvas-based interactions for Flutter UI
      const canvas = await page.locator('canvas').first();
      if (await canvas.count() > 0) {
        console.log('🎨 Attempting canvas-based Flutter interactions...');
        
        const canvasBox = await canvas.boundingBox();
        if (canvasBox) {
          // Try clicking where login fields might be
          const fieldY = canvasBox.height * 0.4; // Middle-upper area
          const buttonY = canvasBox.height * 0.6; // Lower area
          const centerX = canvasBox.width / 2;
          
          // Click potential email field
          await page.click('canvas', { position: { x: centerX, y: fieldY } });
          await page.waitForTimeout(500);
          await page.keyboard.type(testUser.emailAddress);
          await page.waitForTimeout(500);
          
          // Click potential password field
          await page.click('canvas', { position: { x: centerX, y: fieldY + 50 } });
          await page.waitForTimeout(500);
          await page.keyboard.type(testUser.password);
          await page.waitForTimeout(500);
          
          // Click potential login button
          await page.click('canvas', { position: { x: centerX, y: buttonY } });
          await page.waitForTimeout(2000);
          
          console.log('✅ Completed canvas-based interaction simulation');
        }
      }
      
      // Monitor for API calls during the interaction
      const apiCalls = [];
      page.on('request', request => {
        if (request.url().includes('localhost:8080')) {
          apiCalls.push({
            url: request.url(),
            method: request.method(),
            headers: request.headers()
          });
          console.log('🌐 API call detected:', request.method(), request.url());
        }
      });
      
      // Wait for potential API responses
      await page.waitForTimeout(3000);
      
      // Take final screenshot
      await page.screenshot({ path: 'flutter-after-login-attempt.png', fullPage: true });
      
      console.log(`📊 Login simulation completed. API calls made: ${apiCalls.length}`);
      
    } else {
      console.log('❌ Failed to create test user for simulation');
    }
  });
});
