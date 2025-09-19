/** @type {import('next').NextConfig} */
const nextConfig = {
  // Vercel handles optimization automatically - no manual config needed
  
  // Allow cross-origin requests for mobile testing
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'Access-Control-Allow-Origin',
            value: '*',
          },
          {
            key: 'Access-Control-Allow-Methods',
            value: 'GET, POST, PUT, DELETE, OPTIONS',
          },
          {
            key: 'Access-Control-Allow-Headers',
            value: 'Content-Type, Authorization',
          },
        ],
      },
    ];
  },
  
  // Allow development origins for mobile testing
  allowedDevOrigins: ['*'],
  
  // Vercel optimizes automatically
  experimental: {
    // Vercel handles all optimization
  },
};

module.exports = nextConfig;