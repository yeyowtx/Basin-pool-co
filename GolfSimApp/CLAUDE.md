# Claude.MD - Golf Sim App Project Guide

## 🔴 CRITICAL WORKFLOW INSTRUCTIONS - FOLLOW EVERY SESSION

### These 4 rules MUST be followed when working on the Golf Sim App project:

1. **START OF CONVERSATION:** Always read `planning.MD` first to understand current project state and priorities
2. **BEFORE STARTING WORK:** Check `tasks.MD` to see what needs to be done and avoid duplicate work
3. **AFTER COMPLETING WORK:** Immediately mark completed tasks in `tasks.MD` with completion date/time
4. **DURING WORK:** Add any newly discovered tasks or requirements to `tasks.MD` as you find them

### MCP Tool Integration (When Available):
- **Session Start:** Load previous context from Claude Context MCP
- **Task Creation:** Convert completed tasks to GitHub issues  
- **Decision Storage:** Save architectural decisions to vector database
- **Sprint Planning:** Use GitHub Project Manager for milestone tracking

```bash
# Session Start Checklist:
□ Read planning.MD for context
□ Check tasks.MD for current work items
□ Load previous session context (Context MCP)
□ Check GitHub Project status (GitHub MCP)
□ Verify project files exist (Filesystem MCP)
□ Test database connection (PostgreSQL MCP)
□ Select task(s) to work on
□ Update tasks.MD when done
□ Save all file changes directly
□ Create GitHub issues for completed work
□ Store important decisions in context
□ Add new tasks discovered during work
```

### File Structure Expected:
```
golf-sim-app/
├── Claude.MD (this file - project guide)
├── planning.MD (project planning, milestones, decisions)
├── tasks.MD (active task list, completed items, backlog)
└── [project code files]
```

---

## 🛠️ MCP TOOLS CONFIGURATION

### Available MCP Servers

#### 1. GitHub Project Manager MCP ✅
**Repository:** yeyowtx/Golf-sim-app  
**Purpose:** Comprehensive GitHub project management and AI-powered development assistance

**Project Management Tools (40+):**
- Project creation and management
- Issues and milestone tracking  
- Sprint planning and management
- Custom fields and views
- Pull request management
- Branch protection and workflows

**AI-Powered Features (8 tools):**
- `generate_prd` - Generate Product Requirements Documents
- `parse_tasks` - Break down requirements into actionable tasks
- `analyze_complexity` - Assess task complexity and effort
- `requirements_traceability` - Track requirements through development
- `generate_sprint_plan` - Create sprint plans from task list
- `suggest_milestones` - Recommend project milestones
- `estimate_timeline` - Calculate realistic timelines
- `dependency_mapping` - Identify task dependencies

**Common Commands:**
```bash
# Create a new GitHub issue from task
"Create a GitHub issue for implementing the booking system"

# Generate sprint plan
"Generate a sprint plan for the next 2 weeks based on tasks.MD"

# Analyze complexity
"Analyze the complexity of Square integration tasks"

# Track requirements
"Map PRD requirements to current implementation status"
```

#### 2. Claude Context MCP ✅
**Purpose:** Vector-based context management and memory persistence across sessions

**Features:**
- 📚 **Context Management:** Store and retrieve project context using vector embeddings
- 🔍 **Semantic Search:** Find relevant information across all project documentation
- 🧠 **Memory Persistence:** Maintain conversation context across Claude sessions
- 🔗 **Cross-Reference:** Automatically link related concepts and documents

**Use Cases:**
```bash
# Store important decisions
"Store this architecture decision in context: We chose PostgreSQL for ACID compliance"

# Retrieve related information
"What have we decided about the payment processing architecture?"

# Find similar implementations
"Search for similar booking system implementations in our context"

# Maintain session continuity
"What were we working on in the last session?"
```

#### 4. Filesystem MCP ✅
**Repository:** modelcontextprotocol/servers  
**Purpose:** Direct file and directory management for seamless code development

**File Operations:**
- Read/write text and code files directly
- Edit files with pattern matching (no more copy-paste!)
- Get file metadata and information
- Handle media files and assets

**Directory Operations:**
- Create and manage project structure
- Move/rename files and directories
- Search files with glob patterns
- Generate directory tree structures

