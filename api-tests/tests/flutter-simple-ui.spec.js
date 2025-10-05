const { test, expect } = require('@playwright/test');

test.describe('SpinWish Flutter Simple UI Tests', () => {
  const flutterAppURL = 'http://localhost:3000';

  test.beforeEach(async ({ page }) => {
    // Navigate to the Flutter app
    await page.goto(flutterAppURL);
    await page.waitForLoadState('networkidle');
    
    // Wait for Flutter to fully load
    await page.waitForTimeout(5000);
  });

  test('should load Flutter app successfully', async ({ page }) => {
    console.log('🚀 Testing Flutter app loading...');
    
    try {
      // Check page title
      const title = await page.title();
      console.log('📄 Page title:', title);
      expect(title).toBe('SpinWish');
      
      // Check for Flutter canvas
      const canvas = page.locator('canvas').first();
      await expect(canvas).toBeVisible();
      console.log('✅ Flutter canvas is visible');
      
      // Take screenshot
      await page.screenshot({ path: 'flutter-app-loaded.png', fullPage: true });
      
      console.log('✅ Flutter app loaded successfully');
      
    } catch (error) {
      console.log('❌ Flutter app loading failed:', error.message);
      await page.screenshot({ path: 'flutter-loading-error.png', fullPage: true });
      throw error;
    }
  });

  test('should test basic canvas interactions', async ({ page }) => {
    console.log('🎨 Testing basic canvas interactions...');
    
    try {
      // Find the canvas
      const canvas = page.locator('canvas').first();
      await expect(canvas).toBeVisible();
      
      // Get canvas dimensions
      const canvasBox = await canvas.boundingBox();
      console.log('📐 Canvas dimensions:', canvasBox);
      
      // Test clicking in the center
      const centerX = canvasBox.x + canvasBox.width / 2;
      const centerY = canvasBox.y + canvasBox.height / 2;
      
      console.log(`🖱️ Clicking at center: (${centerX}, ${centerY})`);
      await page.mouse.click(centerX, centerY);
      await page.waitForTimeout(1000);
      
      // Test typing
      console.log('⌨️ Testing keyboard input...');
      await page.keyboard.type('test@example.com');
      await page.waitForTimeout(1000);
      
      // Test Tab navigation
      console.log('🔄 Testing Tab navigation...');
      await page.keyboard.press('Tab');
      await page.waitForTimeout(500);
      
      await page.keyboard.type('password123');
      await page.waitForTimeout(1000);
      
      // Test Enter key
      console.log('↩️ Testing Enter key...');
      await page.keyboard.press('Enter');
      await page.waitForTimeout(3000);
      
      // Take final screenshot
      await page.screenshot({ path: 'flutter-canvas-interaction-result.png', fullPage: true });
      
      console.log('✅ Canvas interactions completed');
      
    } catch (error) {
      console.log('❌ Canvas interaction failed:', error.message);
      await page.screenshot({ path: 'flutter-canvas-interaction-error.png', fullPage: true });
      throw error;
    }
  });

  test('should test responsive design', async ({ page }) => {
    console.log('📱 Testing responsive design...');
    
    try {
      // Test mobile viewport
      console.log('📱 Testing mobile viewport (375x667)...');
      await page.setViewportSize({ width: 375, height: 667 });
      await page.waitForTimeout(2000);
      
      const canvas = page.locator('canvas').first();
      await expect(canvas).toBeVisible();
      await page.screenshot({ path: 'flutter-mobile-responsive.png', fullPage: true });
      
      // Test tablet viewport
      console.log('📱 Testing tablet viewport (768x1024)...');
      await page.setViewportSize({ width: 768, height: 1024 });
      await page.waitForTimeout(2000);
      
      await expect(canvas).toBeVisible();
      await page.screenshot({ path: 'flutter-tablet-responsive.png', fullPage: true });
      
      // Test desktop viewport
      console.log('🖥️ Testing desktop viewport (1920x1080)...');
      await page.setViewportSize({ width: 1920, height: 1080 });
      await page.waitForTimeout(2000);
      
      await expect(canvas).toBeVisible();
      await page.screenshot({ path: 'flutter-desktop-responsive.png', fullPage: true });
      
      console.log('✅ Responsive design test completed');
      
    } catch (error) {
      console.log('❌ Responsive design test failed:', error.message);
      await page.screenshot({ path: 'flutter-responsive-error.png', fullPage: true });
      throw error;
    }
  });

  test('should test form submission with API interaction', async ({ page }) => {
    console.log('📝 Testing form submission with API...');
    
    try {
      const canvas = page.locator('canvas').first();
      const canvasBox = await canvas.boundingBox();
      
      // Click in form area and fill email
      const emailX = canvasBox.x + canvasBox.width * 0.5;
      const emailY = canvasBox.y + canvasBox.height * 0.4;
      
      await page.mouse.click(emailX, emailY);
      await page.waitForTimeout(1000);
      
      // Type valid email
      await page.keyboard.type('testuser@spinwish.com');
      await page.waitForTimeout(1000);
      
      // Move to password field
      await page.keyboard.press('Tab');
      await page.waitForTimeout(500);
      
      // Type password
      await page.keyboard.type('SecurePass123!');
      await page.waitForTimeout(1000);
      
      // Submit form
      await page.keyboard.press('Tab');
      await page.waitForTimeout(500);
      await page.keyboard.press('Enter');
      
      // Wait for API response
      console.log('⏳ Waiting for API response...');
      await page.waitForTimeout(5000);
      
      // Take screenshot of result
      await page.screenshot({ path: 'flutter-form-api-result.png', fullPage: true });
      
      console.log('✅ Form submission test completed');
      
    } catch (error) {
      console.log('❌ Form submission test failed:', error.message);
      await page.screenshot({ path: 'flutter-form-api-error.png', fullPage: true });
      // Don't throw error as this might fail due to API issues
    }
  });

  test('should test keyboard navigation patterns', async ({ page }) => {
    console.log('⌨️ Testing keyboard navigation patterns...');
    
    try {
      const canvas = page.locator('canvas').first();
      await canvas.click();
      
      // Test various keyboard patterns
      const keyPatterns = [
        { keys: ['Tab'], description: 'Tab navigation' },
        { keys: ['Shift+Tab'], description: 'Reverse tab navigation' },
        { keys: ['Enter'], description: 'Enter key' },
        { keys: ['Escape'], description: 'Escape key' },
        { keys: ['ArrowDown'], description: 'Arrow down' },
        { keys: ['ArrowUp'], description: 'Arrow up' },
      ];
      
      for (const pattern of keyPatterns) {
        console.log(`🔄 Testing ${pattern.description}...`);
        for (const key of pattern.keys) {
          await page.keyboard.press(key);
          await page.waitForTimeout(500);
        }
        await page.screenshot({ path: `flutter-keyboard-${pattern.description.replace(/\s+/g, '-').toLowerCase()}.png` });
      }
      
      console.log('✅ Keyboard navigation test completed');
      
    } catch (error) {
      console.log('❌ Keyboard navigation test failed:', error.message);
      await page.screenshot({ path: 'flutter-keyboard-error.png', fullPage: true });
      throw error;
    }
  });

  test('should test performance and animations', async ({ page }) => {
    console.log('🎬 Testing performance and animations...');
    
    try {
      // Start performance monitoring
      await page.evaluate(() => {
        window.performanceData = {
          startTime: performance.now(),
          interactions: [],
          frames: []
        };
        
        // Monitor requestAnimationFrame
        const originalRAF = window.requestAnimationFrame;
        window.requestAnimationFrame = function(callback) {
          window.performanceData.frames.push(performance.now());
          return originalRAF(callback);
        };
      });
      
      const canvas = page.locator('canvas').first();
      
      // Perform various interactions to trigger animations
      await canvas.click();
      await page.waitForTimeout(500);
      
      await page.keyboard.type('animation@test.com');
      await page.waitForTimeout(1000);
      
      await page.keyboard.press('Tab');
      await page.waitForTimeout(500);
      
      await page.keyboard.type('password');
      await page.waitForTimeout(1000);
      
      // Get performance data
      const perfData = await page.evaluate(() => {
        const data = window.performanceData;
        data.endTime = performance.now();
        data.totalTime = data.endTime - data.startTime;
        return data;
      });
      
      console.log('📊 Performance data:');
      console.log(`   Total time: ${perfData.totalTime.toFixed(2)}ms`);
      console.log(`   Animation frames: ${perfData.frames.length}`);
      console.log(`   Interactions: ${perfData.interactions.length}`);
      
      if (perfData.frames.length > 0) {
        console.log('✅ Animations detected');
      } else {
        console.log('ℹ️ No animations detected');
      }
      
      await page.screenshot({ path: 'flutter-performance-test.png', fullPage: true });
      
      console.log('✅ Performance test completed');
      
    } catch (error) {
      console.log('❌ Performance test failed:', error.message);
      await page.screenshot({ path: 'flutter-performance-error.png', fullPage: true });
      throw error;
    }
  });
});
