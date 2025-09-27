# Golf Sim App - Project Planning

*Last Updated: September 15, 2025*  
*Version: 1.0*

---

## 📌 PROJECT VISION

### Mission Statement
Build a white-label SaaS platform that revolutionizes golf simulation facility management by seamlessly integrating bookings, payments, and member management into one cohesive experience that's "way better than USchedule."

### Core Value Propositions
1. **For Facility Owners:** Complete business management in one platform
2. **For Members:** Frictionless booking and payment experience
3. **For Staff:** Intuitive tools that reduce operational overhead
4. **For Multi-Location Operators:** Scalable white-label solution

### Success Metrics
- **Primary:** Customer feedback stating "way better than USchedule"
- **Secondary:** Successfully deployed to Apple App Store
- **Tertiary:** Support multiple facilities with white-label architecture
- **Business:** Sustainable SaaS revenue model similar to GoHighLevel

---

## 🏗️ ARCHITECTURE DECISIONS

### System Architecture
```
┌─────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                   │
├───────────────────┬────────────────┬────────────────────┤
│   Member Portal   │  Staff Portal  │   Admin Portal     │
│   (Web/Mobile)    │     (Web)      │      (Web)         │
└───────────────────┴────────────────┴────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                      API GATEWAY                         │
│                  (REST + WebSockets)                     │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                   BUSINESS LOGIC LAYER                   │
├──────────────┬──────────────┬──────────────┬───────────┤
│   Booking    │   Payment    │   Member     │   Admin   │
│   Service    │   Service    │   Service    │  Service  │
└──────────────┴──────────────┴──────────────┴───────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                   INTEGRATION LAYER                      │
├────────────────────┬─────────────────────────────────────┤
│   Square API       │        GoHighLevel API              │
│  (POS/Payments)    │    (Marketing/Automation)           │
└────────────────────┴─────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                     DATA LAYER                           │
├────────────────────┬─────────────────────────────────────┤
│   PostgreSQL       │        Redis                        │
│   (Primary DB)     │    (Cache/Sessions)                 │
└────────────────────┴─────────────────────────────────────┘
```

### Multi-Tenant Architecture Strategy
- **Database:** Shared database with tenant isolation (schema-per-tenant)
- **API:** Tenant identification via subdomain or API key
- **Data Isolation:** Row-level security with tenant_id
- **Customization:** Stored configurations per tenant

### Deployment Architecture
```
Phase 1: Web Application (Beta)
├── Frontend: Vercel/Netlify (CDN + Edge Functions)
├── Backend: AWS/Railway (Auto-scaling containers)
├── Database: AWS RDS/Supabase (Managed PostgreSQL)
└── Cache: Redis Cloud (Managed Redis)

Phase 2: iOS Application
├── Native App: Swift/SwiftUI
├── Distribution: Apple App Store
└── Backend: Shared with Web (API-first design)
```

---

## 💻 TECHNOLOGY STACK

### Frontend Stack (Phase 1 - Web)
```javascript
// Core Framework
- Next.js 14+ (React framework with App Router)
- TypeScript (Type safety)
- Tailwind CSS (Styling)
- Shadcn/ui (Component library)

// State Management
- Zustand or Redux Toolkit (Global state)
- React Query/TanStack Query (Server state)
- React Hook Form (Form management)

// Authentication
- NextAuth.js or Clerk (Auth management)
- JWT tokens (Session management)

// Payments UI
- Square Web Payments SDK (PCI compliant)
- Stripe Elements (Backup option)

// Mobile Optimization
- PWA capabilities (Offline support)
- Responsive design (Mobile-first)
```

### Backend Stack
```javascript
// Core Framework Options
Option A: Node.js/TypeScript
- Express.js or Fastify (API framework)
- Prisma or TypeORM (ORM)
- Node.js 20+ LTS

Option B: Python
- FastAPI or Django REST (API framework)
- SQLAlchemy or Django ORM
- Python 3.11+

// Common Components
- REST API (Primary)
- WebSockets (Real-time updates)
- Background Jobs (Bull/Celery)
- File Storage (AWS S3)
```

