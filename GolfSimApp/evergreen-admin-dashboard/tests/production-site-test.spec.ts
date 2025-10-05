import { test, expect } from '@playwright/test';

test.describe('Production Dashboard - Essential UI/UX Tests', () => {
  
  test('Dashboard loads successfully on desktop', async ({ page }) => {
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.goto('/');
    
    // Basic page load check
    await expect(page.locator('h1')).toContainText('Evergreen Golf Club');
    
    // Essential admin metrics should be visible
    await expect(page.locator('text=Total Members')).toBeVisible();
    await expect(page.locator('text=Daily Revenue')).toBeVisible();
    await expect(page.locator('text=Bay Utilization')).toBeVisible();
    
    // Real-time features should be displayed
    await expect(page.locator('text=Real-Time Bay Status')).toBeVisible();
    
    // Beta notice should be present
    await expect(page.locator('text=Beta Dashboard')).toBeVisible();
  });

  test('Responsive layout - Fixed width issue resolved', async ({ page }) => {
    // Test ultra-wide screen (where the "fixed width" issue was most apparent)
    await page.setViewportSize({ width: 2560, height: 1440 });
    await page.goto('/');
    
    // Wait for page to load
    await page.waitForLoadState('networkidle');
    
    // Main content container should use available space
    const mainContent = page.locator('main .py-6 > div');
    const boundingBox = await mainContent.boundingBox();
    
    // Content should be wider than the old max-w-7xl constraint (1280px)
    expect(boundingBox?.width).toBeGreaterThan(1400);
    console.log(`Content width: ${boundingBox?.width}px (should be > 1400px)`);
    
    // Cards should be properly distributed
    const overviewCards = page.locator('[data-testid="overview-cards"]');
    await expect(overviewCards).toBeVisible();
    
    // Screenshot for visual verification
    await page.screenshot({ path: 'test-results/ultra-wide-layout.png', fullPage: true });
  });

  test('Mobile responsive layout', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/');
    
    // Mobile navigation should be visible
    await expect(page.locator('.mobile-nav')).toBeVisible();
    
    // Desktop sidebar should be hidden
    await expect(page.locator('.desktop-sidebar')).toBeHidden();
    
    // Key content should still be accessible
    await expect(page.locator('text=Total Members')).toBeVisible();
    
    // Screenshot for mobile layout verification
    await page.screenshot({ path: 'test-results/mobile-layout.png', fullPage: true });
  });

  test('Essential admin functionality present', async ({ page }) => {
    await page.goto('/');
    
    // Core admin management features should be displayed
    const essentialFeatures = [
      'Real-Time Bay Status',
      'Booking Management', 
      'Member Analytics',
      'Advanced booking system with 15-minute buffers',
      'Track membership growth and engagement'
    ];
    
    for (const feature of essentialFeatures) {
      await expect(page.locator(`text=${feature}`)).toBeVisible();
    }
    
    // Membership tiers should be shown
    await expect(page.locator('text=Rainier (Premium)')).toBeVisible();
    await expect(page.locator('text=Pike (Standard)')).toBeVisible();
    await expect(page.locator('text=Cascade (Basic)')).toBeVisible();
    
    // Beta roadmap should indicate hybrid architecture
    await expect(page.locator('text=Hybrid Architecture')).toBeVisible();
  });

  test('Performance and load time', async ({ page }) => {
    const startTime = Date.now();
    
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    const loadTime = Date.now() - startTime;
    console.log(`Page load time: ${loadTime}ms`);
    
    // Page should load within reasonable time for admin dashboard
    expect(loadTime).toBeLessThan(8000);
    
    // Essential elements should be visible quickly
    await expect(page.locator('h1')).toBeVisible();
    await expect(page.locator('[data-testid="overview-cards"]')).toBeVisible();
  });
});