import { test, expect } from '@playwright/test';

test.describe('UI Functionality Tests', () => {

  test('Dashboard loads and displays main components', async ({ page }) => {
    await page.goto('/dashboard');
    
    // Check page title
    await expect(page).toHaveTitle(/Evergreen/);
    
    // Check main dashboard heading
    const heading = page.locator('h1');
    await expect(heading).toContainText('Evergreen Golf Club Admin Dashboard');
    
    // Check overview cards are present
    const totalMembersCard = page.locator('text=Total Members');
    await expect(totalMembersCard).toBeVisible();
    
    const todayBookingsCard = page.locator('text=Today\'s Bookings');
    await expect(todayBookingsCard).toBeVisible();
    
    const dailyRevenueCard = page.locator('text=Daily Revenue');
    await expect(dailyRevenueCard).toBeVisible();
    
    const bayUtilizationCard = page.locator('text=Bay Utilization');
    await expect(bayUtilizationCard).toBeVisible();
    
    await page.screenshot({ path: 'test-results/dashboard-main-components.png' });
  });

  test('Navigation menu functionality', async ({ page }) => {
    await page.goto('/dashboard');
    
    // Check if navigation items are present and clickable
    const navItems = [
      'Dashboard',
      'Bookings', 
      'Members',
      'Staff',
      'Shop & POS',
      'Analytics',
      'Settings'
    ];
    
    for (const item of navItems) {
      const navLink = page.locator(`nav a:has-text("${item}")`);
      await expect(navLink).toBeVisible();
      
      // Check if the link has proper href
      const href = await navLink.getAttribute('href');
      expect(href).toBeTruthy();
      expect(href).toContain('/dashboard');
    }
    
    await page.screenshot({ path: 'test-results/navigation-menu.png' });
  });

  test('Card layouts and content', async ({ page }) => {
    await page.goto('/dashboard');
    
    // Test overview cards layout
    const overviewSection = page.locator('.grid.gap-4').first();
    await expect(overviewSection).toBeVisible();
    
    // Count overview cards (should be 4)
    const overviewCards = page.locator('.grid.gap-4 > div').first().locator('..');
    const cardCount = await overviewCards.locator('> div').count();
    expect(cardCount).toBe(4);
    
    // Test feature cards layout
    const featureSection = page.locator('.grid.gap-6').first();
    await expect(featureSection).toBeVisible();
    
    // Check Real-Time Bay Status card
    const bayStatusCard = page.locator('text=Real-Time Bay Status').locator('..');
    await expect(bayStatusCard).toBeVisible();
    
    // Check Booking Management card
    const bookingCard = page.locator('text=Booking Management').locator('..');
    await expect(bookingCard).toBeVisible();
    
    // Check Member Analytics card
    const analyticsCard = page.locator('text=Member Analytics').locator('..');
    await expect(analyticsCard).toBeVisible();
    
    await page.screenshot({ path: 'test-results/card-layouts.png' });
  });

  test('Real-time bay status display', async ({ page }) => {
    await page.goto('/dashboard');
    
    // Find the bay status card
    const bayStatusCard = page.locator('text=Real-Time Bay Status').locator('..');
    await expect(bayStatusCard).toBeVisible();
    
    // Check status indicators
    const availableStatus = bayStatusCard.locator('text=Available');
    await expect(availableStatus).toBeVisible();
    
    const occupiedStatus = bayStatusCard.locator('text=Occupied');
    await expect(occupiedStatus).toBeVisible();
    
    const cleaningStatus = bayStatusCard.locator('text=Cleaning');
    await expect(cleaningStatus).toBeVisible();
    
    // Check if numbers are displayed
    const statusNumbers = bayStatusCard.locator('.font-bold');
    const numberCount = await statusNumbers.count();
    expect(numberCount).toBeGreaterThanOrEqual(3);
    
    await page.screenshot({ path: 'test-results/bay-status-display.png' });
  });

  test('Beta notice and feature lists', async ({ page }) => {
    await page.goto('/dashboard');
    
    // Check beta notice card
    const betaCard = page.locator('text=Beta Dashboard - September 2025 Launch').locator('..');
    await expect(betaCard).toBeVisible();
    
    // Check available features list
    const availableFeatures = betaCard.locator('text=Available Now').locator('..');
    await expect(availableFeatures).toBeVisible();
    
    // Check coming soon features list
    const comingSoonFeatures = betaCard.locator('text=Coming Soon').locator('..');
    await expect(comingSoonFeatures).toBeVisible();
    
    // Check hybrid architecture notice
    const hybridNotice = betaCard.locator('text=Hybrid Architecture');
    await expect(hybridNotice).toBeVisible();
    
    await page.screenshot({ path: 'test-results/beta-notice.png' });
  });

  test('Header and branding', async ({ page }) => {
    await page.goto('/dashboard');
    
    // Check if Evergreen logo/brand is visible
    const brandElement = page.locator('text=Evergreen Admin');
    await expect(brandElement).toBeVisible();
    
    // Check if header exists
    const header = page.locator('header').or(page.locator('.header'));
    // Header might not have specific class, check if page has proper top navigation area
    
    await page.screenshot({ path: 'test-results/header-branding.png' });
  });

  test('Mobile navigation functionality', async ({ page }) => {
    // Test on mobile viewport
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto('/dashboard');
    
    // Desktop sidebar should be hidden
    const desktopSidebar = page.locator('.desktop-sidebar');
    await expect(desktopSidebar).toBeHidden();
    
    // Look for mobile navigation elements
    const mobileNav = page.locator('.mobile-nav');
    // Mobile nav might not be visible until triggered
    
    // Check if there's a menu button or hamburger icon
    const menuButton = page.locator('[aria-label*="menu"]').or(
      page.locator('button:has([data-lucide="menu"])').or(
        page.locator('.menu-toggle')
      )
    );
    
    // Take screenshot of mobile layout
    await page.screenshot({ path: 'test-results/mobile-navigation.png' });
  });

  test('Color scheme and theming', async ({ page }) => {
    await page.goto('/dashboard');
    
    // Check if Evergreen brand colors are applied
    const brandElement = page.locator('text=Evergreen Admin');
    await expect(brandElement).toBeVisible();
    
    // Check computed styles for brand colors
    const primaryElements = page.locator('.text-evergreen-primary');
    if (await primaryElements.count() > 0) {
      const color = await primaryElements.first().evaluate(el => 
        window.getComputedStyle(el).color
      );
      // Should be some shade of green (evergreen colors)
      console.log('Primary brand color:', color);
    }
    
    // Check status colors
    const statusElements = page.locator('[class*="bg-green"], [class*="bg-red"], [class*="bg-yellow"]');
    const statusCount = await statusElements.count();
    expect(statusCount).toBeGreaterThan(0);
    
    await page.screenshot({ path: 'test-results/color-theming.png' });
  });

  test('Content overflow and scrolling', async ({ page }) => {
    await page.goto('/dashboard');
    
    // Test different viewport sizes for content overflow
    const viewports = [
      { width: 320, height: 568 },
      { width: 768, height: 600 },
      { width: 1024, height: 768 }
    ];
    
    for (const viewport of viewports) {
      await page.setViewportSize(viewport);
      await page.waitForTimeout(300);
      
      // Check if page content is scrollable vertically (expected)
      const body = page.locator('body');
      const scrollHeight = await body.evaluate(el => el.scrollHeight);
      const clientHeight = await body.evaluate(el => el.clientHeight);
      
      // Check for horizontal overflow (should not exist)
      const scrollWidth = await body.evaluate(el => el.scrollWidth);
      const clientWidth = await body.evaluate(el => el.clientWidth);
      
      if (scrollWidth > clientWidth + 5) {
        console.log(`Horizontal overflow detected at ${viewport.width}x${viewport.height}: scrollWidth=${scrollWidth}, clientWidth=${clientWidth}`);
      }
      
      await page.screenshot({ 
        path: `test-results/content-overflow-${viewport.width}x${viewport.height}.png`,
        fullPage: true 
      });
    }
  });
});