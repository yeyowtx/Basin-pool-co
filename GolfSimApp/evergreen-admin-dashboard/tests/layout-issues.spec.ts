import { test, expect } from '@playwright/test';

test.describe('Layout Issues Detection', () => {

  test('Detect fixed width containers and elements', async ({ page }) => {
    await page.goto('/dashboard');
    
    // Comprehensive scan for fixed width issues
    const fixedWidthIssues = await page.evaluate(() => {
      const issues: any[] = [];
      const elements = document.querySelectorAll('*');
      
      elements.forEach((el, index) => {
        const styles = window.getComputedStyle(el);
        const rect = el.getBoundingClientRect();
        
        // Check for fixed pixel widths
        if (styles.width && styles.width.includes('px') && !styles.width.includes('auto')) {
          const pixelValue = parseInt(styles.width);
          if (pixelValue > 500) { // Suspiciously large fixed width
            issues.push({
              type: 'fixed-width',
              element: el.tagName + (el.className ? '.' + el.className.split(' ').join('.') : ''),
              width: styles.width,
              computed: pixelValue,
              rect: { width: rect.width, height: rect.height }
            });
          }
        }
        
        // Check for elements extending beyond viewport
        if (rect.right > window.innerWidth) {
          issues.push({
            type: 'overflow-right',
            element: el.tagName + (el.className ? '.' + el.className.split(' ').join('.') : ''),
            rightPosition: rect.right,
            viewportWidth: window.innerWidth,
            overflow: rect.right - window.innerWidth
          });
        }
        
        // Check for min-width issues
        if (styles.minWidth && styles.minWidth.includes('px')) {
          const minWidthValue = parseInt(styles.minWidth);
          if (minWidthValue > 800) {
            issues.push({
              type: 'large-min-width',
              element: el.tagName + (el.className ? '.' + el.className.split(' ').join('.') : ''),
              minWidth: styles.minWidth,
              computed: minWidthValue
            });
          }
        }
      });
      
      return issues;
    });
    
    console.log('Fixed width issues found:', fixedWidthIssues);
    
    // Take screenshot for visual reference
    await page.screenshot({ 
      path: 'test-results/fixed-width-analysis.png', 
      fullPage: true 
    });
    
    // Log issues but don't fail test unless critical
    if (fixedWidthIssues.length > 0) {
      console.log(`Found ${fixedWidthIssues.length} potential layout issues:`);
      fixedWidthIssues.forEach((issue, i) => {
        console.log(`${i + 1}. ${issue.type}: ${issue.element}`);
      });
    }
  });

  test('Test container max-width behavior', async ({ page }) => {
    await page.goto('/dashboard');
    
    // Test the main container behavior
    const maxWidthTests = await page.evaluate(() => {
      const results: any[] = [];
      
      // Find elements with max-width classes
      const containers = document.querySelectorAll('[class*="max-w"]');
      
      containers.forEach(container => {
        const styles = window.getComputedStyle(container);
        const rect = container.getBoundingClientRect();
        
        results.push({
          element: container.tagName + '.' + Array.from(container.classList).join('.'),
          maxWidth: styles.maxWidth,
          actualWidth: rect.width,
          className: container.className
        });
      });
      
      return results;
    });
    
    console.log('Max-width containers:', maxWidthTests);
    
    // Check for the main content container
    const mainContainer = page.locator('.max-w-7xl');
    if (await mainContainer.count() > 0) {
      await expect(mainContainer).toBeVisible();
      
      // Test at different viewport sizes
      const viewports = [1200, 1400, 1600, 1920];
      
      for (const width of viewports) {
        await page.setViewportSize({ width, height: 800 });
        await page.waitForTimeout(200);
        
        const containerWidth = await mainContainer.evaluate(el => {
          const rect = el.getBoundingClientRect();
          const styles = window.getComputedStyle(el);
          return {
            actualWidth: rect.width,
            maxWidth: styles.maxWidth,
            viewportWidth: window.innerWidth
          };
        });
        
        console.log(`Viewport ${width}px:`, containerWidth);
        
        // Container should not exceed its max-width
        if (containerWidth.maxWidth !== 'none') {
          const maxWidthPx = parseInt(containerWidth.maxWidth);
          expect(containerWidth.actualWidth).toBeLessThanOrEqual(maxWidthPx + 5);
        }
      }
    }
    
    await page.screenshot({ path: 'test-results/container-max-width.png' });
  });

  test('Grid responsiveness issues', async ({ page }) => {
    await page.goto('/dashboard');
    
    // Test grid behavior at different breakpoints
    const breakpoints = [
      { name: 'mobile', width: 375 },
      { name: 'tablet', width: 768 },
      { name: 'laptop', width: 1024 },
      { name: 'desktop', width: 1280 },
      { name: 'wide', width: 1920 }
    ];
    
    for (const bp of breakpoints) {
      await page.setViewportSize({ width: bp.width, height: 800 });
      await page.waitForTimeout(300);
      
      // Analyze grid layouts
      const gridAnalysis = await page.evaluate((breakpointName) => {
        const grids = document.querySelectorAll('.grid');
        const results: any[] = [];
        
        grids.forEach((grid, index) => {
          const styles = window.getComputedStyle(grid);
          const rect = grid.getBoundingClientRect();
          
          results.push({
            gridIndex: index,
            breakpoint: breakpointName,
            gridTemplateColumns: styles.gridTemplateColumns,
            className: grid.className,
            width: rect.width,
            children: grid.children.length
          });
        });
        
        return results;
      }, bp.name);
      
      console.log(`Grid analysis at ${bp.name} (${bp.width}px):`, gridAnalysis);
      
      await page.screenshot({ 
        path: `test-results/grid-${bp.name}-${bp.width}px.png`,
        fullPage: true 
      });
    }
  });

  test('Sidebar layout impact', async ({ page }) => {
    await page.goto('/dashboard');
    
    // Test how sidebar affects main content layout
    const sidebarTests = [
      { width: 1024, expectSidebar: true },
      { width: 768, expectSidebar: false },
      { width: 1200, expectSidebar: true },
      { width: 1920, expectSidebar: true }
    ];
    
    for (const test of sidebarTests) {
      await page.setViewportSize({ width: test.width, height: 800 });
      await page.waitForTimeout(300);
      
      const sidebar = page.locator('.desktop-sidebar');
      const mainContent = page.locator('main');
      
      const sidebarVisible = await sidebar.isVisible();
      expect(sidebarVisible).toBe(test.expectSidebar);
      
      if (sidebarVisible) {
        // Check if main content is properly positioned
        const sidebarBox = await sidebar.boundingBox();
        const mainBox = await mainContent.boundingBox();
        
        if (sidebarBox && mainBox) {
          // Main content should start after sidebar
          expect(mainBox.x).toBeGreaterThanOrEqual(sidebarBox.width - 10);
        }
      }
      
      // Check for content overflow
      const contentOverflow = await page.evaluate(() => {
        const body = document.body;
        return {
          scrollWidth: body.scrollWidth,
          clientWidth: body.clientWidth,
          hasHorizontalScroll: body.scrollWidth > body.clientWidth
        };
      });
      
      if (contentOverflow.hasHorizontalScroll) {
        console.log(`Horizontal scroll detected at ${test.width}px:`, contentOverflow);
      }
      
      await page.screenshot({ 
        path: `test-results/sidebar-layout-${test.width}px.png`,
        fullPage: true 
      });
    }
  });

  test('Content padding and spacing issues', async ({ page }) => {
    await page.goto('/dashboard');
    
    // Check if content has proper padding/margins
    const spacingAnalysis = await page.evaluate(() => {
      const results: any[] = [];
      
      // Check main content container
      const main = document.querySelector('main');
      if (main) {
        const styles = window.getComputedStyle(main);
        const rect = main.getBoundingClientRect();
        
        results.push({
          element: 'main',
          padding: {
            top: styles.paddingTop,
            right: styles.paddingRight,
            bottom: styles.paddingBottom,
            left: styles.paddingLeft
          },
          margin: {
            top: styles.marginTop,
            right: styles.marginRight,
            bottom: styles.marginBottom,
            left: styles.marginLeft
          },
          position: {
            x: rect.x,
            y: rect.y,
            width: rect.width,
            height: rect.height
          }
        });
      }
      
      // Check content wrapper
      const contentWrapper = document.querySelector('.max-w-7xl');
      if (contentWrapper) {
        const styles = window.getComputedStyle(contentWrapper);
        const rect = contentWrapper.getBoundingClientRect();
        
        results.push({
          element: 'content-wrapper',
          padding: {
            top: styles.paddingTop,
            right: styles.paddingRight,
            bottom: styles.paddingBottom,
            left: styles.paddingLeft
          },
          margin: {
            top: styles.marginTop,
            right: styles.marginRight,
            bottom: styles.marginBottom,
            left: styles.marginLeft
          },
          position: {
            x: rect.x,
            y: rect.y,
            width: rect.width,
            height: rect.height
          }
        });
      }
      
      return results;
    });
    
    console.log('Spacing analysis:', spacingAnalysis);
    
    // Test at mobile size for spacing issues
    await page.setViewportSize({ width: 375, height: 667 });
    await page.waitForTimeout(300);
    
    const mobileSpacing = await page.evaluate(() => {
      const contentWrapper = document.querySelector('.max-w-7xl');
      if (contentWrapper) {
        const rect = contentWrapper.getBoundingClientRect();
        return {
          leftMargin: rect.x,
          rightMargin: window.innerWidth - (rect.x + rect.width),
          hasProperPadding: rect.x > 10 && (window.innerWidth - (rect.x + rect.width)) > 10
        };
      }
      return null;
    });
    
    console.log('Mobile spacing analysis:', mobileSpacing);
    
    await page.screenshot({ 
      path: 'test-results/content-spacing-mobile.png',
      fullPage: true 
    });
  });

  test('Typography and text scaling', async ({ page }) => {
    await page.goto('/dashboard');
    
    // Test text scaling at different viewport sizes
    const textScalingTests = [
      { width: 320, name: 'small-mobile' },
      { width: 375, name: 'mobile' },
      { width: 768, name: 'tablet' },
      { width: 1024, name: 'desktop' },
      { width: 1920, name: 'large-desktop' }
    ];
    
    for (const test of textScalingTests) {
      await page.setViewportSize({ width: test.width, height: 800 });
      await page.waitForTimeout(300);
      
      const typographyAnalysis = await page.evaluate((testName) => {
        const results: any[] = [];
        
        // Check main heading
        const h1 = document.querySelector('h1');
        if (h1) {
          const styles = window.getComputedStyle(h1);
          const rect = h1.getBoundingClientRect();
          
          results.push({
            element: 'h1',
            fontSize: styles.fontSize,
            lineHeight: styles.lineHeight,
            width: rect.width,
            height: rect.height,
            testName
          });
        }
        
        // Check card titles
        const cardTitles = document.querySelectorAll('[class*="CardTitle"]');
        cardTitles.forEach((title, index) => {
          if (index < 3) { // Only check first 3
            const styles = window.getComputedStyle(title);
            const rect = title.getBoundingClientRect();
            
            results.push({
              element: `card-title-${index}`,
              fontSize: styles.fontSize,
              lineHeight: styles.lineHeight,
              width: rect.width,
              height: rect.height,
              testName
            });
          }
        });
        
        return results;
      }, test.name);
      
      console.log(`Typography at ${test.name} (${test.width}px):`, typographyAnalysis);
      
      await page.screenshot({ 
        path: `test-results/typography-${test.name}.png`
      });
    }
  });
});