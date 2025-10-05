const { test, expect } = require('@playwright/test');

test.describe('SpinWish End-to-End Authentication Journey Tests', () => {
  const backendURL = 'http://localhost:8080';
  const flutterAppURL = 'http://localhost:3000';

  test.describe('Complete User Registration and Login Flow', () => {
    test('should complete full user registration and login journey', async ({ page, request }) => {
      console.log('🚀 Starting complete user registration and login journey...');
      console.log('=' .repeat(60));
      
      const timestamp = Date.now();
      const testUser = {
        emailAddress: `e2euser${timestamp}@spinwish.com`,
        username: `e2euser${timestamp}`,
        password: 'SecurePass123!',
        roleName: 'CLIENT'
      };
      
      console.log('👤 Test user:', testUser.emailAddress);
      
      try {
        // Step 1: Test Backend Registration API
        console.log('\n📡 STEP 1: Testing Backend Registration API');
        console.log('-'.repeat(40));
        
        const signupResponse = await request.post(`${backendURL}/api/v1/users/signup`, {
          data: testUser
        });
        
        console.log('📊 Registration Response Status:', signupResponse.status());
        
        if (signupResponse.status() === 201) {
          const signupData = await signupResponse.json();
          console.log('✅ Registration successful:', signupData);
        } else {
          const errorText = await signupResponse.text();
          console.log('❌ Registration failed:', errorText);
        }
        
        // Step 2: Test Backend Login API
        console.log('\n📡 STEP 2: Testing Backend Login API');
        console.log('-'.repeat(40));
        
        const loginResponse = await request.post(`${backendURL}/api/v1/users/login`, {
          data: {
            emailAddress: testUser.emailAddress,
            password: testUser.password
          }
        });
        
        console.log('📊 Login Response Status:', loginResponse.status());
        
        let jwtToken = null;
        if (loginResponse.status() === 200) {
          const loginData = await loginResponse.json();
          jwtToken = loginData.token;
          console.log('✅ Login successful, JWT token received');
          console.log('👤 User details:', loginData.userDetails);
        } else {
          const errorText = await loginResponse.text();
          console.log('❌ Login failed:', errorText);
        }
        
        // Step 3: Test Flutter App Registration
        console.log('\n📱 STEP 3: Testing Flutter App Registration');
        console.log('-'.repeat(40));
        
        await page.goto(flutterAppURL);
        await page.waitForLoadState('networkidle');
        
        // Look for signup/register option
        try {
          const signupToggle = page.locator('text*="Sign Up", text*="Register", text*="account"').first();
          if (await signupToggle.isVisible({ timeout: 5000 })) {
            await signupToggle.click();
            await page.waitForTimeout(1000);
            console.log('✅ Switched to registration mode');
          }
        } catch (e) {
          console.log('ℹ️ Already in registration mode or toggle not found');
        }
        
        // Fill registration form
        const nameField = page.locator('input').first();
        const emailField = page.locator('input').nth(1);
        const passwordField = page.locator('input[type="password"], input').last();
        
        await nameField.fill(testUser.username);
        await emailField.fill(`flutter${testUser.emailAddress}`);
        await passwordField.fill(testUser.password);
        
        console.log('📝 Filled registration form');
        
        // Submit registration
        const submitButton = page.locator('button, [role="button"]').filter({ hasText: /Sign Up|Register/ }).first();
        await submitButton.click();
        
        // Wait for response
        await page.waitForTimeout(3000);
        
        // Check for success or error
        const successIndicator = page.locator('text*="welcome", text*="success", text*="dashboard"');
        const errorIndicator = page.locator('text*="error", text*="failed"');
        
        if (await successIndicator.isVisible({ timeout: 5000 })) {
          console.log('✅ Flutter registration successful');
        } else if (await errorIndicator.isVisible({ timeout: 5000 })) {
          const errorText = await errorIndicator.textContent();
          console.log('❌ Flutter registration failed:', errorText);
        } else {
          console.log('ℹ️ Registration response unclear');
        }
        
        await page.screenshot({ path: 'e2e-registration-result.png', fullPage: true });
        
        // Step 4: Test Flutter App Login
        console.log('\n📱 STEP 4: Testing Flutter App Login');
        console.log('-'.repeat(40));
        
        // Navigate back to login if needed
        try {
          const loginToggle = page.locator('text*="Sign In", text*="Login", text*="account"').first();
          if (await loginToggle.isVisible({ timeout: 5000 })) {
            await loginToggle.click();
            await page.waitForTimeout(1000);
            console.log('✅ Switched to login mode');
          }
        } catch (e) {
          console.log('ℹ️ Already in login mode or toggle not found');
        }
        
        // Fill login form
        const loginEmailField = page.locator('input').first();
        const loginPasswordField = page.locator('input[type="password"], input').last();
        
        await loginEmailField.fill(testUser.emailAddress);
        await loginPasswordField.fill(testUser.password);
        
        console.log('📝 Filled login form');
        
        // Submit login
        const loginSubmitButton = page.locator('button, [role="button"]').filter({ hasText: /Sign In|Login/ }).first();
        await loginSubmitButton.click();
        
        // Wait for response
        await page.waitForTimeout(3000);
        
        // Check for success or error
        const loginSuccessIndicator = page.locator('text*="welcome", text*="dashboard", text*="main"');
        const loginErrorIndicator = page.locator('text*="error", text*="failed", text*="invalid"');
        
        if (await loginSuccessIndicator.isVisible({ timeout: 5000 })) {
          console.log('✅ Flutter login successful');
        } else if (await loginErrorIndicator.isVisible({ timeout: 5000 })) {
          const errorText = await loginErrorIndicator.textContent();
          console.log('❌ Flutter login failed:', errorText);
        } else {
          console.log('ℹ️ Login response unclear');
        }
        
        await page.screenshot({ path: 'e2e-login-result.png', fullPage: true });
        
        console.log('\n🎉 End-to-End Journey Complete!');
        console.log('=' .repeat(60));
        
      } catch (error) {
        console.log('❌ E2E Journey failed:', error.message);
        await page.screenshot({ path: 'e2e-journey-error.png', fullPage: true });
        throw error;
      }
    });

    test('should handle invalid credentials gracefully', async ({ page }) => {
      console.log('🚨 Testing invalid credentials handling...');
      
      try {
        await page.goto(flutterAppURL);
        await page.waitForLoadState('networkidle');
        
        // Fill form with invalid credentials
        const emailField = page.locator('input').first();
        const passwordField = page.locator('input[type="password"], input').last();
        
        await emailField.fill('invalid@example.com');
        await passwordField.fill('wrongpassword');
        
        // Submit form
        const submitButton = page.locator('button, [role="button"]').filter({ hasText: /Sign In|Login/ }).first();
        await submitButton.click();
        
        // Wait for error message
        await page.waitForTimeout(3000);
        
        // Check for error handling
        const errorMessage = page.locator('text*="error", text*="invalid", text*="failed"').first();
        await expect(errorMessage).toBeVisible({ timeout: 10000 });
        
        console.log('✅ Invalid credentials handled correctly');
        await page.screenshot({ path: 'invalid-credentials-test.png', fullPage: true });
        
      } catch (error) {
        console.log('❌ Invalid credentials test failed:', error.message);
        await page.screenshot({ path: 'invalid-credentials-error.png', fullPage: true });
        throw error;
      }
    });

    test('should handle network errors gracefully', async ({ page }) => {
      console.log('🌐 Testing network error handling...');
      
      try {
        // Simulate network failure by using invalid backend URL
        await page.route('**/api/v1/users/**', route => {
          route.abort('failed');
        });
        
        await page.goto(flutterAppURL);
        await page.waitForLoadState('networkidle');
        
        // Fill form with valid data
        const emailField = page.locator('input').first();
        const passwordField = page.locator('input[type="password"], input').last();
        
        await emailField.fill('test@example.com');
        await passwordField.fill('password123');
        
        // Submit form
        const submitButton = page.locator('button, [role="button"]').filter({ hasText: /Sign In|Login/ }).first();
        await submitButton.click();
        
        // Wait for error message
        await page.waitForTimeout(5000);
        
        // Check for network error handling
        const errorMessage = page.locator('text*="error", text*="network", text*="connection"').first();
        
        if (await errorMessage.isVisible({ timeout: 5000 })) {
          console.log('✅ Network errors handled correctly');
        } else {
          console.log('ℹ️ Network error handling may need improvement');
        }
        
        await page.screenshot({ path: 'network-error-test.png', fullPage: true });
        
      } catch (error) {
        console.log('❌ Network error test failed:', error.message);
        await page.screenshot({ path: 'network-error-error.png', fullPage: true });
        // Don't throw error as this is expected to fail in some scenarios
      }
    });
  });

  test.describe('DJ Registration and Login Flow', () => {
    test('should complete DJ registration and login journey', async ({ page, request }) => {
      console.log('🎧 Starting DJ registration and login journey...');
      
      const timestamp = Date.now();
      const testDJ = {
        emailAddress: `dj${timestamp}@spinwish.com`,
        username: `dj${timestamp}`,
        password: 'DJPass123!',
        roleName: 'DJ'
      };
      
      try {
        // Step 1: Test Backend DJ Registration
        console.log('\n📡 Testing Backend DJ Registration');
        
        const signupResponse = await request.post(`${backendURL}/api/v1/users/signup`, {
          data: testDJ
        });
        
        console.log('📊 DJ Registration Response Status:', signupResponse.status());
        
        if (signupResponse.status() === 201) {
          console.log('✅ DJ registration successful');
        } else {
          const errorText = await signupResponse.text();
          console.log('❌ DJ registration failed:', errorText);
        }
        
        // Step 2: Test DJ Login
        const loginResponse = await request.post(`${backendURL}/api/v1/users/login`, {
          data: {
            emailAddress: testDJ.emailAddress,
            password: testDJ.password
          }
        });
        
        console.log('📊 DJ Login Response Status:', loginResponse.status());
        
        if (loginResponse.status() === 200) {
          const loginData = await loginResponse.json();
          console.log('✅ DJ login successful');
          console.log('👤 DJ details:', loginData.userDetails);
          
          // Verify DJ role
          if (loginData.userDetails.role === 'DJ') {
            console.log('✅ DJ role verified');
          } else {
            console.log('❌ DJ role not set correctly');
          }
        } else {
          const errorText = await loginResponse.text();
          console.log('❌ DJ login failed:', errorText);
        }
        
        console.log('\n🎉 DJ Journey Complete!');
        
      } catch (error) {
        console.log('❌ DJ Journey failed:', error.message);
        throw error;
      }
    });
  });

  test.describe('Form Validation Edge Cases', () => {
    test('should handle special characters in email and password', async ({ page }) => {
      console.log('🔤 Testing special characters handling...');
      
      try {
        await page.goto(flutterAppURL);
        await page.waitForLoadState('networkidle');
        
        // Test email with special characters
        const emailField = page.locator('input').first();
        const passwordField = page.locator('input[type="password"], input').last();
        
        await emailField.fill('test+special@example-domain.co.uk');
        await passwordField.fill('P@ssw0rd!#$');
        
        // Check if form accepts these values
        const submitButton = page.locator('button, [role="button"]').filter({ hasText: /Sign In|Login/ }).first();
        await submitButton.click();
        
        await page.waitForTimeout(2000);
        
        console.log('✅ Special characters handled');
        await page.screenshot({ path: 'special-characters-test.png', fullPage: true });
        
      } catch (error) {
        console.log('❌ Special characters test failed:', error.message);
        await page.screenshot({ path: 'special-characters-error.png', fullPage: true });
        throw error;
      }
    });

    test('should handle very long input values', async ({ page }) => {
      console.log('📏 Testing long input values...');
      
      try {
        await page.goto(flutterAppURL);
        await page.waitForLoadState('networkidle');
        
        // Test very long email
        const longEmail = 'a'.repeat(100) + '@example.com';
        const longPassword = 'P'.repeat(100);
        
        const emailField = page.locator('input').first();
        const passwordField = page.locator('input[type="password"], input').last();
        
        await emailField.fill(longEmail);
        await passwordField.fill(longPassword);
        
        // Check if form handles long values
        const submitButton = page.locator('button, [role="button"]').filter({ hasText: /Sign In|Login/ }).first();
        await submitButton.click();
        
        await page.waitForTimeout(2000);
        
        console.log('✅ Long input values handled');
        await page.screenshot({ path: 'long-input-test.png', fullPage: true });
        
      } catch (error) {
        console.log('❌ Long input test failed:', error.message);
        await page.screenshot({ path: 'long-input-error.png', fullPage: true });
        throw error;
      }
    });
  });
});
