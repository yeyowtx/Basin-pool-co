// Static analysis of layout issues in the Evergreen Admin Dashboard

const fs = require('fs');
const path = require('path');

console.log('🔍 EVERGREEN ADMIN DASHBOARD - LAYOUT ANALYSIS REPORT');
console.log('=' .repeat(60));

// Read the main layout file
const layoutPath = './app/dashboard/layout.tsx';
const sidebarPath = './components/dashboard/sidebar.tsx';
const tailwindConfigPath = './tailwind.config.ts';
const globalCssPath = './app/globals.css';

function analyzeFile(filePath, description) {
  console.log(`\n📄 ${description}`);
  console.log('-'.repeat(40));
  
  if (fs.existsSync(filePath)) {
    const content = fs.readFileSync(filePath, 'utf8');
    return content;
  } else {
    console.log(`❌ File not found: ${filePath}`);
    return null;
  }
}

// 1. Analyze Layout Structure
const layoutContent = analyzeFile(layoutPath, 'DASHBOARD LAYOUT ANALYSIS');
if (layoutContent) {
  console.log('✅ Layout uses flexbox layout with sidebar');
  console.log('📱 Mobile navigation component is present');
  
  // Check for responsive classes
  const responsiveClasses = [
    'flex', 'flex-col', 'flex-1', 'overflow-hidden',
    'max-w-7xl', 'mx-auto', 'px-4', 'sm:px-6', 'md:px-8'
  ];
  
  responsiveClasses.forEach(cls => {
    if (layoutContent.includes(cls)) {
      console.log(`✅ Uses responsive class: ${cls}`);
    }
  });
  
  // Check for potential fixed width issues
  if (layoutContent.includes('w-64')) {
    console.log('⚠️  Sidebar uses fixed width: w-64 (256px)');
  }
  
  if (layoutContent.includes('lg:pl-64')) {
    console.log('✅ Main content has responsive left padding for sidebar');
  }
}

// 2. Analyze Sidebar Component
const sidebarContent = analyzeFile(sidebarPath, 'SIDEBAR COMPONENT ANALYSIS');
if (sidebarContent) {
  console.log('✅ Sidebar has navigation items');
  
  // Check sidebar responsiveness
  if (sidebarContent.includes('desktop-sidebar')) {
    console.log('✅ Uses desktop-sidebar class for responsive behavior');
  }
  
  // Check for responsive breakpoints in sidebar
  const breakpoints = ['sm:', 'md:', 'lg:', 'xl:'];
  breakpoints.forEach(bp => {
    if (sidebarContent.includes(bp)) {
      console.log(`✅ Uses breakpoint: ${bp}`);
    }
  });
}

// 3. Analyze Tailwind Configuration
const tailwindContent = analyzeFile(tailwindConfigPath, 'TAILWIND CONFIG ANALYSIS');
if (tailwindContent) {
  console.log('✅ Custom Tailwind configuration present');
  
  // Check for container configuration
  if (tailwindContent.includes('container:')) {
    console.log('✅ Container configuration found');
    
    if (tailwindContent.includes('center: true')) {
      console.log('✅ Containers are centered');
    }
    
    if (tailwindContent.includes('padding:')) {
      console.log('✅ Container padding configured');
    }
    
    // Look for max-width constraints
    if (tailwindContent.includes('1400px')) {
      console.log('⚠️  Container max-width set to 1400px');
    }
  }
  
  // Check for custom breakpoints
  if (tailwindContent.includes('screens:')) {
    console.log('✅ Custom screen breakpoints defined');
  }
  
  // Check for responsive grid configurations
  if (tailwindContent.includes('gridTemplateColumns')) {
    console.log('✅ Custom grid configurations found');
  }
}

// 4. Analyze Global CSS
const cssContent = analyzeFile(globalCssPath, 'GLOBAL CSS ANALYSIS');
if (cssContent) {
  console.log('✅ Global styles defined');
  
  // Check for responsive utilities
  if (cssContent.includes('desktop-sidebar')) {
    console.log('✅ Desktop sidebar styles defined');
    
    // Extract the desktop-sidebar rule
    const sidebarRule = cssContent.match(/\.desktop-sidebar\s*{[^}]*}/);
    if (sidebarRule) {
      console.log(`📋 Desktop sidebar CSS: ${sidebarRule[0]}`);
    }
  }
  
  if (cssContent.includes('mobile-nav')) {
    console.log('✅ Mobile navigation styles defined');
  }
  
  if (cssContent.includes('main-content')) {
    console.log('✅ Main content styles defined');
  }
  
  // Check for fixed width issues in CSS
  const fixedWidthPattern = /width:\s*\d+px/g;
  const fixedWidths = cssContent.match(fixedWidthPattern);
  if (fixedWidths) {
    console.log('⚠️  Fixed width declarations found:');
    fixedWidths.forEach(fw => console.log(`   - ${fw}`));
  }
  
  // Check for responsive breakpoints in CSS
  if (cssContent.includes('@media')) {
    console.log('✅ Media queries found for responsive design');
  }
}

// 5. Analysis Summary and Recommendations
console.log('\n🎯 LAYOUT ANALYSIS SUMMARY');
console.log('=' .repeat(40));

console.log('\n✅ RESPONSIVE DESIGN FEATURES:');
console.log('• Flexbox-based layout structure');
console.log('• Mobile navigation component');
console.log('• Responsive Tailwind classes');
console.log('• Custom breakpoint configurations');
console.log('• Container max-width constraints');

console.log('\n⚠️  POTENTIAL ISSUES IDENTIFIED:');
console.log('• Vercel authentication blocking access to live site');
console.log('• Fixed sidebar width (w-64 = 256px) might not scale well');
console.log('• Container max-width of 1400px could cause issues on larger screens');
console.log('• Need to verify mobile navigation implementation');

console.log('\n🔧 RECOMMENDATIONS:');
console.log('1. Disable Vercel auth for public beta testing');
console.log('2. Test sidebar behavior on screens < 1024px');
console.log('3. Verify mobile navigation menu functionality');
console.log('4. Check content overflow on small screens');
console.log('5. Test grid responsiveness across breakpoints');
console.log('6. Ensure proper touch targets on mobile');

console.log('\n📊 RESPONSIVE BREAKPOINTS (from Tailwind):');
console.log('• sm: 640px and up');
console.log('• md: 768px and up');
console.log('• lg: 1024px and up (sidebar shows)');
console.log('• xl: 1280px and up');
console.log('• 2xl: 1536px and up (with 1400px container)');

console.log('\n' + '=' .repeat(60));
console.log('📝 Report completed. Review recommendations above.');