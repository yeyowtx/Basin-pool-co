import { test, expect } from '@playwright/test';

test.describe('Responsive Layout Mockup Tests', () => {
  
  test('Create visual mockup of expected responsive behavior', async ({ page }) => {
    // Create a simple HTML mockup that demonstrates the expected layout
    const mockupHTML = `
    <!DOCTYPE html>
    <html>
    <head>
      <title>Evergreen Dashboard - Responsive Mockup</title>
      <script src="https://cdn.tailwindcss.com"></script>
      <style>
        .desktop-sidebar {
          @apply hidden lg:flex lg:w-64 lg:flex-col lg:fixed lg:inset-y-0;
        }
        .mobile-nav {
          @apply fixed inset-x-0 bottom-0 z-50 bg-white border-t border-gray-200 lg:hidden;
        }
        .main-content {
          @apply flex-1 lg:pl-64;
        }
      </style>
    </head>
    <body class="bg-gray-50">
      <!-- Layout Container -->
      <div class="h-screen flex overflow-hidden">
        
        <!-- Desktop Sidebar -->
        <div class="desktop-sidebar bg-white border-r border-gray-200">
          <div class="flex h-full flex-col">
            <!-- Logo -->
            <div class="flex h-16 items-center px-6 border-b">
              <div class="h-8 w-8 bg-green-600 rounded"></div>
              <span class="ml-3 text-lg font-bold text-green-700">Evergreen Admin</span>
            </div>
            
            <!-- Navigation -->
            <nav class="flex-1 space-y-1 px-3 py-4">
              <div class="bg-green-100 text-green-700 px-3 py-2 rounded">Dashboard</div>
              <div class="text-gray-600 px-3 py-2 rounded hover:bg-gray-100">Bookings</div>
              <div class="text-gray-600 px-3 py-2 rounded hover:bg-gray-100">Members</div>
              <div class="text-gray-600 px-3 py-2 rounded hover:bg-gray-100">Staff</div>
              <div class="text-gray-600 px-3 py-2 rounded hover:bg-gray-100">Shop & POS</div>
              <div class="text-gray-600 px-3 py-2 rounded hover:bg-gray-100">Analytics</div>
              <div class="text-gray-600 px-3 py-2 rounded hover:bg-gray-100">Settings</div>
            </nav>
          </div>
        </div>
        
        <!-- Main Content -->
        <div class="flex flex-col flex-1 overflow-hidden">
          <!-- Header -->
          <header class="border-b border-gray-200 bg-white">
            <div class="flex h-16 items-center px-4 sm:px-6">
              <!-- Mobile menu button -->
              <button class="lg:hidden p-2 rounded-md text-gray-600">
                <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                </svg>
              </button>
              
              <!-- Search -->
              <div class="flex flex-1 items-center justify-center px-6 lg:justify-start">
                <div class="w-full max-w-lg lg:max-w-xs">
                  <input type="search" placeholder="Search..." class="w-full px-4 py-2 border border-gray-300 rounded-md" />
                </div>
              </div>
              
              <!-- User menu -->
              <div class="flex items-center gap-4">
                <button class="p-2 text-gray-600">🔔</button>
                <button class="p-2 text-gray-600">👤</button>
              </div>
            </div>
          </header>
          
          <!-- Main Content Area -->
          <main class="flex-1 overflow-y-auto">
            <div class="py-6">
              <div class="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
                
                <!-- Page Header -->
                <div class="mb-8">
                  <h1 class="text-3xl font-bold text-green-700">Evergreen Golf Club Admin Dashboard</h1>
                  <p class="text-gray-600">Welcome to your facility management dashboard</p>
                </div>
                
                <!-- Overview Cards -->
                <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4 mb-8">
                  <div class="bg-white p-6 rounded-lg shadow">
                    <h3 class="text-sm font-medium text-gray-500">Total Members</h3>
                    <p class="text-2xl font-bold">1,247</p>
                    <p class="text-xs text-green-600">+12% from last month</p>
                  </div>
                  <div class="bg-white p-6 rounded-lg shadow">
                    <h3 class="text-sm font-medium text-gray-500">Today's Bookings</h3>
                    <p class="text-2xl font-bold">89</p>
                    <p class="text-xs text-green-600">+23% from yesterday</p>
                  </div>
                  <div class="bg-white p-6 rounded-lg shadow">
                    <h3 class="text-sm font-medium text-gray-500">Daily Revenue</h3>
                    <p class="text-2xl font-bold">$4,231</p>
                    <p class="text-xs text-green-600">+18% from yesterday</p>
                  </div>
                  <div class="bg-white p-6 rounded-lg shadow">
                    <h3 class="text-sm font-medium text-gray-500">Bay Utilization</h3>
                    <p class="text-2xl font-bold">73%</p>
                    <p class="text-xs text-green-600">+5% from last week</p>
                  </div>
                </div>
                
                <!-- Feature Cards -->
                <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                  <div class="bg-white p-6 rounded-lg shadow">
                    <h3 class="text-lg font-medium mb-4">Real-Time Bay Status</h3>
                    <div class="grid grid-cols-3 gap-2 text-xs">
                      <div class="text-center p-2 bg-green-50 rounded">
                        <div class="font-bold text-green-700">15</div>
                        <div class="text-green-600">Available</div>
                      </div>
                      <div class="text-center p-2 bg-red-50 rounded">
                        <div class="font-bold text-red-700">8</div>
                        <div class="text-red-600">Occupied</div>
                      </div>
                      <div class="text-center p-2 bg-yellow-50 rounded">
                        <div class="font-bold text-yellow-700">2</div>
                        <div class="text-yellow-600">Cleaning</div>
                      </div>
                    </div>
                  </div>
                  
                  <div class="bg-white p-6 rounded-lg shadow">
                    <h3 class="text-lg font-medium mb-4">Booking Management</h3>
                    <div class="space-y-2 text-sm">
                      <div class="flex justify-between">
                        <span>Confirmed Today</span>
                        <span class="font-bold">89</span>
                      </div>
                      <div class="flex justify-between">
                        <span>Pending Approval</span>
                        <span class="font-bold">12</span>
                      </div>
                      <div class="flex justify-between">
                        <span>Waitlisted</span>
                        <span class="font-bold">5</span>
                      </div>
                    </div>
                  </div>
                  
                  <div class="bg-white p-6 rounded-lg shadow">
                    <h3 class="text-lg font-medium mb-4">Member Analytics</h3>
                    <div class="space-y-2 text-sm">
                      <div class="flex justify-between">
                        <span>Rainier (Premium)</span>
                        <span class="font-bold">247</span>
                      </div>
                      <div class="flex justify-between">
                        <span>Pike (Standard)</span>
                        <span class="font-bold">486</span>
                      </div>
                      <div class="flex justify-between">
                        <span>Cascade (Basic)</span>
                        <span class="font-bold">514</span>
                      </div>
                    </div>
                  </div>
                </div>
                
              </div>
            </div>
          </main>
        </div>
        
        <!-- Mobile Navigation -->
        <div class="mobile-nav">
          <div class="grid grid-cols-4 h-16">
            <button class="flex flex-col items-center justify-center text-green-600">
              <div class="text-lg">📊</div>
              <span class="text-xs">Dashboard</span>
            </button>
            <button class="flex flex-col items-center justify-center text-gray-600">
              <div class="text-lg">📅</div>
              <span class="text-xs">Bookings</span>
            </button>
            <button class="flex flex-col items-center justify-center text-gray-600">
              <div class="text-lg">👥</div>
              <span class="text-xs">Members</span>
            </button>
            <button class="flex flex-col items-center justify-center text-gray-600">
              <div class="text-lg">⋯</div>
              <span class="text-xs">More</span>
            </button>
          </div>
        </div>
        
      </div>
    </body>
    </html>
    `;
    
    // Set the page content to our mockup
    await page.setContent(mockupHTML);
    
    // Test different viewport sizes with the mockup
    const viewports = [
      { name: 'mobile', width: 375, height: 667 },
      { name: 'mobile-large', width: 414, height: 896 },
      { name: 'tablet', width: 768, height: 1024 },
      { name: 'laptop', width: 1366, height: 768 },
      { name: 'desktop', width: 1920, height: 1080 }
    ];
    
    for (const viewport of viewports) {
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await page.waitForTimeout(300);
      
      // Take screenshot
      await page.screenshot({ 
        path: `test-results/mockup-${viewport.name}-${viewport.width}x${viewport.height}.png`,
        fullPage: true 
      });
      
      // Check responsive behavior
      const sidebar = page.locator('.desktop-sidebar');
      const mobileNav = page.locator('.mobile-nav');
      
      if (viewport.width >= 1024) {
        // Desktop: sidebar visible, mobile nav hidden
        await expect(sidebar).toBeVisible();
        await expect(mobileNav).toBeHidden();
      } else {
        // Mobile/tablet: sidebar hidden, mobile nav visible
        await expect(sidebar).toBeHidden();
        await expect(mobileNav).toBeVisible();
      }
      
      console.log(`✅ ${viewport.name} (${viewport.width}x${viewport.height}): Layout test passed`);
    }
  });

  test('Demonstrate layout issues with fixed widths', async ({ page }) => {
    // Create a problematic layout to show the "fixed width" issue
    const problematicHTML = `
    <!DOCTYPE html>
    <html>
    <head>
      <title>Problematic Fixed Width Layout</title>
      <style>
        body { margin: 0; font-family: system-ui; }
        .container { 
          width: 1200px; /* Fixed width - problem! */
          margin: 0 auto;
          background: white;
          min-height: 100vh;
          box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        .sidebar { 
          width: 250px; /* Fixed width */
          height: 100vh;
          background: #f8f9fa;
          float: left;
          border-right: 1px solid #ddd;
        }
        .content { 
          margin-left: 250px; /* Fixed margin */
          padding: 20px;
        }
        .card { 
          width: 300px; /* Fixed width cards */
          height: 200px;
          background: white;
          border: 1px solid #ddd;
          margin: 10px;
          padding: 20px;
          float: left;
        }
        body { background: #eee; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="sidebar">
          <h3>Fixed Sidebar</h3>
          <p>This sidebar is 250px wide</p>
        </div>
        <div class="content">
          <h1>Fixed Width Container Problem</h1>
          <p>This container is fixed at 1200px wide, causing the "fixed width" issue</p>
          <div class="card">Card 1<br>300px wide</div>
          <div class="card">Card 2<br>300px wide</div>
          <div class="card">Card 3<br>300px wide</div>
        </div>
      </div>
    </body>
    </html>
    `;
    
    await page.setContent(problematicHTML);
    
    const viewports = [
      { name: 'small-screen', width: 1024, height: 768 },
      { name: 'large-screen', width: 1920, height: 1080 },
      { name: 'ultrawide', width: 2560, height: 1440 }
    ];
    
    for (const viewport of viewports) {
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await page.waitForTimeout(200);
      
      await page.screenshot({ 
        path: `test-results/problematic-fixed-width-${viewport.name}.png`,
        fullPage: false 
      });
      
      console.log(`📸 ${viewport.name}: Captured problematic layout`);
    }
  });
});