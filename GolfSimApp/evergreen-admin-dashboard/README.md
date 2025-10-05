# Evergreen Golf Club - Admin Dashboard

Advanced facility management dashboard for Evergreen Golf Club with real-time bay status, booking management, and GoHighLevel integration.

## 🚀 Quick Deploy to Vercel

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/yourusername/evergreen-admin-dashboard)

## ✨ Features

### 🏌️ Core Facility Management
- **Real-Time Bay Status** - Live updates every 30 seconds
- **Advanced Booking System** - 15-minute buffers, priority booking
- **Member Management** - 4-tier membership system (Cascade/Pike/Rainier/Junior)
- **Staff Scheduling** - Instructor availability and resource management

### 💰 Revenue & POS Integration
- **Square POS Integration** - Real-time payment processing
- **Tab Management** - 24-hour auto-close with grace period
- **Inventory Management** - Pro shop items and equipment
- **Revenue Analytics** - Daily/weekly/monthly reports

### 🔗 External Integrations
- **GoHighLevel Sync** - Customer data and marketing automation
- **iOS App Integration** - Real-time data sync with mobile app
- **WebSocket Updates** - Live bay status and booking changes

### 📊 Analytics & Reporting
- **Utilization Metrics** - Bay usage and peak hour analysis
- **Financial Reports** - Revenue, membership, and transaction tracking
- **Performance Analytics** - Staff productivity and customer satisfaction

## 🛠️ Tech Stack

- **Frontend:** Next.js 14, TypeScript, Tailwind CSS, Framer Motion
- **Backend:** Next.js API Routes, Prisma ORM
- **Database:** PostgreSQL (Vercel Postgres)
- **Real-time:** WebSockets, Server-Sent Events
- **Auth:** NextAuth.js with role-based access
- **Payments:** Square Web SDK
- **Deployment:** Vercel

## 📋 Prerequisites

- Node.js 18+ and npm
- PostgreSQL database (or use Vercel Postgres)
- Square Developer Account
- GoHighLevel Account (optional)

## ⚡ Quick Start

### 1. Clone and Install
```bash
git clone https://github.com/yourusername/evergreen-admin-dashboard
cd evergreen-admin-dashboard
npm install
```

### 2. Environment Setup
```bash
cp .env.example .env.local
```

Edit `.env.local` with your credentials:
```env
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/evergreen_admin"

# NextAuth
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="your-secret-key"

# Square
SQUARE_ACCESS_TOKEN="your-square-token"
SQUARE_APPLICATION_ID="your-square-app-id"
SQUARE_ENVIRONMENT="sandbox"

# GoHighLevel (optional)
GHL_API_KEY="your-ghl-api-key"
GHL_LOCATION_ID="your-ghl-location-id"
```

### 3. Database Setup
```bash
# Push schema to database
npm run db:push

# Seed with sample data
npm run db:seed
```

### 4. Run Development Server
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## 🌐 Deploy to Vercel

### Option 1: One-Click Deploy
1. Click the "Deploy with Vercel" button above
2. Connect your GitHub account
3. Set environment variables in Vercel dashboard
4. Deploy!

### Option 2: Manual Deploy
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Set environment variables
vercel env add DATABASE_URL
vercel env add NEXTAUTH_SECRET
# ... add other env vars

# Deploy production
vercel --prod
```

### Option 3: Automated Deploy Script
```bash
# Run the automated deployment
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

## 🗄️ Database Schema

The database mirrors your iOS app's data models:

### Core Entities
- **Facilities** - Tacoma & Redmond locations
- **Members** - 4-tier membership system
- **Bookings** - Advanced scheduling with buffers
- **Resources** - Simulators and equipment
- **Staff** - Instructors and employees

### Real-Time Tables
- **BayStatus** - Live bay occupancy
- **Transactions** - Payment processing
- **GHLSync** - Integration status

## 🔌 API Integration

### iOS App Sync
```typescript
// Real-time bay status
GET /api/bay-status/:facilityId

// Booking management
POST /api/bookings
PUT /api/bookings/:id
DELETE /api/bookings/:id

// Member data
GET /api/members
POST /api/members
```

### GoHighLevel Webhooks
```typescript
// Customer sync
POST /api/webhooks/ghl/contact

// Booking triggers
POST /api/webhooks/ghl/opportunity
```

### Square Integration
```typescript
// Payment processing
POST /api/square/payments

// Inventory sync
GET /api/square/catalog
```

## 🚦 Features Status

### ✅ Completed
- [x] Database schema and models
- [x] Authentication and user management
- [x] Dashboard layout and navigation
- [x] Real-time bay status framework
- [x] Booking system foundation
- [x] Member management structure

### 🚧 In Progress
- [ ] Real-time WebSocket connections
- [ ] Square POS integration
- [ ] GoHighLevel sync automation
- [ ] Advanced analytics dashboard
- [ ] Staff scheduling system

### 📋 Planned
- [ ] Mobile-responsive design
- [ ] Advanced reporting
- [ ] Automated marketing triggers
- [ ] Performance optimization
- [ ] Multi-tenant white-label support

## 🔒 Security

- Role-based access control (RBAC)
- NextAuth.js authentication
- API route protection
- Input validation and sanitization
- HTTPS enforcement
- Environment variable security

## 📱 iOS App Integration

This dashboard is designed to work seamlessly with your iOS Golf Sim App:

### Data Synchronization
- **Real-time bay status** updates iOS app every 30 seconds
- **Booking changes** instantly sync between admin and mobile
- **Member data** stays consistent across platforms

### Offline Handling
- Dashboard continues working during connectivity issues
- iOS app caches data for offline booking capability
- Auto-sync when connection restored

## 🆘 Support

### Development
- Check the [Issues](https://github.com/yourusername/evergreen-admin-dashboard/issues) for known problems
- Review the [API Documentation](./docs/api.md)
- See [Contributing Guidelines](./CONTRIBUTING.md)

### Production Support
- Monitor deployment at [Vercel Dashboard](https://vercel.com/dashboard)
- Check database health in Vercel Postgres
- Review error logs in Vercel Functions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Built for Evergreen Golf Club** 🌲⛳
*Advanced facility management made simple*