**Security Features:**
- Sandboxed access to /Users/apple
- Dynamic directory access control
- Secure path validation

**Golf Sim App Specific Commands:**
```bash
# Project structure creation
"Create the Next.js project structure for Golf Sim App"

# Code file management
"Read the current package.json and add Square SDK dependencies"

# Direct code editing
"Update the booking controller to include 15-minute buffer logic"

# File searching
"Find all files that reference 'Square' in the project"

# Bulk operations
"Create all the API route files for member management"

# iOS preparation (Phase 2)
"Set up the Swift project structure for the iOS app"
```

### MCP Tool Power Combinations 🔥

#### The Complete Development Stack:
1. **Filesystem MCP** → Direct code manipulation
2. **PostgreSQL MCP Pro** → Database management
3. **GitHub Project Manager** → Task and version control
4. **Claude Context** → Memory and decision tracking

#### Workflow Synergies:
```bash
# Example: Creating a new feature
1. Filesystem: "Create booking-service.ts file"
2. PostgreSQL: "Create bookings table with optimized indexes"
3. GitHub: "Create issue for booking system implementation"
4. Context: "Store decision: Using transaction locks for concurrent bookings"

# Example: Debugging
1. Filesystem: "Read the error logs in /logs directory"
2. PostgreSQL: "Analyze query performance for slow booking queries"
3. GitHub: "Create bug issue with stack trace"
4. Context: "Search for similar issues we've solved before"
```

### How to Use MCP Tools Effectively

#### For Database Development (PostgreSQL MCP Pro):
1. Start with health check to establish baseline
2. Create schema with AI assistance
3. Use index tuning for booking query optimization
4. Monitor performance during development
5. Use hypothetical indexes before creating real ones

#### For Sprint Planning (GitHub MCP):
1. Parse tasks.MD into GitHub issues
2. Generate sprint plans based on priority and dependencies
3. Track progress directly in GitHub Projects

#### For Development Context (Claude Context MCP):
1. Store architectural decisions
2. Search for similar code patterns
3. Maintain consistency across codebase
4. Remember session progress

### MCP Tool Integration Workflow
```
1. START SESSION
   ├── Claude Context MCP loads previous session memory
   ├── Check GitHub Project for current sprint status
   ├── PostgreSQL MCP Pro health check
   ├── Filesystem MCP reads project state
   └── Review stored architectural decisions

2. DURING DEVELOPMENT
   ├── Filesystem MCP creates/edits code files directly
   ├── PostgreSQL MCP manages schema and optimizations
   ├── Create GitHub issues for new tasks discovered
   ├── Store important decisions in context
   └── Update GitHub Project boards

3. END SESSION
   ├── Store session summary in context
   ├── Filesystem MCP saves all code changes
   ├── Update GitHub milestones
   ├── Run final database health check
   └── Generate next session's priorities
```

### MCP Tool Power Combinations 🔥

**The Complete Development Stack:**
1. **Filesystem MCP** → Direct code manipulation (no more copy-paste!)
2. **PostgreSQL MCP Pro** → Database management with AI optimization
3. **GitHub Project Manager** → Task tracking and version control
4. **Claude Context** → Memory persistence across sessions

**Real Workflow Examples:**

```bash
# Creating the Booking System (Week 5-6)
1. Filesystem: "Create /api/bookings route structure"
2. PostgreSQL: "Design bookings table with 15-minute buffer constraints"
3. Filesystem: "Write the booking validation logic in booking-service.ts"
4. PostgreSQL: "Add indexes for availability queries"
5. GitHub: "Create PR for booking system implementation"
6. Context: "Store decision: Using database constraints for buffer time"

# Square Integration (Week 7-8)
1. Filesystem: "Add Square SDK to package.json and install"
2. Filesystem: "Create /api/square webhook handlers"
3. PostgreSQL: "Create payment_methods table for card-on-file"
4. Filesystem: "Implement tab auto-charge logic in tab-service.ts"
5. GitHub: "Track Square integration progress in project board"
6. Context: "Store Square webhook patterns for reuse"

# Debugging Production Issue
1. Filesystem: "Read error logs from /logs/error.log"
2. PostgreSQL: "Analyze slow query log for booking searches"
3. Context: "Search for similar timeout issues"
4. Filesystem: "Fix the N+1 query in member-service.ts"
5. GitHub: "Create hotfix PR with issue reference"
```

