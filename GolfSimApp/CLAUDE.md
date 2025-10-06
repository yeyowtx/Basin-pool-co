# Golf Sim App - PRODUCTION READY PROJECT

## 🎯 CURRENT FOCUS: BOOKING FLOW ENHANCEMENT
```
Project Path: /Users/apple/GolfSimApp/GolfSimProiOS.xcodeproj
Project ID: 1D92AAA62CA73D1E00123456
Bundle ID: com.golfsim.pro
Working Directory: /Users/apple/GolfSimApp
Current Session Focus: Enhance booking tab functionality with TopGolf-inspired UX
```

### 📋 TERMINAL SESSION FOCUS PROMPT:
**"We are working on enhancing the booking flow in our golf simulator app. Use 'launch simulator' to build and test the 4-tab navigation system (Book | Activity | Shop | Account) with TopGolf-inspired features and USchedule competitive intelligence. All terminals coordinate through the main GolfSimProiOS.xcodeproj."**

### 🎯 ACTIVE DEVELOPMENT PRIORITIES:
1. **Booking Flow Enhancement** - Improve time slot selection, bay availability, member pricing
2. **TopGolf UI Integration** - Use indexed TopGolf-SwiftUI-Components for consistent design
3. **USchedule Intelligence** - Apply competitive analysis for pricing and features
4. **Member Experience** - Leverage authentication system for personalized booking

## 🔄 MULTI-TERMINAL DEVELOPMENT WORKFLOW

### 📋 TERMINAL SESSION STARTUP (ALL TERMINALS):
```bash
# Required sequence for every terminal session:
1. cd /Users/apple/GolfSimApp
2. Read CLAUDE.md for current focus and standards
3. Check planning.md for coordination status and other terminals' work
4. Build project to verify current state: xcodebuild -project GolfSimProiOS.xcodeproj -scheme GolfSimProiOS -destination 'platform=iOS Simulator,name=iPhone 16' build
5. Begin feature-specific work using existing project structure
```

### 🎯 FEATURE ISOLATION STRATEGY:
- **Single Project Rule**: ALWAYS use `/Users/apple/GolfSimApp/GolfSimProiOS.xcodeproj`
- **Feature-Specific Files**: Create new Swift files for major features (e.g., `EnhancedBookingView.swift`, `PaymentFlowView.swift`)
- **Tab Integration**: Modify existing tab views (`BookTabView`, `ShopTabView`, etc.) in main project
- **Shared Resources**: Leverage existing authentication system, models (`CoreModels.swift`, `MembershipModels.swift`), and design system (`EvergreenColors.swift`, `TopGolfDesignSystem.swift`)
- **Environment Objects**: Use existing `AuthenticationService()`, `BayStatusManager()`, `TabManager()` from SimpleTabApp.swift

### 📊 TERMINAL COORDINATION ASSIGNMENTS:
- **Master Terminal (Current)**: Project coordination, build management, integration testing, CLAUDE.md maintenance
- **Booking Terminal**: Enhanced booking features, time slot optimization, group booking improvements
- **Payment Terminal**: Square SDK integration, tab management, bill splitting enhancements
- **Member Terminal**: Loyalty features, member dashboard, referral system, push notifications
- **Admin Terminal**: Staff tools, backend integration, analytics, operational dashboards

### 📝 SESSION COORDINATION PROTOCOL:
```bash
# At Start of Each Terminal Session:
1. Read current focus from CLAUDE.md
2. Check what other terminals are working on in planning.md
3. Verify project builds successfully
4. Create/modify your feature-specific files within main project

# During Development:
1. Work on assigned tab/feature area
2. Use existing authentication and design systems
3. Test changes within complete app context using "launch simulator"
4. Document any shared model or service changes needed

# At End of Each Session:
1. Ensure project builds successfully
2. Update planning.md with progress and any coordination notes
3. Index codebase: mcp__claude-context__index_codebase --path /Users/apple/GolfSimApp
4. Note any dependencies or integration points for other terminals
```

## ✅ AUTHENTICATION SYSTEM COMPLETE
**Professional golf club authentication flow with comprehensive membership integration**

### 🏆 COMPLETED FEATURES:
- ✅ **AuthenticationManager** - iOS Keychain integration with secure credential storage
- ✅ **Welcome Splash Screen** - Professional Evergreen Golf Club branding with fade animation
- ✅ **3-Option Authentication Flow** - "Already a Member?", "Become a Member", "Continue as Guest"
- ✅ **Member Sign-In** - Auto-login functionality with demo credentials (john@example.com, etc.)
- ✅ **Membership Application** - Complete USchedule tier system (Junior $149, Cascade $199, Pike $299, Rainier $399)
- ✅ **Guest Information Flow** - Smart conversion prompts with returning guest detection
- ✅ **Authenticated Booking** - User-specific pricing with automatic 15% member discounts
- ✅ **Member vs Guest Pricing** - Real USchedule rates ($36/$48/$60) with member benefits

