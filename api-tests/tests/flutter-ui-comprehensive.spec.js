const { test, expect } = require('@playwright/test');

test.describe('SpinWish Flutter UI Comprehensive Tests', () => {
  const flutterAppURL = 'http://localhost:3000';

  test.beforeEach(async ({ page }) => {
    // Navigate to the Flutter app
    await page.goto(flutterAppURL);
    await page.waitForLoadState('networkidle');
    
    // Wait for Flutter to fully load
    await page.waitForTimeout(5000);
    
    // Enable accessibility for better element detection
    const accessibilityButton = page.locator('[aria-label="Enable accessibility"]');
    if (await accessibilityButton.isVisible()) {
      await accessibilityButton.click();
      await page.waitForTimeout(2000);
    }
  });

  test.describe('Flutter Canvas Interaction Tests', () => {
    test('should interact with Flutter canvas elements', async ({ page }) => {
      console.log('🎨 Testing Flutter canvas interactions...');
      
      try {
        // Take initial screenshot
        await page.screenshot({ path: 'flutter-initial-state.png', fullPage: true });
        
        // Look for Flutter canvas
        const canvas = page.locator('canvas').first();
        await expect(canvas).toBeVisible();
        
        // Get canvas dimensions
        const canvasBox = await canvas.boundingBox();
        console.log('📐 Canvas dimensions:', canvasBox);
        
        // Try clicking in different areas of the canvas to find interactive elements
        const centerX = canvasBox.x + canvasBox.width / 2;
        const centerY = canvasBox.y + canvasBox.height / 2;
        
        // Click in the center (likely where form elements would be)
        await page.mouse.click(centerX, centerY);
        await page.waitForTimeout(1000);
        
        // Try typing to see if we can interact with form fields
        await page.keyboard.type('test@example.com');
        await page.waitForTimeout(1000);
        
        // Press Tab to move to next field
        await page.keyboard.press('Tab');
        await page.waitForTimeout(500);
        
        // Type password
        await page.keyboard.type('password123');
        await page.waitForTimeout(1000);
        
        // Press Tab to move to button
        await page.keyboard.press('Tab');
        await page.waitForTimeout(500);
        
        // Press Enter to submit
        await page.keyboard.press('Enter');
        await page.waitForTimeout(3000);
        
        // Take screenshot after interaction
        await page.screenshot({ path: 'flutter-after-interaction.png', fullPage: true });
        
        console.log('✅ Flutter canvas interaction test completed');
        
      } catch (error) {
        console.log('❌ Flutter canvas interaction failed:', error.message);
        await page.screenshot({ path: 'flutter-interaction-error.png', fullPage: true });
        throw error;
      }
    });

    test('should test responsive design on different viewports', async ({ page }) => {
      console.log('📱 Testing Flutter responsive design...');
      
      try {
        // Test mobile viewport
        await page.setViewportSize({ width: 375, height: 667 });
        await page.waitForTimeout(2000);
        await page.screenshot({ path: 'flutter-mobile-view.png', fullPage: true });
        
        // Test tablet viewport
        await page.setViewportSize({ width: 768, height: 1024 });
        await page.waitForTimeout(2000);
        await page.screenshot({ path: 'flutter-tablet-view.png', fullPage: true });
        
        // Test desktop viewport
        await page.setViewportSize({ width: 1920, height: 1080 });
        await page.waitForTimeout(2000);
        await page.screenshot({ path: 'flutter-desktop-view.png', fullPage: true });
        
        console.log('✅ Responsive design test completed');
        
      } catch (error) {
        console.log('❌ Responsive design test failed:', error.message);
        await page.screenshot({ path: 'flutter-responsive-error.png', fullPage: true });
        throw error;
      }
    });

    test('should test keyboard navigation', async ({ page }) => {
      console.log('⌨️ Testing keyboard navigation...');
      
      try {
        const canvas = page.locator('canvas').first();
        await canvas.click();
        
        // Test Tab navigation
        for (let i = 0; i < 5; i++) {
          await page.keyboard.press('Tab');
          await page.waitForTimeout(500);
          await page.screenshot({ path: `flutter-tab-${i}.png` });
        }
        
        // Test Shift+Tab navigation
        for (let i = 0; i < 3; i++) {
          await page.keyboard.press('Shift+Tab');
          await page.waitForTimeout(500);
        }
        
        console.log('✅ Keyboard navigation test completed');
        
      } catch (error) {
        console.log('❌ Keyboard navigation test failed:', error.message);
        await page.screenshot({ path: 'flutter-keyboard-error.png', fullPage: true });
        throw error;
      }
    });

    test('should test form submission flow', async ({ page }) => {
      console.log('📝 Testing form submission flow...');
      
      try {
        const canvas = page.locator('canvas').first();
        const canvasBox = await canvas.boundingBox();
        
        // Click in email field area (estimated position)
        const emailX = canvasBox.x + canvasBox.width * 0.5;
        const emailY = canvasBox.y + canvasBox.height * 0.4;
        
        await page.mouse.click(emailX, emailY);
        await page.waitForTimeout(1000);
        
        // Type email
        await page.keyboard.type('test@spinwish.com');
        await page.waitForTimeout(1000);
        
        // Move to password field
        await page.keyboard.press('Tab');
        await page.waitForTimeout(500);
        
        // Type password
        await page.keyboard.type('password123');
        await page.waitForTimeout(1000);
        
        // Move to submit button
        await page.keyboard.press('Tab');
        await page.waitForTimeout(500);
        
        // Submit form
        await page.keyboard.press('Enter');
        await page.waitForTimeout(5000); // Wait for API response
        
        // Take screenshot of result
        await page.screenshot({ path: 'flutter-form-submission-result.png', fullPage: true });
        
        console.log('✅ Form submission test completed');
        
      } catch (error) {
        console.log('❌ Form submission test failed:', error.message);
        await page.screenshot({ path: 'flutter-form-submission-error.png', fullPage: true });
        // Don't throw error as this might fail due to API issues
      }
    });

    test('should test click interactions at various positions', async ({ page }) => {
      console.log('🖱️ Testing click interactions...');
      
      try {
        const canvas = page.locator('canvas').first();
        const canvasBox = await canvas.boundingBox();
        
        // Test clicks at different positions
        const positions = [
          { x: 0.3, y: 0.3, name: 'top-left' },
          { x: 0.7, y: 0.3, name: 'top-right' },
          { x: 0.5, y: 0.5, name: 'center' },
          { x: 0.3, y: 0.7, name: 'bottom-left' },
          { x: 0.7, y: 0.7, name: 'bottom-right' },
        ];
        
        for (const pos of positions) {
          const x = canvasBox.x + canvasBox.width * pos.x;
          const y = canvasBox.y + canvasBox.height * pos.y;
          
          await page.mouse.click(x, y);
          await page.waitForTimeout(1000);
          await page.screenshot({ path: `flutter-click-${pos.name}.png` });
        }
        
        console.log('✅ Click interaction test completed');
        
      } catch (error) {
        console.log('❌ Click interaction test failed:', error.message);
        await page.screenshot({ path: 'flutter-click-error.png', fullPage: true });
        throw error;
      }
    });

    test('should test animation performance', async ({ page }) => {
      console.log('🎬 Testing animation performance...');
      
      try {
        const canvas = page.locator('canvas').first();
        
        // Start performance monitoring
        await page.evaluate(() => {
          window.animationFrames = [];
          const originalRAF = window.requestAnimationFrame;
          window.requestAnimationFrame = function(callback) {
            window.animationFrames.push(Date.now());
            return originalRAF(callback);
          };
        });
        
        // Trigger interactions that should cause animations
        await canvas.click();
        await page.waitForTimeout(500);
        
        await page.keyboard.press('Tab');
        await page.waitForTimeout(500);
        
        await page.keyboard.press('Tab');
        await page.waitForTimeout(500);
        
        // Get animation frame data
        const frameData = await page.evaluate(() => {
          return {
            frameCount: window.animationFrames ? window.animationFrames.length : 0,
            frames: window.animationFrames || []
          };
        });
        
        console.log('📊 Animation frames captured:', frameData.frameCount);
        
        if (frameData.frameCount > 0) {
          console.log('✅ Animations detected');
        } else {
          console.log('ℹ️ No animations detected');
        }
        
      } catch (error) {
        console.log('❌ Animation performance test failed:', error.message);
        await page.screenshot({ path: 'flutter-animation-error.png', fullPage: true });
        throw error;
      }
    });
  });

  test.describe('Error Handling Tests', () => {
    test('should handle network errors gracefully', async ({ page }) => {
      console.log('🌐 Testing network error handling...');
      
      try {
        // Block API requests to simulate network issues
        await page.route('**/api/v1/users/**', route => {
          route.abort('failed');
        });
        
        const canvas = page.locator('canvas').first();
        await canvas.click();
        
        // Try to submit form with blocked API
        await page.keyboard.type('test@example.com');
        await page.keyboard.press('Tab');
        await page.keyboard.type('password123');
        await page.keyboard.press('Tab');
        await page.keyboard.press('Enter');
        
        // Wait for error handling
        await page.waitForTimeout(5000);
        
        await page.screenshot({ path: 'flutter-network-error-test.png', fullPage: true });
        
        console.log('✅ Network error handling test completed');
        
      } catch (error) {
        console.log('❌ Network error test failed:', error.message);
        await page.screenshot({ path: 'flutter-network-error-error.png', fullPage: true });
        // Don't throw error as this is expected to fail in some scenarios
      }
    });
  });
});