### Best Practices for MCP Usage

1. **File Development (Filesystem MCP)**
   - Create entire project structure in one session
   - Edit multiple files without copy-paste fatigue
   - Search and replace across entire codebase
   - Keep all code in sync with direct file access
   - Generate boilerplate code instantly

2. **Database Development (PostgreSQL MCP Pro)**
   - Always run health check before major changes
   - Use AI index recommendations for booking queries
   - Test hypothetical indexes before creation
   - Monitor connection pools for Square API calls
   - Optimize vacuum settings for 24/7 operation

3. **Always Store Critical Decisions (Context MCP)**
   - Architecture choices
   - API integration approaches
   - Security implementations
   - Performance optimizations
   - Bug solutions for future reference

4. **Use GitHub Issues for Task Tracking**
   - Convert tasks.MD items to GitHub issues
   - Link PRs to issues for traceability
   - Use labels for priority and categorization

5. **Leverage AI Features for Planning**
   - Generate sprint plans weekly
   - Analyze complexity before committing to timelines
   - Use dependency mapping to avoid blockers

6. **Maintain Context Continuity**
   - Store session summaries
   - Document blocking issues
   - Keep implementation patterns searchable

---

## Project Overview

**Product:** Golf Sim App - A white-label SaaS platform for golf simulation facilities  
**Primary Goal:** iOS Application in Apple App Store  
**Development Strategy:** Web Application first (beta), then native iOS app  
**Beta Launch:** September 2025  
**Success Metric:** Customer feedback: "way better than USchedule"

## Quick Context for Claude Code

This is a comprehensive golf simulation facility management platform that combines:
- Member management with multi-location support
- Booking system for golf bays, lessons, and events
- POS integration via Square (tabs, payments, inventory)
- Marketing automation via GoHighLevel (GHL)
- White-label SaaS architecture similar to GHL's model

## Development Phases

### Phase 1: Web Application (Current Priority - September 2025 Beta)
- **Purpose:** Foundation and beta testing platform
- **Stack Recommendation:** 
  - Frontend: React/Next.js with responsive mobile-first design
  - Backend: Node.js/Express or Python/Django
  - Database: PostgreSQL for permanent data retention
  - Hosting: AWS/Vercel/Railway for scalability

### Phase 2: iOS Application (Primary Product Goal)
- **Purpose:** Native iOS app for Apple App Store
- **Stack:** Swift/SwiftUI
- **Requirements:** Apple Developer Account, App Store compliance

## Core Architecture Requirements

### Database Schema Needs
```
- Users (roles: owner, manager, staff, member)
- Members (profiles, multi-location parameters)
- Bookings (bays, lessons, events with 1-hour slots)
- Transactions (payments, tabs, invoices)
- Products/Services (custom items, pricing)
- Locations (for white-label multi-facility support)
```

### Key Business Rules
1. **Booking System:**
   - 1-hour increments for bay reservations
   - 15-minute buffer between bookings for cleanup
   - Members get priority booking
   - First-come-first-serve within member tier
   - Required card-on-file for ALL bookings

2. **Payment System:**
   - Membership-based with pay-as-you-go support
   - Tab system with end-of-day auto-closure
   - 24-hour grace period for unpaid tabs
   - Automatic charge to card-on-file after grace period
   - No peak/off-peak pricing

3. **Multi-Location Support:**
   - Member parameter restrictions per location
   - White-label capability for different facilities
   - Centralized management dashboard

## Integration Requirements

### Square Integration (Critical)
```javascript
// Required Square API endpoints:
- Payments API (process transactions)
- Customers API (member profiles)
- Catalog API (products/services)
- Orders API (tab management)
- Cards API (card-on-file storage)
- Invoices API (billing)
```

**Key Features:**
- Full POS functionality
- Tab system with auto-charge
- Inventory synchronization
- Gift cards and loyalty points
- End-of-shift reporting

### GoHighLevel Integration
```javascript
// GHL API requirements:
- Contact management sync
- Automated booking confirmations
- SMS/Email reminders (24hr, 1hr before)
- Social media posting
- Lead nurturing workflows
- Website management
- MVP snapshot creation
```