## 🔄 MULTI-SESSION COORDINATION REQUIREMENTS

### 📋 MANDATORY FOR ALL CLAUDE CODE SESSIONS:
1. **Working Directory**: `/Users/apple/GolfSimApp` (ALWAYS use this path)
2. **Project Verification**: Run `xcodebuild -project GolfSimProiOS.xcodeproj -scheme GolfSimProiOS -showBuildSettings | head -10` on startup
3. **Build Before Changes**: Always build project before making significant modifications
4. **Coordination**: Check planning.md for current development priorities and session allocation
5. **🔍 CODEBASE INDEXING**: Use Claude Context MCP for efficient code search and multi-session coordination

### 🚀 SESSION STARTUP COMMANDS:
```bash
cd /Users/apple/GolfSimApp
xcodebuild -project GolfSimProiOS.xcodeproj -scheme GolfSimProiOS -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## 📱 SIMULATOR LAUNCH STANDARDS

### 🎯 STANDARD LAUNCH COMMAND:
```bash
# Master command: "launch simulator" executes this complete sequence
cd /Users/apple/GolfSimApp && xcodebuild -project GolfSimProiOS.xcodeproj -scheme GolfSimProiOS -destination 'platform=iOS Simulator,name=iPhone 16' build && open -a Simulator && xcrun simctl launch booted com.golfsim.pro
```

### ⚡ QUICK LAUNCH COMMANDS:
```bash
# Build only (verify compilation)
xcodebuild -project GolfSimProiOS.xcodeproj -scheme GolfSimProiOS -destination 'platform=iOS Simulator,name=iPhone 16' build

# Launch simulator app (after successful build)
open -a Simulator && xcrun simctl launch booted com.golfsim.pro

# Complete build + launch sequence
cd /Users/apple/GolfSimApp && xcodebuild -project GolfSimProiOS.xcodeproj -scheme GolfSimProiOS -destination 'platform=iOS Simulator,name=iPhone 16' build && open -a Simulator && xcrun simctl launch booted com.golfsim.pro
```

### 🔧 TROUBLESHOOTING COMMANDS:
```bash
# Clean build (use when build fails)
xcodebuild -project GolfSimProiOS.xcodeproj -scheme GolfSimProiOS clean

# Reset simulator (use when app won't launch)
xcrun simctl shutdown all && xcrun simctl boot "iPhone 16"

# Force kill and restart simulator
pkill -f Simulator && open -a Simulator

# Clean + rebuild + launch sequence
cd /Users/apple/GolfSimApp && xcodebuild -project GolfSimProiOS.xcodeproj -scheme GolfSimProiOS clean && xcodebuild -project GolfSimProiOS.xcodeproj -scheme GolfSimProiOS -destination 'platform=iOS Simulator,name=iPhone 16' build && open -a Simulator && xcrun simctl launch booted com.golfsim.pro
```

### ⚡ QUICK COMMANDS REFERENCE:

#### 🏃‍♂️ IMMEDIATE ACTION COMMANDS:
- **"launch simulator"** → Execute complete build + launch sequence to test app
- **"build project"** → Run xcodebuild to verify compilation without launching
- **"check status"** → Show git status, current files, and build state
- **"index codebase"** → Run Claude Context MCP indexing for multi-session coordination

#### 🔍 DEBUGGING COMMANDS:
- **"show build errors"** → Parse and display specific compilation issues
- **"clean project"** → Clean build artifacts and rebuild from scratch
- **"reset simulator"** → Force restart simulator environment
- **"fix syntax"** → Address common Swift compilation errors

#### 📱 TAB NAVIGATION TESTING:
- **Booking Tab**: Default launch (tab 0) - Time slots, bay selection, booking flow
- **Activity Tab**: User session history and golf activity tracking  
- **Shop Tab**: Pro shop, food/beverage menu, equipment sales
- **Account Tab**: Member profile, authentication, settings

#### 🔄 COORDINATION COMMANDS:
- **"update planning"** → Sync progress with planning.md for other terminals
- **"check conflicts"** → Verify no file conflicts with other terminal sessions
- **"merge status"** → Review integration points and dependencies

## 🔄 LIVE DEVELOPMENT WORKFLOW

### 📱 REAL-TIME EDIT & TEST CYCLE:

#### **Step 1: Initial Launch**
```bash
# Command: "launch simulator"
cd /Users/apple/GolfSimApp && xcodebuild -project GolfSimProiOS.xcodeproj -scheme GolfSimProiOS -destination 'platform=iOS Simulator,name=iPhone 16' build && open -a Simulator && xcrun simctl launch booted com.golfsim.pro
```

#### **Step 2: Make Code Changes**
- Edit Swift files (BookTabView.swift, ShopTabView.swift, etc.)
- Save changes (Cmd+S in editor)
- Focus on single tab/feature per edit session

#### **Step 3: Push Changes to Simulator**
```bash
# Command: "push changes" or "rebuild app"
xcodebuild -project GolfSimProiOS.xcodeproj -scheme GolfSimProiOS -destination 'platform=iOS Simulator,name=iPhone 16' build && xcrun simctl launch booted com.golfsim.pro
```

#### **Step 4: Navigate & Test in Simulator**
- **Book Tab (📅)**: Time slots, bay selection, booking flow
- **Activity Tab (🕘)**: Session history, user activity tracking
- **Shop Tab (🛒)**: USchedule pricing, member discounts, cart functionality
- **Account Tab (👤)**: Authentication flow, member profile, settings

### ⚡ RAPID ITERATION COMMANDS:

#### **🏃‍♂️ Fast Development Loop:**
```bash
# Build only (check for compilation errors)
"build project" → xcodebuild -project GolfSimProiOS.xcodeproj -scheme GolfSimProiOS -destination 'platform=iOS Simulator,name=iPhone 16' build