### Database Stack
```sql
// Primary Database
- PostgreSQL 15+ (ACID compliance, JSON support)
- Schema-per-tenant or Row-level security

// Caching Layer
- Redis (Session management, caching)
- Redis Pub/Sub (Real-time events)

// Search (if needed)
- PostgreSQL Full Text Search (Simple)
- Elasticsearch (Advanced)
```

### iOS Stack (Phase 2)
```swift
// Native Development
- Swift 5.9+
- SwiftUI (UI framework)
- Combine (Reactive programming)
- Core Data (Offline storage)

// Networking
- URLSession or Alamofire
- WebSocket support

// Payments
- Square In-App Payments SDK
- Apple Pay integration
```

---

## 🔧 REQUIRED TOOLS & SERVICES

### Development Tools
```yaml
Version Control:
  - Git
  - GitHub/GitLab (Repository + CI/CD)

IDEs & Editors:
  - VS Code (Web development)
  - Xcode (iOS development)
  - TablePlus/DBeaver (Database management)

API Development:
  - Postman/Insomnia (API testing)
  - Swagger/OpenAPI (Documentation)

Design:
  - Figma (UI/UX design)
  - Excalidraw (Architecture diagrams)
```

### Third-Party Services
```yaml
Required Integrations:
  Square:
    - Developer Account
    - Sandbox Environment
    - Production Credentials
    - Webhook Endpoints
    APIs Needed:
      - Payments API
      - Customers API
      - Catalog API
      - Orders API
      - Cards API
      - Loyalty API
      - Gift Cards API

  GoHighLevel:
    - Agency Account
    - API Access
    - MVP Snapshot
    APIs Needed:
      - Contacts API
      - Campaigns API
      - Workflows API
      - Calendar API
      - SMS/Email API

Infrastructure:
  Domain & DNS:
    - Custom domain
    - SSL certificates
    - Subdomain support (multi-tenant)

  Email Service:
    - SendGrid/Postmark (Transactional)
    - GHL (Marketing emails)

  Monitoring:
    - Sentry (Error tracking)
    - LogRocket/FullStory (Session replay)
    - New Relic/Datadog (APM)

  Analytics:
    - Google Analytics 4
    - Mixpanel/Amplitude (Product analytics)
    - Hotjar (Heatmaps)
```

### Development Environment
```bash
# Required Software
- Node.js 20+ LTS
- npm/yarn/pnpm
- PostgreSQL 15+
- Redis
- Docker (optional but recommended)
- ngrok (webhook testing)

# Environment Variables Setup
- .env.local (development)
- .env.staging (staging)
- .env.production (production)
```

---

## 🚀 DEPLOYMENT STRATEGY

### Phase 1 - Web Application (September 2025 Beta)

#### Hosting Options
```yaml
Option A - Vercel/Netlify + Railway:
  Pros:
    - Simple deployment
    - Auto-scaling
    - Great DX
    - Built-in CI/CD
  Cons:
    - Vendor lock-in
    - Limited customization

Option B - AWS:
  Frontend: CloudFront + S3
  Backend: ECS/EKS or Lambda
  Database: RDS PostgreSQL
  Cache: ElastiCache Redis
  Pros:
    - Full control
    - Enterprise-ready
    - Cost-effective at scale
  Cons:
    - Complex setup
    - Requires DevOps expertise

Option C - Digital Ocean/Linode:
  Pros:
    - Good balance of simplicity/control
    - Cost-effective
    - Managed databases available
  Cons:
    - Manual scaling
    - Less ecosystem
```

#### CI/CD Pipeline
```yaml
Development Workflow:
  1. Feature branch created
  2. Code pushed to GitHub
  3. Automated tests run
  4. PR review required
  5. Merge to main
  6. Auto-deploy to staging
  7. Manual promote to production

Testing Strategy:
  - Unit tests (Jest/Vitest)
  - Integration tests (Supertest)
  - E2E tests (Playwright/Cypress)
  - Load testing (K6/Artillery)
```

### Phase 2 - iOS Deployment

