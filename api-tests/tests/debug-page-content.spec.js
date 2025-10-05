const { test, expect } = require('@playwright/test');

test.describe('Debug Page Content', () => {
  const flutterAppURL = 'http://localhost:3000';

  test('should inspect page content and take screenshot', async ({ page }) => {
    console.log('🔍 Inspecting page content...');
    
    try {
      // Navigate to the Flutter app
      await page.goto(flutterAppURL);
      await page.waitForLoadState('networkidle');
      
      // Wait a bit more for Flutter to fully load
      await page.waitForTimeout(5000);
      
      // Take a screenshot
      await page.screenshot({ path: 'flutter-app-current-state.png', fullPage: true });
      
      // Get page title
      const title = await page.title();
      console.log('📄 Page title:', title);
      
      // Get all text content
      const bodyText = await page.locator('body').textContent();
      console.log('📝 Page text content:', bodyText?.substring(0, 500) + '...');
      
      // Check for Flutter-specific elements
      const flutterView = page.locator('flutter-view, flt-glass-pane, [flt-renderer]');
      const hasFlutterView = await flutterView.count();
      console.log('🎯 Flutter view elements found:', hasFlutterView);
      
      // Check for any input elements
      const inputs = page.locator('input');
      const inputCount = await inputs.count();
      console.log('📝 Input elements found:', inputCount);
      
      if (inputCount > 0) {
        for (let i = 0; i < inputCount; i++) {
          const input = inputs.nth(i);
          const type = await input.getAttribute('type');
          const placeholder = await input.getAttribute('placeholder');
          const ariaLabel = await input.getAttribute('aria-label');
          console.log(`Input ${i}: type=${type}, placeholder=${placeholder}, aria-label=${ariaLabel}`);
        }
      }
      
      // Check for any buttons
      const buttons = page.locator('button, [role="button"]');
      const buttonCount = await buttons.count();
      console.log('🔘 Button elements found:', buttonCount);
      
      if (buttonCount > 0) {
        for (let i = 0; i < Math.min(buttonCount, 5); i++) {
          const button = buttons.nth(i);
          const text = await button.textContent();
          const ariaLabel = await button.getAttribute('aria-label');
          console.log(`Button ${i}: text="${text}", aria-label=${ariaLabel}`);
        }
      }
      
      // Check for any clickable text elements
      const clickableTexts = page.locator('text=/Sign|Login|Register|Up|In/i');
      const clickableCount = await clickableTexts.count();
      console.log('🔗 Clickable text elements found:', clickableCount);
      
      if (clickableCount > 0) {
        for (let i = 0; i < Math.min(clickableCount, 5); i++) {
          const text = await clickableTexts.nth(i).textContent();
          console.log(`Clickable text ${i}: "${text}"`);
        }
      }
      
      // Check for Flutter canvas elements
      const canvases = page.locator('canvas');
      const canvasCount = await canvases.count();
      console.log('🎨 Canvas elements found:', canvasCount);
      
      // Check for any form elements
      const forms = page.locator('form');
      const formCount = await forms.count();
      console.log('📋 Form elements found:', formCount);
      
      // Get all semantic elements
      const semanticElements = await page.evaluate(() => {
        const elements = [];
        const walker = document.createTreeWalker(
          document.body,
          NodeFilter.SHOW_ELEMENT,
          {
            acceptNode: function(node) {
              if (node.tagName && (
                node.tagName.toLowerCase().includes('input') ||
                node.tagName.toLowerCase().includes('button') ||
                node.tagName.toLowerCase().includes('form') ||
                node.hasAttribute('role') ||
                node.hasAttribute('aria-label') ||
                node.textContent?.toLowerCase().includes('sign') ||
                node.textContent?.toLowerCase().includes('login') ||
                node.textContent?.toLowerCase().includes('email') ||
                node.textContent?.toLowerCase().includes('password')
              )) {
                return NodeFilter.FILTER_ACCEPT;
              }
              return NodeFilter.FILTER_SKIP;
            }
          }
        );
        
        let node;
        while (node = walker.nextNode()) {
          elements.push({
            tagName: node.tagName,
            textContent: node.textContent?.substring(0, 100),
            attributes: Array.from(node.attributes || []).map(attr => `${attr.name}="${attr.value}"`),
            className: node.className
          });
        }
        return elements;
      });
      
      console.log('🏷️ Semantic elements found:', semanticElements.length);
      semanticElements.forEach((el, i) => {
        console.log(`Element ${i}:`, JSON.stringify(el, null, 2));
      });
      
      console.log('✅ Page inspection complete');
      
    } catch (error) {
      console.log('❌ Page inspection failed:', error.message);
      await page.screenshot({ path: 'debug-error.png', fullPage: true });
      throw error;
    }
  });
});
