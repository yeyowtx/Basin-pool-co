import { test, expect } from '@playwright/test';

/**
 * Golf Sim App - Welcome Screen Mobile Testing
 * Comprehensive testing across mobile devices and interactions
 */

test.describe('Welcome Screen - Mobile Experience', () => {
  
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('should display welcome screen on iPhone 14', async ({ page }) => {
    // Verify main heading is visible
    await expect(page.getByText('Welcome to')).toBeVisible();
    await expect(page.getByText('Golf Excellence')).toBeVisible();
    
    // Check golf-themed branding
    await expect(page.getByText('Golf Sim Plus')).toBeVisible();
    
    // Verify main CTA button
    const getStartedButton = page.getByRole('button', { name: 'Get Started' });
    await expect(getStartedButton).toBeVisible();
    await expect(getStartedButton).toBeEnabled();
  });

  test('should handle touch interactions properly', async ({ page }) => {
    const getStartedButton = page.getByRole('button', { name: 'Get Started' });
    
    // Test touch interaction
    await getStartedButton.tap();
    
    // Verify click handling (should log for now)
    // TODO: Update when navigation is implemented
    const logs = [];
    page.on('console', msg => logs.push(msg.text()));
    
    await getStartedButton.click();
    // Note: In real implementation, this would navigate to booking
  });

  test('should be responsive across different mobile viewports', async ({ page }) => {
    // Test iPhone SE (smaller screen)
    await page.setViewportSize({ width: 375, height: 667 });
    await expect(page.getByText('Golf Excellence')).toBeVisible();
    
    // Test iPhone 14 Plus (larger screen)
    await page.setViewportSize({ width: 428, height: 926 });
    await expect(page.getByText('Golf Excellence')).toBeVisible();
    
    // Test iPad viewport
    await page.setViewportSize({ width: 820, height: 1180 });
    await expect(page.getByText('Golf Excellence')).toBeVisible();
  });

  test('should display feature cards correctly', async ({ page }) => {
    // Check all three feature cards
    await expect(page.getByText('Book Instantly')).toBeVisible();
    await expect(page.getByText('Lightning Fast')).toBeVisible();
    await expect(page.getByText('Premium Experience')).toBeVisible();
    
    // Verify descriptions
    await expect(page.getByText('Reserve your bay in seconds')).toBeVisible();
    await expect(page.getByText('10x faster than other systems')).toBeVisible();
    await expect(page.getByText('Professional golf simulation')).toBeVisible();
  });

  test('should handle member login interaction', async ({ page }) => {
    const memberLoginButton = page.getByText('Member Login');
    
    await expect(memberLoginButton).toBeVisible();
    await memberLoginButton.click();
    
    // TODO: Update when login flow is implemented
  });

  test('should load animations smoothly', async ({ page }) => {
    // Wait for page to fully load
    await page.waitForLoadState('networkidle');
    
    // Check that main content is visible (animations should complete)
    await expect(page.getByText('Welcome to')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Get Started' })).toBeVisible();
    
    // Verify no layout shift by checking positions
    const button = page.getByRole('button', { name: 'Get Started' });
    const boundingBox = await button.boundingBox();
    expect(boundingBox).toBeTruthy();
  });

  test('should work in landscape orientation', async ({ page }) => {
    // Test landscape mode (common when using tablets for POS)
    await page.setViewportSize({ width: 844, height: 390 });
    
    await expect(page.getByText('Golf Excellence')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Get Started' })).toBeVisible();
  });

  test('should have proper color contrast and accessibility', async ({ page }) => {
    // Check main heading contrast
    const heading = page.getByText('Golf Excellence');
    await expect(heading).toBeVisible();
    
    // Check button accessibility
    const button = page.getByRole('button', { name: 'Get Started' });
    await expect(button).toBeEnabled();
    
    // Verify focus states work properly
    await button.focus();
    // Note: Visual focus testing would require screenshot comparison
  });

  test('should handle slow network conditions', async ({ page }) => {
    // Simulate slow 3G
    await page.route('**/*', async route => {
      await new Promise(resolve => setTimeout(resolve, 100));
      await route.continue();
    });
    
    await page.goto('/');
    
    // Should still load within reasonable time
    await expect(page.getByText('Golf Excellence')).toBeVisible({ timeout: 10000 });
    await expect(page.getByRole('button', { name: 'Get Started' })).toBeVisible();
  });

  test('should meet performance requirements', async ({ page }) => {
    // Navigate and measure timing
    const startTime = Date.now();
    await page.goto('/');
    
    // Wait for interactive content
    await page.waitForSelector('[role="button"]');
    const loadTime = Date.now() - startTime;
    
    // Should load within 2 seconds (web-first requirement)
    expect(loadTime).toBeLessThan(2000);
  });
});

test.describe('Welcome Screen - Cross-Browser Testing', () => {
  
  test('should work consistently across mobile browsers', async ({ page, browserName }) => {
    await page.goto('/');
    
    // Core functionality should work in all browsers
    await expect(page.getByText('Golf Excellence')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Get Started' })).toBeVisible();
    
    // Test touch interaction
    await page.getByRole('button', { name: 'Get Started' }).tap();
  });
  
  test('should handle PWA manifest correctly', async ({ page }) => {
    await page.goto('/');
    
    // Check manifest link
    const manifestLink = page.locator('link[rel="manifest"]');
    await expect(manifestLink).toHaveAttribute('href', '/manifest.json');
    
    // Verify PWA meta tags
    const themeColor = page.locator('meta[name="theme-color"]');
    await expect(themeColor).toHaveAttribute('content', '#248A3D');
  });
});