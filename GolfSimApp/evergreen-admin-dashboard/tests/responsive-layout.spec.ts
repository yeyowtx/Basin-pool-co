import { test, expect } from '@playwright/test';

test.describe('Evergreen Admin Dashboard - Responsive Layout Tests', () => {
  
  test('Mobile (375px) - Should display mobile navigation and stack cards vertically', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/');
    
    // Check mobile navigation is visible
    await expect(page.locator('.mobile-nav')).toBeVisible();
    
    // Check desktop sidebar is hidden
    await expect(page.locator('.desktop-sidebar')).toBeHidden();
    
    // Verify cards stack vertically (1 column)
    const overviewCards = page.locator('[data-testid="overview-cards"] > div').first();
    const cardWidth = await overviewCards.boundingBox();
    expect(cardWidth?.width).toBeGreaterThan(300); // Should use most of mobile width
    
    // Check mobile navigation icons are functional
    await page.click('text=Members');
    await expect(page).toHaveURL(/\/dashboard\/members/);
  });

  test('Tablet (768px) - Should display 2-column layout', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.goto('/');
    
    // Desktop sidebar should still be hidden
    await expect(page.locator('.desktop-sidebar')).toBeHidden();
    
    // Mobile nav should be visible
    await expect(page.locator('.mobile-nav')).toBeVisible();
    
    // Overview cards should be in 2 columns on tablet
    const cardsContainer = page.locator('[data-testid="overview-cards"]');
    await expect(cardsContainer).toHaveCSS('grid-template-columns', /repeat\(2,/);
  });

  test('Desktop (1024px+) - Should display sidebar and multi-column layout', async ({ page }) => {
    await page.setViewportSize({ width: 1024, height: 768 });
    await page.goto('/');
    
    // Desktop sidebar should be visible
    await expect(page.locator('.desktop-sidebar')).toBeVisible();
    
    // Mobile nav should be hidden
    await expect(page.locator('.mobile-nav')).toBeHidden();
    
    // Overview cards should be in 4 columns
    const cardsContainer = page.locator('[data-testid="overview-cards"]');
    await expect(cardsContainer).toHaveCSS('grid-template-columns', /repeat\(4,/);
    
    // Test sidebar navigation
    await page.click('text=Members');
    await expect(page).toHaveURL(/\/dashboard\/members/);
  });

  test('Ultra Wide (2560px) - Should use full width without fixed constraints', async ({ page }) => {
    await page.setViewportSize({ width: 2560, height: 1440 });
    await page.goto('/');
    
    // Main content should use available space, not be constrained to 1280px
    const mainContent = page.locator('main .py-6 > div');
    const contentBox = await mainContent.boundingBox();
    
    // Content should be wider than the old max-w-7xl constraint (1280px)
    expect(contentBox?.width).toBeGreaterThan(1400);
    
    // Cards should utilize the extra space effectively
    const featureCards = page.locator('[data-testid="feature-cards"]');
    await expect(featureCards).toHaveCSS('grid-template-columns', /repeat\(3,/);
  });

  test('Page Content - Essential Admin UI Elements', async ({ page }) => {
    await page.goto('/');
    
    // Check essential dashboard metrics are present
    await expect(page.locator('text=Total Members')).toBeVisible();
    await expect(page.locator('text=Today\'s Bookings')).toBeVisible();
    await expect(page.locator('text=Daily Revenue')).toBeVisible();
    await expect(page.locator('text=Bay Utilization')).toBeVisible();
    
    // Check real-time bay status feature
    await expect(page.locator('text=Real-Time Bay Status')).toBeVisible();
    await expect(page.locator('text=Available')).toBeVisible();
    await expect(page.locator('text=Occupied')).toBeVisible();
    await expect(page.locator('text=Cleaning')).toBeVisible();
    
    // Check membership tier display
    await expect(page.locator('text=Rainier (Premium)')).toBeVisible();
    await expect(page.locator('text=Pike (Standard)')).toBeVisible();
    await expect(page.locator('text=Cascade (Basic)')).toBeVisible();
    
    // Check beta notice and feature roadmap
    await expect(page.locator('text=Beta Dashboard - September 2025 Launch')).toBeVisible();
    await expect(page.locator('text=Hybrid Architecture')).toBeVisible();
  });

  test('Navigation Functionality', async ({ page }) => {
    await page.goto('/');
    
    // Test desktop navigation (if visible)
    if (await page.locator('.desktop-sidebar').isVisible()) {
      await page.click('.desktop-sidebar >> text=Dashboard');
      await expect(page).toHaveURL(/\/dashboard$/);
      
      // Check active state styling
      const activeLink = page.locator('.desktop-sidebar >> text=Dashboard').locator('..');
      await expect(activeLink).toHaveClass(/bg-evergreen-primary/);
    }
    
    // Test mobile navigation (if visible)
    if (await page.locator('.mobile-nav').isVisible()) {
      await page.click('.mobile-nav >> text=Dashboard');
      await expect(page).toHaveURL(/\/dashboard$/);
    }
  });

  test('Performance - Page Load and Interactivity', async ({ page }) => {
    const start = Date.now();
    await page.goto('/');
    
    // Page should load within reasonable time
    const loadTime = Date.now() - start;
    expect(loadTime).toBeLessThan(5000);
    
    // Key elements should be interactive
    await expect(page.locator('h1')).toBeVisible();
    await expect(page.locator('[data-testid="overview-cards"]')).toBeVisible();
    
    // No console errors related to layout
    const errors = [];
    page.on('console', msg => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });
    
    // Interact with elements to trigger any layout issues
    await page.hover('[data-testid="overview-cards"] >> nth=0');
    await page.waitForTimeout(1000);
    
    // Check for layout-related errors
    const layoutErrors = errors.filter(error => 
      error.includes('width') || 
      error.includes('responsive') || 
      error.includes('grid') ||
      error.includes('flex')
    );
    expect(layoutErrors).toHaveLength(0);
  });
});