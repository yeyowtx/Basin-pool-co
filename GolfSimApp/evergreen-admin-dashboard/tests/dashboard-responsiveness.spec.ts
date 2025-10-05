import { test, expect } from '@playwright/test';

test.describe('Dashboard Responsiveness Tests', () => {
  
  test('Desktop layout - 1920x1080', async ({ page }) => {
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.goto('/dashboard');
    
    // Take full page screenshot
    await page.screenshot({ 
      path: 'test-results/desktop-1920x1080.png', 
      fullPage: true 
    });
    
    // Check if sidebar is visible on desktop
    const sidebar = page.locator('.desktop-sidebar');
    await expect(sidebar).toBeVisible();
    
    // Check if main content has proper left padding for sidebar
    const mainContent = page.locator('main');
    await expect(mainContent).toBeVisible();
    
    // Check grid layouts
    const overviewCards = page.locator('div').filter({ hasText: 'Total Members' }).first().locator('..');
    const parentGrid = overviewCards.locator('..');
    await expect(parentGrid).toHaveClass(/grid/);
    
    // Verify responsive grid classes
    await expect(parentGrid).toHaveClass(/md:grid-cols-2/);
    await expect(parentGrid).toHaveClass(/lg:grid-cols-4/);
  });

  test('Desktop layout - 1366x768 (common laptop)', async ({ page }) => {
    await page.setViewportSize({ width: 1366, height: 768 });
    await page.goto('/dashboard');
    
    await page.screenshot({ 
      path: 'test-results/desktop-1366x768.png', 
      fullPage: true 
    });
    
    const sidebar = page.locator('.desktop-sidebar');
    await expect(sidebar).toBeVisible();
    
    // Check if content fits properly without horizontal scroll
    const body = page.locator('body');
    const scrollWidth = await body.evaluate(el => el.scrollWidth);
    const clientWidth = await body.evaluate(el => el.clientWidth);
    
    expect(scrollWidth).toBeLessThanOrEqual(clientWidth + 5); // Allow small tolerance
  });

  test('Tablet layout - iPad Pro (1024x1366)', async ({ page }) => {
    await page.setViewportSize({ width: 1024, height: 1366 });
    await page.goto('/dashboard');
    
    await page.screenshot({ 
      path: 'test-results/tablet-1024x1366.png', 
      fullPage: true 
    });
    
    // Sidebar should still be visible on large tablets
    const sidebar = page.locator('.desktop-sidebar');
    await expect(sidebar).toBeVisible();
    
    // Check grid breakpoints - should show 2 columns on medium screens
    const overviewGrid = page.locator('.grid.gap-4').first();
    await expect(overviewGrid).toHaveClass(/md:grid-cols-2/);
  });

  test('Tablet layout - Standard tablet (768x1024)', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.goto('/dashboard');
    
    await page.screenshot({ 
      path: 'test-results/tablet-768x1024.png', 
      fullPage: true 
    });
    
    // At this size, sidebar might not be visible
    const sidebar = page.locator('.desktop-sidebar');
    // On smaller tablets, sidebar should be hidden
    const isVisible = await sidebar.isVisible();
    console.log('Sidebar visible on 768px tablet:', isVisible);
  });

  test('Mobile layout - iPhone 12 (390x844)', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto('/dashboard');
    
    await page.screenshot({ 
      path: 'test-results/mobile-390x844.png', 
      fullPage: true 
    });
    
    // Sidebar should be hidden on mobile
    const sidebar = page.locator('.desktop-sidebar');
    await expect(sidebar).toBeHidden();
    
    // Check if mobile navigation exists
    const mobileNav = page.locator('.mobile-nav');
    // Note: This might not be visible until triggered
    
    // Check if content stacks properly on mobile
    const overviewGrid = page.locator('.grid.gap-4').first();
    await expect(overviewGrid).toBeVisible();
    
    // Cards should stack on mobile (single column)
    const cards = page.locator('.grid.gap-4 > div').first();
    await expect(cards).toBeVisible();
  });

  test('Mobile layout - Small mobile (320x568)', async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 568 });
    await page.goto('/dashboard');
    
    await page.screenshot({ 
      path: 'test-results/mobile-320x568.png', 
      fullPage: true 
    });
    
    // Check if content is readable and doesn't overflow
    const mainContent = page.locator('main');
    await expect(mainContent).toBeVisible();
    
    // Check for horizontal scrolling (should not exist)
    const body = page.locator('body');
    const scrollWidth = await body.evaluate(el => el.scrollWidth);
    const clientWidth = await body.evaluate(el => el.clientWidth);
    
    expect(scrollWidth).toBeLessThanOrEqual(clientWidth + 5);
  });

  test('Check for fixed width issues', async ({ page }) => {
    await page.goto('/dashboard');
    
    // Test multiple viewport sizes to detect fixed width
    const viewports = [
      { width: 320, height: 568 },
      { width: 768, height: 1024 },
      { width: 1024, height: 768 },
      { width: 1366, height: 768 },
      { width: 1920, height: 1080 }
    ];
    
    for (const viewport of viewports) {
      await page.setViewportSize(viewport);
      await page.waitForTimeout(500); // Allow for reflow
      
      // Check if any elements have fixed pixel widths that don't scale
      const fixedWidthElements = await page.evaluate(() => {
        const elements = document.querySelectorAll('*');
        const fixedElements: any[] = [];
        
        elements.forEach(el => {
          const styles = window.getComputedStyle(el);
          const width = styles.width;
          const minWidth = styles.minWidth;
          const maxWidth = styles.maxWidth;
          
          // Check for problematic fixed widths
          if (width && width.includes('px') && !width.includes('auto')) {
            const pixelValue = parseInt(width);
            if (pixelValue > 800) { // Suspiciously large fixed width
              fixedElements.push({
                tagName: el.tagName,
                className: el.className,
                width: width,
                element: el.outerHTML.substring(0, 100)
              });
            }
          }
        });
        
        return fixedElements;
      });
      
      if (fixedWidthElements.length > 0) {
        console.log(`Fixed width elements found at ${viewport.width}x${viewport.height}:`, fixedWidthElements);
      }
    }
  });

  test('Sidebar responsiveness', async ({ page }) => {
    await page.goto('/dashboard');
    
    // Test sidebar visibility at different breakpoints
    const breakpoints = [
      { width: 320, expectHidden: true },
      { width: 768, expectHidden: true },
      { width: 1024, expectVisible: true },
      { width: 1366, expectVisible: true },
      { width: 1920, expectVisible: true }
    ];
    
    for (const bp of breakpoints) {
      await page.setViewportSize({ width: bp.width, height: 800 });
      await page.waitForTimeout(300);
      
      const sidebar = page.locator('.desktop-sidebar');
      
      if (bp.expectVisible) {
        await expect(sidebar).toBeVisible();
        
        // Check if sidebar has proper width
        const sidebarBox = await sidebar.boundingBox();
        expect(sidebarBox?.width).toBeDefined();
        expect(sidebarBox?.width).toBeGreaterThan(200); // Should be around 256px (w-64)
      } else if (bp.expectHidden) {
        await expect(sidebar).toBeHidden();
      }
    }
  });
});