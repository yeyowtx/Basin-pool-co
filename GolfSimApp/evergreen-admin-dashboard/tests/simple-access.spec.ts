import { test, expect } from '@playwright/test';

test.describe('Basic Access Tests', () => {
  
  test('Check what page actually loads', async ({ page }) => {
    await page.goto('/');
    
    // Take a screenshot to see what loads
    await page.screenshot({ path: 'test-results/homepage.png', fullPage: true });
    
    // Check page title and content
    const title = await page.title();
    console.log('Page title:', title);
    
    const body = await page.textContent('body');
    console.log('Body contains "Login":', body?.includes('Login'));
    console.log('Body contains "Vercel":', body?.includes('Vercel'));
    console.log('Body contains "Evergreen":', body?.includes('Evergreen'));
    console.log('Body contains "Dashboard":', body?.includes('Dashboard'));
    
    // Check current URL
    const currentUrl = page.url();
    console.log('Current URL:', currentUrl);
  });

  test('Try direct dashboard access', async ({ page }) => {
    await page.goto('/dashboard');
    
    await page.screenshot({ path: 'test-results/dashboard-direct.png', fullPage: true });
    
    const title = await page.title();
    console.log('Dashboard page title:', title);
    
    const currentUrl = page.url();
    console.log('Dashboard URL:', currentUrl);
    
    // Check if we're redirected
    if (currentUrl.includes('vercel.com')) {
      console.log('REDIRECTED TO VERCEL AUTH');
    }
  });

  test('Check HTML structure', async ({ page }) => {
    await page.goto('/dashboard');
    
    // Get the HTML structure
    const htmlContent = await page.content();
    console.log('HTML contains our sidebar class:', htmlContent.includes('desktop-sidebar'));
    console.log('HTML contains our dashboard heading:', htmlContent.includes('Evergreen Golf Club Admin Dashboard'));
    console.log('HTML contains Vercel login:', htmlContent.includes('Log in to Vercel'));
    
    // Log first 500 characters to see what's actually loading
    console.log('First 500 chars of HTML:', htmlContent.substring(0, 500));
  });

  test('Test different authentication bypass', async ({ page }) => {
    // Try accessing with different headers or parameters
    await page.goto('/dashboard?auth=bypass');
    await page.screenshot({ path: 'test-results/dashboard-bypass-attempt.png', fullPage: true });
    
    const content = await page.textContent('body');
    console.log('Bypass attempt - contains Evergreen:', content?.includes('Evergreen'));
  });
});