# Launch only (after successful build)
"relaunch app" → xcrun simctl launch booted com.golfsim.pro

# Full rebuild + launch
"push changes" → xcodebuild -project GolfSimProiOS.xcodeproj -scheme GolfSimProiOS -destination 'platform=iOS Simulator,name=iPhone 16' build && xcrun simctl launch booted com.golfsim.pro
```

### 📋 REAL WORKFLOW EXAMPLE:

#### **Booking Tab Enhancement Session:**
```bash
# 1. Initial setup
"launch simulator"

# 2. Navigate to Book tab in simulator → Test current state
# 3. Edit BookTabView.swift → Improve time slot selection UI
# 4. Save changes (Cmd+S)

"push changes"

# 5. Navigate to Book tab again → Verify time slot improvements
# 6. Edit EvergreenBookingFlow.swift → Add bay availability logic
# 7. Save changes

"push changes"

# 8. Test complete booking flow → Book tab → Select time → Choose bay
# 9. Document changes in planning.md
# 10. End session with successful build verification
```

### 🎯 WORKFLOW REFERENCE COMMANDS:

#### **Starting Development:**
- **"start development"** = Launch simulator + navigate to your assigned tab
- **"quick setup"** = cd /Users/apple/GolfSimApp + verify build + launch

#### **During Development:**
- **"push changes"** = Rebuild + relaunch to see your edits
- **"test navigation"** = Verify all 4 tabs still work after changes
- **"verify auth"** = Test both member and guest user experiences

#### **Ending Session:**
- **"final build"** = Ensure project builds successfully before ending
- **"update coordination"** = Document progress in planning.md for other terminals

### 🧭 SIMULATOR NAVIGATION SHORTCUTS:
- **Cmd+Shift+H** = Home button (return to app home)
- **Cmd+R** = Rotate device orientation
- **Window→Scale** = Adjust simulator size for better viewing
- **Hardware→Device** = Switch device type if needed

### ⚠️ TROUBLESHOOTING QUICK FIXES:
```bash
# Build fails
"clean project" → xcodebuild -project GolfSimProiOS.xcodeproj -scheme GolfSimProiOS clean

# App won't launch
"reset simulator" → xcrun simctl shutdown all && xcrun simctl boot "iPhone 16"

# Simulator frozen
"restart simulator" → pkill -f Simulator && open -a Simulator
```

## 🔍 CLAUDE CONTEXT MCP - CODEBASE SEARCH SYSTEM

### ⚡ CRITICAL: INDEX MANAGEMENT
**🚨 ALWAYS INDEX AFTER KEY CHANGES - ENABLES MULTI-SESSION COORDINATION**

### 📋 WHEN TO INDEX:
1. **Session End**: ALWAYS index before ending any Claude Code session
2. **After Major Features**: Index after completing authentication, payments, etc.
3. **Before Complex Work**: Index before starting multi-file modifications
4. **Multi-Session Prep**: Index to enable other terminal tabs to search efficiently

### 🛠️ INDEXING COMMANDS:
```bash
# Index the entire codebase (run after key changes)
mcp__claude-context__index_codebase --path /Users/apple/GolfSimApp