## Implementation Priorities

### MVP Features (Phase 1 - Must Have)
1. **Authentication & User Management**
   - Role-based access (owner/manager/staff/member)
   - Member portal creation on signup
   - Secure session management

2. **Booking System**
   ```javascript
   // Core booking logic
   - Check member status
   - Validate time slot availability
   - Apply 15-minute buffer
   - Require card-on-file
   - Send confirmation via GHL
   ```

3. **Square POS Integration**
   ```javascript
   // Essential POS features
   - Payment processing
   - Tab creation/management
   - Auto-charge system (24hr grace)
   - Member purchase history
   ```

4. **Member Management**
   - Profile creation/editing
   - Multi-location parameters
   - Transaction visibility
   - Portal access

### Nice-to-Have Features (Can implement later)
- AI booking assistant
- Advanced analytics dashboard
- Community features
- Loyalty program mechanics (TBD)

## Code Organization Structure

```
golf-sim-app/
├── frontend/
│   ├── components/
│   │   ├── booking/
│   │   ├── members/
│   │   ├── pos/
│   │   └── shared/
│   ├── pages/
│   │   ├── admin/
│   │   ├── staff/
│   │   └── member-portal/
│   └── services/
│       ├── square-api/
│       └── ghl-api/
├── backend/
│   ├── models/
│   ├── controllers/
│   ├── middleware/
│   ├── integrations/
│   │   ├── square/
│   │   └── ghl/
│   └── utils/
└── shared/
    └── types/
```

## API Design Patterns

### RESTful Endpoints Structure
```javascript
// Members
GET    /api/members
POST   /api/members
GET    /api/members/:id
PUT    /api/members/:id
DELETE /api/members/:id

// Bookings
GET    /api/bookings
POST   /api/bookings
GET    /api/bookings/:id
PUT    /api/bookings/:id
DELETE /api/bookings/:id

// Square Integration
POST   /api/square/charge
POST   /api/square/tab/create
POST   /api/square/tab/close
GET    /api/square/transactions

// GHL Integration
POST   /api/ghl/trigger/booking-confirmation
POST   /api/ghl/trigger/reminder
```

## Security Considerations

1. **Payment Security:**
   - PCI compliance required
   - Never store raw card data
   - Use Square's secure tokenization
   - Implement proper SSL/TLS

2. **Authentication:**
   - JWT tokens for session management
   - Role-based access control (RBAC)
   - Secure password hashing (bcrypt)
   - 2FA for admin accounts (optional)

3. **Data Protection:**
   - HTTPS everywhere
   - Input validation/sanitization
   - SQL injection prevention
   - Rate limiting on APIs

## Testing Strategy

### Unit Tests
- Business logic (booking rules, pricing)
- Integration endpoints
- Validation functions

### Integration Tests
- Square API workflows
- GHL automation triggers
- End-to-end booking flow

### User Acceptance Tests
- Member can book a bay
- Staff can process payments
- Tabs auto-close properly
- Reminders send correctly

## Environment Variables

```env
# Database
DATABASE_URL=

# Square
SQUARE_ACCESS_TOKEN=
SQUARE_APPLICATION_ID=
SQUARE_LOCATION_ID=
SQUARE_ENVIRONMENT=sandbox|production

# GoHighLevel
GHL_API_KEY=
GHL_LOCATION_ID=

# App
JWT_SECRET=
NODE_ENV=development|production
API_URL=
FRONTEND_URL=
```

## Outstanding Questions to Clarify

1. **Loyalty Program:** Specific point values and redemption rules?
2. **Food/Beverage:** Need menu items and prices for beta
3. **Booking Windows:** How far in advance can members book vs non-members?
4. **GHL Specifics:** Exact API endpoints and authentication method
5. **Square Scope:** Any limitations on Square integration features?

## Development Commands Quick Reference

