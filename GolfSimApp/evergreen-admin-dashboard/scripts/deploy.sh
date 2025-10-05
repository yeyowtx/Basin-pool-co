#!/bin/bash

# Evergreen Golf Club Admin Dashboard - Automated Deployment Script
# This script deploys the admin dashboard to Vercel with all necessary configurations

set -e  # Exit on any error

echo "🌲 Evergreen Golf Club - Admin Dashboard Deployment"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in the correct directory
if [ ! -f "package.json" ] || [ ! -f "next.config.js" ]; then
    log_error "Please run this script from the evergreen-admin-dashboard directory"
    exit 1
fi

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    log_warning "Vercel CLI not found. Installing..."
    npm install -g vercel
    log_success "Vercel CLI installed"
fi

# Check if user is logged in to Vercel
if ! vercel whoami &> /dev/null; then
    log_info "Please log in to Vercel"
    vercel login
fi

log_info "Starting deployment process..."

# Install dependencies
log_info "Installing dependencies..."
npm install
log_success "Dependencies installed"

# Type check
log_info "Running type check..."
npm run type-check
log_success "Type check passed"

# Build check (local)
log_info "Testing build locally..."
npm run build
log_success "Local build successful"

# Deploy to Vercel
log_info "Deploying to Vercel..."

# Create vercel.json configuration
cat > vercel.json << EOF
{
  "framework": "nextjs",
  "buildCommand": "npm run build",
  "devCommand": "npm run dev",
  "installCommand": "npm install",
  "functions": {
    "app/api/**": {
      "maxDuration": 60
    }
  },
  "env": {
    "NODE_ENV": "production"
  },
  "regions": ["pdx1"],
  "crons": [
    {
      "path": "/api/cron/sync-bay-status",
      "schedule": "*/30 * * * * *"
    },
    {
      "path": "/api/cron/sync-ghl",
      "schedule": "0 */6 * * *"
    },
    {
      "path": "/api/cron/auto-close-tabs",
      "schedule": "0 1 * * *"
    }
  ]
}
EOF

# Deploy
vercel --prod

# Get the deployment URL
DEPLOYMENT_URL=$(vercel ls --limit=1 | grep https | awk '{print $2}')

log_success "Deployment completed!"
log_info "Dashboard URL: $DEPLOYMENT_URL"

# Environment variables setup
echo ""
log_info "Setting up environment variables..."

# Check if .env.local exists for reference
if [ -f ".env.local" ]; then
    log_info "Found .env.local file. Using as reference for environment variables."
    
    # Read environment variables from .env.local
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        if [[ $key =~ ^[A-Z] ]]; then
            # Remove quotes from value
            clean_value=$(echo $value | sed 's/^"//;s/"$//')
            
            # Set environment variable in Vercel
            echo "Setting $key..."
            echo "$clean_value" | vercel env add "$key" production
        fi
    done < .env.local
    
    log_success "Environment variables configured"
else
    log_warning "No .env.local file found. You'll need to set environment variables manually."
    echo ""
    echo "Required environment variables:"
    echo "- DATABASE_URL"
    echo "- NEXTAUTH_URL"
    echo "- NEXTAUTH_SECRET"
    echo "- SQUARE_ACCESS_TOKEN"
    echo "- SQUARE_APPLICATION_ID"
    echo "- SQUARE_ENVIRONMENT"
    echo "- GHL_API_KEY (optional)"
    echo "- GHL_LOCATION_ID (optional)"
    echo ""
    echo "Set them with: vercel env add VARIABLE_NAME production"
fi

# Database setup
echo ""
log_info "Database setup instructions:"
echo "1. Create a PostgreSQL database (Vercel Postgres recommended)"
echo "2. Update DATABASE_URL environment variable"
echo "3. Run: vercel env pull .env.local"
echo "4. Run: npm run db:push"
echo "5. Run: npm run db:seed"

# Final deployment with environment variables
log_info "Triggering final deployment with environment variables..."
vercel --prod
FINAL_URL=$(vercel ls --limit=1 | grep https | awk '{print $2}')

echo ""
echo "🎉 Deployment Complete!"
echo "========================"
log_success "Admin Dashboard: $FINAL_URL"
echo ""
echo "Next Steps:"
echo "1. Set up your database (see instructions above)"
echo "2. Configure Square API credentials"
echo "3. Set up GoHighLevel integration (optional)"
echo "4. Test the dashboard functionality"
echo "5. Configure your iOS app to connect to this admin dashboard"
echo ""
echo "Documentation: $FINAL_URL/docs"
echo "Health Check: $FINAL_URL/api/health"
echo ""
log_info "Happy facility managing! 🏌️‍♂️"