# Search indexed code (use for finding existing functionality)
mcp__claude-context__search_code --path /Users/apple/GolfSimApp --query "authentication manager"

# Check indexing status
mcp__claude-context__get_indexing_status --path /Users/apple/GolfSimApp
```

### 🎯 MULTI-SESSION BENEFITS:
- **Tab A (Booking)**: Search "booking flow" → instantly find EvergreenBookingFlow.swift
- **Tab B (Payments)**: Search "user pricing" → find member discount logic
- **Tab C (Members)**: Search "membership tiers" → locate USchedule integration
- **Tab D (Admin)**: Search "authentication" → find all auth-related files

### ⚠️ INDEXING PROTOCOL:
1. **Before Session End**: `mcp__claude-context__index_codebase --path /Users/apple/GolfSimApp`
2. **Document Changes**: Update planning.md with what was added/modified
3. **Enable Team**: Other Claude Code sessions can now search your changes instantly

## 📁 PRODUCTION PROJECT STRUCTURE
```
GolfSimApp/
├── GolfSimProiOS.xcodeproj           ← MAIN XCODE PROJECT (Multi-session coordination point)
├── GolfSimProiOS/                    ← iOS APP SOURCE - AUTHENTICATION COMPLETE
│   ├── Services/                     ← ✅ Authentication & Core Services
│   │   ├── AuthenticationManager.swift ← ✅ iOS Keychain integration
│   │   └── AuthenticationService.swift ← ✅ User management
│   ├── Views/                        ← ✅ COMPLETE AUTHENTICATION FLOW
│   │   ├── WelcomeFlowView.swift    ← ✅ Splash screen + 3-option auth
│   │   ├── MemberSignInScreen.swift ← ✅ Auto-login with Keychain
│   │   ├── MembershipApplicationFlow.swift ← ✅ USchedule tier system
│   │   ├── GuestInformationFlow.swift ← ✅ Smart conversion prompts
│   │   ├── EvergreenBookingFlow.swift ← ✅ Authenticated booking with pricing
│   │   └── [other production views]
│   ├── Models/                       ← ✅ Complete data structures
│   │   ├── CoreModels.swift         ← ✅ User, Customer, Venue models
│   │   ├── MembershipModels.swift   ← ✅ USchedule tier integration
│   │   └── [other model files]
│   └── DesignSystem/                ← ✅ Evergreen branding
├── competitive-intelligence/         ← ✅ USchedule analysis & requirements
├── planning.md                      ← ✅ Multi-session development coordination
├── CLAUDE.md                        ← ✅ This file - session coordination guide
└── CLEAN_PROJECT_BACKUP/            ← Historical backup
```

## 📊 DATA SOURCES (Use These)
1. **USchedule Pricing:** `uschedule-authenticated-extractor/final-comprehensive-uschedule-intelligence.md`
2. **TopGolf Components:** `TopGolf-SwiftUI-Components/` (reusable UI)
3. **Competitive Analysis:** `competitive-intelligence/`

## 🎯 MULTI-TAB DEVELOPMENT PRIORITIES

### 🔄 CURRENT DEVELOPMENT FOCUS:
1. **Tab A: Enhanced Booking Features** - Time slot optimization, group booking improvements
2. **Tab B: Payment Integration** - Square SDK implementation, real payment processing
3. **Tab C: Member Experience** - Loyalty features, member benefits expansion
4. **Tab D: Admin/Staff Tools** - Backend integration, operational dashboards

### 📋 COORDINATION PROTOCOLS:
- **File Changes**: Always check if other sessions are modifying same files
- **Build Verification**: Test builds before major commits
- **Documentation**: Update planning.md with session progress
- **Conflict Prevention**: Use different feature branches if needed

## 🏆 AUTHENTICATION SYSTEM ACHIEVEMENTS COMPLETED
- ✅ **Professional UX**: Replaced simple toggle with comprehensive auth flow
- ✅ **iOS Keychain Security**: Secure credential storage with auto-login
- ✅ **Smart Member Conversion**: Intelligent guest-to-member prompts
- ✅ **USchedule Business Logic**: Complete tier system with real pricing
- ✅ **Competitive Advantage**: Native iOS experience vs USchedule web-only

## ✅ PROJECT STATUS: PRODUCTION READY FOR AUTHENTICATION
- ✅ Clean, focused project structure maintained
- ✅ Authentication system builds and runs successfully  
- ✅ Ready for multi-session feature development
- ✅ Superior to USchedule user experience achieved

---
**Status:** Authentication Complete - Ready for Feature Expansion  
**Priority:** Coordinate multi-tab development for payment integration and enhanced features