#### App Store Requirements
```yaml
Prerequisites:
  - Apple Developer Account ($99/year)
  - App Store Connect setup
  - TestFlight for beta testing
  - App review preparation

Certificates & Profiles:
  - Development certificate
  - Distribution certificate
  - Provisioning profiles
  - Push notification certificates

App Store Optimization:
  - App icon (1024x1024)
  - Screenshots (all device sizes)
  - App preview video
  - Keywords research
  - Category selection
```

---

## 📊 PROJECT MILESTONES

### Phase 1 Timeline (Web Beta)
```
Week 1-2: Project Setup
├── Repository initialization
├── Development environment
├── Database schema design
└── API architecture

Week 3-4: Core Authentication
├── User roles implementation
├── Member portal creation
├── Session management
└── Password reset flow

Week 5-6: Booking System
├── Bay reservation logic
├── Calendar interface
├── Booking rules engine
└── Buffer time management

Week 7-8: Square Integration
├── Payment processing
├── Card-on-file system
├── Tab management
└── Auto-charge implementation

Week 9-10: GHL Integration
├── Contact sync
├── Automated triggers
├── Reminder system
└── Marketing automation

Week 11-12: Testing & Launch
├── Beta user onboarding
├── Bug fixes
├── Performance optimization
└── Beta launch
```

---

## 🎯 CURRENT SPRINT

### Sprint 1: Foundation (Current)
- [ ] Set up development environment
- [ ] Initialize Git repository
- [ ] Create project structure
- [ ] Set up database schema
- [ ] Configure Square sandbox
- [ ] Obtain GHL API access

---

## 📝 RECENT DECISIONS

- **[2025-09-15]** Created comprehensive Claude.MD for project guidance
- **[2025-09-15]** Established workflow: planning.MD → tasks.MD → code
- **[2025-09-15]** Decided on web-first approach for beta testing
- **[2025-09-10]** PRD v1.1 finalized with iOS App Store as primary goal

---

## 🚨 CURRENT BLOCKERS

- [ ] Need Square developer account credentials
- [ ] Need GHL API documentation and access
- [ ] Awaiting food/beverage menu items for POS
- [ ] Loyalty program mechanics undefined
- [ ] Specific booking window rules needed

---

## 🔄 INTEGRATION STATUS

| Integration | Status | Notes |
|------------|--------|-------|
| Square Payments | Not Started | Need sandbox credentials |
| Square POS | Not Started | Awaiting account setup |
| GHL Contacts | Not Started | Need API access |
| GHL Automation | Not Started | MVP snapshot pending |
| GHL Marketing | Not Started | Social media templates needed |

---

## 💡 ARCHITECTURE DECISIONS LOG

### Why Next.js for Frontend?
- **Date:** 2025-09-15
- **Reasoning:** 
  - Built-in SSR/SSG for SEO
  - API routes for BFF pattern
  - Excellent mobile performance
  - Easy migration path to React Native
  - Strong TypeScript support

### Why PostgreSQL for Database?
- **Date:** 2025-09-15
- **Reasoning:**
  - ACID compliance for financial data
  - JSON support for flexible schemas
  - Row-level security for multi-tenancy
  - Excellent performance at scale
  - Mature ecosystem

### Why Square over Stripe?
- **Date:** Per PRD requirement
- **Reasoning:**
  - Full POS system integration
  - Built-in tab management
  - Inventory synchronization
  - Gift cards and loyalty
  - Physical terminal support

---

## 📚 REFERENCE DOCUMENTS

- [PRD v1.1](./PRD.md) - Product Requirements Document
- [Claude.MD](./Claude.MD) - AI Development Guide
- [tasks.MD](./tasks.MD) - Task Management
- [Square API Docs](https://developer.squareup.com/docs)
- [GHL API Docs](https://highlevel.com/api-docs) - *Pending access*
- [USchedule Reference](https://clients.uschedule.com/evergreengolfclub/product?View=List)

---

## 🎯 NEXT MAJOR MILESTONE

**September 2025 Beta Launch**
- Web application fully functional
- 5-10 beta facilities onboarded
- Core features operational
- Feedback collection system active
- "Better than USchedule" validation

---

*This document is the source of truth for all architectural and planning decisions. Update immediately when decisions are made.*