```bash
# Session Start (Claude should do automatically)
"First, let me check planning.MD and tasks.MD..."
"Load previous session context from Claude Context MCP"
"Check GitHub Project status for current sprint"

# GitHub Project Management
"Create GitHub issues from today's completed tasks"
"Generate a sprint plan for the booking system milestone"
"Analyze complexity of Square integration tasks"
"Update GitHub milestone progress"

# Context Management
"Store this architecture decision: [decision details]"
"Search context for previous payment integration approaches"
"What decisions have we made about multi-tenant architecture?"
"Save session summary before ending"

# When starting a new session
"Help me implement the [specific feature] for the Golf Sim App based on the PRD requirements"

# For integration work
"I need to integrate Square's [specific API] for the tab management system"

# For debugging
"The booking system isn't applying the 15-minute buffer correctly, here's my code..."

# For architecture decisions
"Should we use [technology X] or [technology Y] for the member portal given our requirements?"

# Task Management (Claude should do automatically)
"I've completed [task X], updating tasks.MD and creating GitHub issue..."
"I discovered we need to [new requirement], adding to tasks.MD and GitHub backlog..."
```

## Success Criteria Checklist

- [ ] Members can create accounts and access portal
- [ ] Booking system works with 1-hour slots and buffers
- [ ] Square POS fully integrated with tab system
- [ ] Card-on-file required and working
- [ ] 24-hour auto-charge system functional
- [ ] GHL sending automated confirmations/reminders
- [ ] Multi-location member restrictions working
- [ ] White-label architecture supports multiple facilities
- [ ] Responsive design works on all devices
- [ ] Beta testers say it's "better than USchedule"

## Notes for Claude Code Sessions

### ⚠️ WORKFLOW REMINDERS (CRITICAL)
1. **ALWAYS start by reading `planning.MD` and `tasks.MD`**
2. **NEVER start coding without checking current tasks**
3. **ALWAYS update `tasks.MD` immediately after completing work**
4. **ALWAYS add newly discovered requirements to `tasks.MD`**
5. **USE MCP tools when available for GitHub integration and context persistence**

### MCP Tool Benefits
- **GitHub MCP:** Automates project management, tracks issues, generates sprint plans
- **Context MCP:** Maintains memory across sessions, enables semantic search of past decisions
- **Combined Power:** Creates a self-documenting, intelligent development environment

### Technical Reminders
1. **Always consider multi-location architecture** - Every feature should support white-label/multi-facility use
2. **Card-on-file is mandatory** - No booking or tab without stored payment method
3. **Square is the payment backbone** - All financial transactions go through Square
4. **GHL handles all marketing automation** - Don't build email/SMS systems, use GHL
5. **Mobile-first design** - Web app should feel native on mobile (prep for iOS)
6. **Permanent data storage** - Never delete transaction or member data

## Competitor Reference
Current system to beat: https://clients.uschedule.com/evergreengolfclub/product?View=List

---

## REQUIRED COMPANION FILES

### planning.MD Template
```markdown
# Golf Sim App - Project Planning

## Current Phase
Phase 1: Web Application (Beta - September 2025)

## Current Sprint/Milestone
[Current work focus]

## Recent Decisions
- [Date] Decision made about X
- [Date] Chose technology Y for Z

## Architecture Decisions
- Frontend: [Framework choice]
- Backend: [Framework choice]
- Database: [Database choice]
- Hosting: [Platform choice]

## Integration Status
- Square API: [Not Started/In Progress/Complete]
- GHL API: [Not Started/In Progress/Complete]

## Blockers
- [Any current blockers]

## Next Major Milestone
[What we're working toward]
```

### tasks.MD Template
```markdown
# Golf Sim App - Task List

## 🔥 CURRENT SPRINT
- [ ] Task description [Priority: High/Medium/Low]
- [ ] Another task [Priority: High]

## 📋 BACKLOG
- [ ] Future task
- [ ] Another future task

## ✅ COMPLETED
- [x] Completed task [Completed: 2025-09-15 14:30]
- [x] Another done task [Completed: 2025-09-14 10:00]

## 🆕 NEWLY DISCOVERED (During Development)
- [ ] Task found while coding [Added: 2025-09-15]
- [ ] Technical debt item [Added: 2025-09-14]

## 🔍 QUESTIONS/CLARIFICATIONS NEEDED
- [ ] Question about loyalty program mechanics
- [ ] Need Square API credentials
```

---

*Last Updated: September 2025*  
*Project Status: Ready for Phase 1 Development*  
*Next Milestone: September 2025 Beta Launch*