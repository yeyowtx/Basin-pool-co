import SwiftUI

@main  
struct SimpleGolfSimApp: App {
    var body: some Scene {
        WindowGroup {
            // Launch directly to 4-tab system for booking flow testing
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var bayStatusManager = BayStatusManager()
    @StateObject private var customerSessionManager: CustomerSessionManager
    
    init() {
        let bayManager = BayStatusManager()
        _bayStatusManager = StateObject(wrappedValue: bayManager)
        _customerSessionManager = StateObject(wrappedValue: CustomerSessionManager(bayStatusManager: bayManager))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Book Tab
            BookTabView(sessionManager: customerSessionManager)
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "calendar.badge.plus" : "calendar")
                        .font(.system(size: 22))
                    Text("Book")
                }
                .tag(0)
            
            // Activity Tab
            ActivityTabView(sessionManager: customerSessionManager)
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "clock.arrow.circlepath" : "clock")
                        .font(.system(size: 22))
                    Text("Activity")
                }
                .tag(1)
            
            // Shop Tab
            ShopTabView(sessionManager: customerSessionManager)
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "cart.fill" : "cart")
                        .font(.system(size: 22))
                    Text("Shop")
                }
                .tag(2)
            
            // Account Tab
            AccountTabView(sessionManager: customerSessionManager)
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.circle.fill" : "person.circle")
                        .font(.system(size: 22))
                    Text("Account")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .onAppear {
            // Customize tab bar appearance
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor.systemBackground
            
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            
            // Initialize mock session for demo purposes
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                customerSessionManager.startMockActiveSession()
            }
        }
    }
}

// MARK: - Book Tab
struct BookTabView: View {
    @ObservedObject var sessionManager: CustomerSessionManager
    @State private var selectedTimeSlot = "7:00 PM"
    
    let timeSlots = ["7:00 PM", "7:15 PM", "7:30 PM", "7:45 PM", "8:00 PM"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Enhanced Bay Status Header for context awareness
                    BayStatusHeader(sessionManager: sessionManager, showDetails: true)
                        .padding(.horizontal)
                    
                    // Dynamic Welcome Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hello, \(userDisplayName)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        // Member/Guest Status Badge
                        Text(userStatusText)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(userStatusColor)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Simplified Location Info
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("EVERGREEN GOLF CLUB")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tacoma Location")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("OPEN until 11:00 PM")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            
                            Spacer()
                            
                            Text("Walk-ins Welcome")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Core Booking Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("BOOK YOUR TIME")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        // Time Slots
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(timeSlots, id: \.self) { time in
                                    Button(action: {
                                        selectedTimeSlot = time
                                    }) {
                                        Text(time)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(selectedTimeSlot == time ? .blue : .primary)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedTimeSlot == time ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Primary Booking Button
                        NavigationLink(destination: EvergreenExperienceView(bayNumber: 1)) {
                            Text("BOOK A BAY")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(.blue)
                                .cornerRadius(28)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // Dynamic user display name
    private var userDisplayName: String {
        if let session = sessionManager.currentSession {
            return session.customerName
        }
        return "Guest" // Default name - in real app would get from user input
    }
    
    // User status text
    private var userStatusText: String {
        if let session = sessionManager.currentSession, let tier = session.membershipTier {
            return tier.displayName.uppercased()
        }
        return "GUEST"
    }
    
    // User status color
    private var userStatusColor: Color {
        if let session = sessionManager.currentSession, session.membershipTier != nil {
            return .orange
        }
        return .blue
    }
}

struct BayCardView: View {
    let bayNumber: Int
    @State private var isAvailable = Bool.random()
    
    var body: some View {
        NavigationLink(destination: EvergreenExperienceView(bayNumber: bayNumber)) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill((isAvailable ? Color.green : Color.red).opacity(0.2))
                        .frame(height: 120)
                    
                    VStack(spacing: 8) {
                        Text("BAY \(bayNumber)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(isAvailable ? .green : .red)
                                .frame(width: 8, height: 8)
                            
                            Text(isAvailable ? "Available" : "Occupied")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(isAvailable ? .green : .red)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background((isAvailable ? Color.green : Color.red).opacity(0.1))
                        .cornerRadius(12)
                        
                        if isAvailable {
                            Text("Tap to book")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .disabled(!isAvailable)
    }
}

struct LegendItemView: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Activity Tab
struct ActivityTabView: View {
    @ObservedObject var sessionManager: CustomerSessionManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Current Session Status
                    if sessionManager.isSessionActive {
                        BayStatusHeader(sessionManager: sessionManager, showDetails: true, showQuickActions: true)
                            .padding(.horizontal)
                    }
                    
                    // Activity Header
                    HStack {
                        Text("Your Activity")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        if sessionManager.isSessionActive {
                            BayStatusBadge(sessionManager: sessionManager)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Current Session Stats
                    if let session = sessionManager.currentSession, session.isActive {
                        CurrentSessionStatsView(session: session, sessionManager: sessionManager)
                            .padding(.horizontal)
                    }
                    
                    // Session History
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recent Sessions")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        if SessionHistory.mockSessions().isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                                
                                Text("No Activity Yet")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("Your session history will appear here after you book your first bay.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding()
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(SessionHistory.mockSessions()) { session in
                                    SessionHistoryCard(session: session)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Enhanced Shop Tab with Integrated Bill Splitting
struct ShopTabView: View {
    @ObservedObject var sessionManager: CustomerSessionManager
    @State private var isSignedIn = true
    @State private var cartCount = 2
    @State private var showCart = false
    @State private var showBillSplit = false
    @State private var showGroupBooking = false
    
    var membershipType: String {
        sessionManager.currentSession?.membershipTier != nil ? "member" : "guest"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Session Context Header - Global awareness
                    BayStatusHeader(sessionManager: sessionManager, showDetails: false)
                        .padding(.horizontal)
                    
                    // Enhanced Header with Quick Actions
                    shopHeaderSection
                    
                    // Session-Aware Quick Actions
                    if sessionManager.isSessionActive {
                        sessionQuickActionsSection
                    }
                    
                    // Enhanced Categories with Social Integration
                    categoriesSection
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCart) {
                CartView(membershipType: membershipType)
            }
            .sheet(isPresented: $showBillSplit) {
                SimpleBillSplitView()
            }
            .sheet(isPresented: $showGroupBooking) {
                GroupBookingView()
            }
        }
    }
    
    // MARK: - Header Section
    private var shopHeaderSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("EVERGREEN SHOP")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Food • Gear • Services • Social")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Member Badge & Cart
                HStack(spacing: 12) {
                    // Member Status Badge
                    HStack(spacing: 4) {
                        Image(systemName: membershipType == "member" ? "crown.fill" : "person")
                            .font(.system(size: 10))
                        Text(membershipType == "member" ? "MEMBER" : "GUEST")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(membershipType == "member" ? Color.orange : Color.gray.opacity(0.2))
                    .foregroundColor(membershipType == "member" ? .white : .primary)
                    .cornerRadius(8)
                    
                    // Enhanced Cart Button
                    Button(action: { showCart = true }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "cart.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            if cartCount > 0 {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 18, height: 18)
                                    .overlay(
                                        Text("\(cartCount)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                    .offset(x: 15, y: -15)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Session Quick Actions
    private var sessionQuickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("QUICK ACTIONS")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickActionCard(
                        title: "Order F&B",
                        icon: "fork.knife",
                        color: .orange,
                        description: "To your bay"
                    ) {
                        // Navigate to menu
                    }
                    
                    QuickActionCard(
                        title: "Split Bill",
                        icon: "person.2.fill",
                        color: .purple,
                        description: "With group"
                    ) {
                        showBillSplit = true
                    }
                    
                    QuickActionCard(
                        title: "Extend Time",
                        icon: "plus.circle",
                        color: .blue,
                        description: "Add 30 min"
                    ) {
                        sessionManager.extendSession(additionalTime: 1800)
                    }
                    
                    QuickActionCard(
                        title: "Order Gear",
                        icon: "cart",
                        color: .green,
                        description: "Pro shop"
                    ) {
                        // Navigate to pro shop
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Enhanced Categories Section
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("SHOP CATEGORIES")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                // Food & Beverages
                NavigationLink(destination: MenuView(membershipType: membershipType)) {
                    EnhancedShopCategoryCard(
                        title: "FOOD & BEVERAGES",
                        subtitle: "Arnold Palmer $\(membershipType == "member" ? "3" : "4") • Burgers $\(membershipType == "member" ? "12" : "15")",
                        icon: "fork.knife",
                        color: .orange,
                        badge: "Popular",
                        badgeColor: .orange
                    )
                }
                
                // Pro Shop
                NavigationLink(destination: ProShopView(membershipType: membershipType)) {
                    EnhancedShopCategoryCard(
                        title: "PRO SHOP",
                        subtitle: "Golf clubs • Apparel • Accessories • Member discounts",
                        icon: "cart.fill",
                        color: .green,
                        badge: nil,
                        badgeColor: .clear
                    )
                }
                
                // Games & Challenges
                NavigationLink(destination: GamesView()) {
                    EnhancedShopCategoryCard(
                        title: "GAMES & CHALLENGES",
                        subtitle: "Closest to Pin • Long Drive • Skills challenges",
                        icon: "gamecontroller.fill",
                        color: .blue,
                        badge: "New",
                        badgeColor: .blue
                    )
                }
                
                // Social & Group Features - Bill Splitting Integration
                socialGroupSection
                
                // Instruction & Lessons
                NavigationLink(destination: InstructionView(membershipType: membershipType)) {
                    EnhancedShopCategoryCard(
                        title: "INSTRUCTION & LESSONS",
                        subtitle: "Private lessons • Group clinics • Swing analysis",
                        icon: "person.fill.checkmark",
                        color: .indigo,
                        badge: nil,
                        badgeColor: .clear
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Social & Group Section with Bill Splitting
    private var socialGroupSection: some View {
        VStack(spacing: 8) {
            Button(action: { showBillSplit = true }) {
                EnhancedShopCategoryCard(
                    title: "SOCIAL & GROUP",
                    subtitle: "Bill splitting • Group bookings • Share orders • Social challenges",
                    icon: "person.2.fill",
                    color: .purple,
                    badge: "Split Bill",
                    badgeColor: .purple
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Sub-options for Social features
            HStack(spacing: 12) {
                SocialSubActionCard(
                    title: "Split Current Bill",
                    icon: "divide.circle",
                    color: .purple
                ) {
                    showBillSplit = true
                }
                
                SocialSubActionCard(
                    title: "Group Booking",
                    icon: "person.3.fill",
                    color: .blue
                ) {
                    showGroupBooking = true
                }
                
                SocialSubActionCard(
                    title: "Share Order",
                    icon: "square.and.arrow.up",
                    color: .green
                ) {
                    // Share current cart
                }
            }
        }
    }
    
    private func mockCustomerTab() -> CustomerTab {
        return CustomerTab(
            id: UUID(),
            memberName: sessionManager.currentSession?.customerName ?? "John Smith",
            memberTier: sessionManager.currentSession?.membershipTier ?? .cascade,
            bayName: sessionManager.currentBayName ?? "Palmer - Tacoma",
            location: sessionManager.currentLocation ?? .tacoma,
            openedAt: Date().addingTimeInterval(-1800),
            items: [
                TabItem(id: UUID(), name: "Arnold Palmer", price: 3.00, quantity: 2, category: .beverage),
                TabItem(id: UUID(), name: "Club Burger", price: 14.00, quantity: 1, category: .food),
                TabItem(id: UUID(), name: "Bay Time", price: 45.00, quantity: 1, category: .rental)
            ]
        )
    }
}
// MARK: - Enhanced Shop UI Components

// Quick Action Card for session-based actions
struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.15))
                    .cornerRadius(12)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 80)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Enhanced Category Card with badges
struct EnhancedShopCategoryCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let badge: String?
    let badgeColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(color.opacity(0.1))
                .cornerRadius(16)
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if let badge = badge {
                        Text(badge)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(badgeColor)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

// Social Sub-Action Card
struct SocialSubActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.1))
                    .cornerRadius(8)
                
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Enhanced Views are implemented below with full USchedule integration

struct GamesView: View {
    var body: some View {
        VStack {
            Text("Games & Challenges")
                .font(.title)
                .padding()
            Text("Simulator Games & Skills")
                .foregroundColor(.secondary)
            Spacer()
        }
        .navigationTitle("Games")
    }
}

struct InstructionView: View {
    let membershipType: String
    
    var body: some View {
        VStack {
            Text("Instruction & Lessons")
                .font(.title)
                .padding()
            Text("Professional Golf Instruction")
                .foregroundColor(.secondary)
            Spacer()
        }
        .navigationTitle("Instruction")
    }
}

struct CartView: View {
    let membershipType: String
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Shopping Cart")
                    .font(.title)
                    .padding()
                Text("Member Type: \(membershipType)")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .navigationTitle("Cart")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct GroupBookingView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Group Booking")
                    .font(.title)
                    .padding()
                Text("Create group sessions and events")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .navigationTitle("Group Booking")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SimpleBillSplitView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Bill Splitting")
                    .font(.title)
                    .padding()
                Text("Split your tab with friends")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .navigationTitle("Split Bill")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Enhanced Shop Integration (Uses existing CustomerTab models from TabManagement.swift)

// MARK: - Context-Aware Bay Information
struct YourBaySection: View {
    let membershipType: String
    @ObservedObject var sessionManager: CustomerSessionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("YOUR BAY")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Context-aware bay card based on session manager state
            BayStatusHeader(sessionManager: sessionManager, showDetails: true, showQuickActions: true)
                .padding(.horizontal, 20)
        }
    }
}


// MARK: - Active Bay Card (Currently Playing)
struct ActiveBayCard: View {
    let membershipType: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Current Bay Status
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(.green)
                            .frame(width: 12, height: 12)
                        
                        Text("CURRENTLY PLAYING")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    Text("BAY: Mickelson - Tacoma")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("42 minutes remaining")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$45")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(membershipType == "member" ? "Member Rate" : "Guest Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Quick Actions
            HStack(spacing: 12) {
                BayActionButton(title: "EXTEND TIME", icon: "plus.circle", color: .blue) {
                    // Extend booking action
                }
                
                BayActionButton(title: "ORDER F&B", icon: "fork.knife", color: .orange) {
                    // Quick order action
                }
                
                BayActionButton(title: "GET HELP", icon: "questionmark.circle", color: .gray) {
                    // Support action
                }
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green.opacity(0.3), lineWidth: 2)
        )
    }
}

// MARK: - Upcoming Bay Card (Future Booking)
struct UpcomingBayCard: View {
    let membershipType: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Upcoming Booking Status
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(.orange)
                            .frame(width: 12, height: 12)
                        
                        Text("UPCOMING BOOKING")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    
                    Text("BAY: Palmer - Tacoma")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Starts in 25 minutes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("7:00 PM")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("60 minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Pre-Session Actions
            HStack(spacing: 12) {
                BayActionButton(title: "PRE-ORDER", icon: "cart", color: .orange) {
                    // Pre-order F&B
                }
                
                BayActionButton(title: "BAY DETAILS", icon: "info.circle", color: .blue) {
                    // Bay information
                }
                
                BayActionButton(title: "MODIFY", icon: "calendar", color: .gray) {
                    // Modify booking
                }
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 2)
        )
    }
}

// MARK: - Quick Book Card (Walk-in Customer)
struct QuickBookCard: View {
    let membershipType: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Walk-in Status
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 12, height: 12)
                        
                        Text("BOOK A BAY NOW")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Text("7 bays available")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Average wait: No wait")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(membershipType == "member" ? "45" : "55")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("per hour")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Quick Book Actions
            HStack(spacing: 12) {
                BayActionButton(title: "BOOK NOW", icon: "calendar.badge.plus", color: .blue) {
                    // Quick booking action
                }
                
                BayActionButton(title: "JOIN WAITLIST", icon: "clock", color: .orange) {
                    // Waitlist action
                }
                
                BayActionButton(title: "VIEW MENU", icon: "fork.knife", color: .green) {
                    // View menu while waiting
                }
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
        )
    }
}

// MARK: - Bay Action Button
struct BayActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Simulator Time Card (Pre-paid Time)
struct SimulatorTimeCard: View {
    let title: String
    let subtitle: String
    let price: Int
    let memberPrice: Int?
    let color: Color
    let description: String
    let icon: String
    let isPopular: Bool
    let action: () -> Void
    
    init(title: String, subtitle: String, price: Int, memberPrice: Int? = nil, color: Color, description: String, icon: String, isPopular: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.price = price
        self.memberPrice = memberPrice
        self.color = color
        self.description = description
        self.icon = icon
        self.isPopular = isPopular
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color)
                    .frame(width: 220, height: 140)
                    .overlay(
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: icon)
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    if let memberPrice = memberPrice {
                                        Text("$\(memberPrice)")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        Text("Member")
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.8))
                                    } else {
                                        Text("$\(price)")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        Text("Guest")
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(title)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(subtitle)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Add to Tab button
                            HStack {
                                Text("ADD TO TAB")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(color)
                                
                                Image(systemName: "plus.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(color)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.white)
                            .cornerRadius(20)
                        }
                        .padding(16)
                    )
                
                if isPopular {
                    Text("MOST POPULAR")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .cornerRadius(6)
                        .padding(12)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Shop Cart View
struct ShopCartView: View {
    @Binding var cartCount: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if cartCount == 0 {
                    VStack(spacing: 24) {
                        Image(systemName: "cart")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("Your cart is empty")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Add simulator sessions and other services to get started.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "tv.and.hifispeaker")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text("Simulator Sessions")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("\(cartCount) sessions added")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("Ready")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        VStack(spacing: 12) {
                            Button("Add to Tab") {
                                // Process order
                                cartCount = 0
                                dismiss()
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                            
                            Button("Clear Cart") {
                                cartCount = 0
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .navigationTitle("Your Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ShopCategoryCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - Menu View (Food & Beverage)
struct MenuView: View {
    let membershipType: String
    @Environment(\.dismiss) private var dismiss
    @State private var cartItems: [FoodBeverageItem] = []
    
    private let foodItems: [FoodBeverageItem] = [
        FoodBeverageItem(id: "arnold-palmer", name: "Arnold Palmer", category: "Beverages", price: 3.00, description: "Classic iced tea and lemonade blend"),
        FoodBeverageItem(id: "cold-brew-frap", name: "Cold Brew/Frappuccino", category: "Coffee", price: 4.00, description: "Cold coffee beverages"),
        FoodBeverageItem(id: "granola-bars", name: "Granola Bars", category: "Snacks", price: 2.00, description: "Healthy energy bars"),
        FoodBeverageItem(id: "poppi", name: "Poppi Soda", category: "Beverages", price: 2.00, description: "Prebiotic soda drinks")
    ]
    
    var memberDiscount: Double {
        membershipType == "member" ? 0.15 : 0.0
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("MENU")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        if membershipType == "member" {
                            Text("15% Member Discount Applied")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Food & Beverage Items
                    LazyVStack(spacing: 16) {
                        ForEach(foodItems.groupedByCategory(), id: \.key) { category, items in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(category.uppercased())
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                                
                                ForEach(items) { item in
                                    MenuItemCard(item: item, memberDiscount: memberDiscount) {
                                        cartItems.append(item)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cart (\(cartItems.count))") {
                        // Show cart
                    }
                    .disabled(cartItems.isEmpty)
                }
            }
        }
    }
}

// MARK: - Pro Shop View (Merchandise)
struct ProShopView: View {
    let membershipType: String
    @Environment(\.dismiss) private var dismiss
    @State private var cartItems: [MerchandiseItem] = []
    
    private let merchandise: [MerchandiseItem] = [
        MerchandiseItem(id: "evergreen-towel", name: "Evergreen Playkleen Towel", category: "Golf Accessories", price: 20.00, description: "Branded golf towel for club cleaning")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("PRO SHOP")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("Golf Equipment & Accessories")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Merchandise Items
                    LazyVStack(spacing: 16) {
                        ForEach(merchandise) { item in
                            MerchandiseItemCard(item: item) {
                                cartItems.append(item)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cart (\(cartItems.count))") {
                        // Show cart
                    }
                    .disabled(cartItems.isEmpty)
                }
            }
        }
    }
}

// MARK: - Lessons View (Instruction)
struct LessonsView: View {
    let membershipType: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedInstructor: String?
    
    private let instructors = [
        Instructor(name: "Leo Li", credentials: "PGA Professional", specialties: ["Private Lessons", "Group Instruction"]),
        Instructor(name: "Yongsik Yoon", credentials: "PGA Professional", specialties: ["Private Lessons", "Swing Analysis"])
    ]
    
    private let lessonServices: [LessonService] = [
        LessonService(
            id: "private-lesson",
            name: "Private Golf Lesson",
            duration: 60,
            description: "One-on-one professional golf instruction with certified PGA professionals",
            memberPrice: 85.00,
            guestPrice: 95.00,
            features: ["Certified PGA instruction", "Video swing analysis", "Personalized improvement plan", "TrackMan data analysis"]
        ),
        LessonService(
            id: "group-lesson",
            name: "Group Golf Lesson",
            duration: 90,
            description: "Small group golf instruction (2-4 people)",
            memberPrice: 50.00,
            guestPrice: 60.00,
            features: ["Professional group instruction", "Interactive learning environment", "Shared TrackMan analysis", "Group challenges"]
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("LESSONS")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Professional Golf Instruction")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Lesson Services
                    LazyVStack(spacing: 16) {
                        ForEach(lessonServices) { service in
                            LessonServiceCard(
                                service: service,
                                membershipType: membershipType
                            ) {
                                // Book lesson
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Instructors Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("OUR INSTRUCTORS")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        ForEach(instructors, id: \.name) { instructor in
                            InstructorCard(instructor: instructor)
                                .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Supporting Models and Views
struct FoodBeverageItem: Identifiable {
    let id: String
    let name: String
    let category: String
    let price: Double
    let description: String
}

struct MerchandiseItem: Identifiable {
    let id: String
    let name: String
    let category: String
    let price: Double
    let description: String
}

struct LessonService: Identifiable {
    let id: String
    let name: String
    let duration: Int
    let description: String
    let memberPrice: Double
    let guestPrice: Double
    let features: [String]
}

struct Instructor {
    let name: String
    let credentials: String
    let specialties: [String]
}

extension Array where Element == FoodBeverageItem {
    func groupedByCategory() -> [(key: String, value: [FoodBeverageItem])] {
        Dictionary(grouping: self) { $0.category }
            .sorted { $0.key < $1.key }
    }
}

struct MenuItemCard: View {
    let item: FoodBeverageItem
    let memberDiscount: Double
    let addToCart: () -> Void
    
    private var finalPrice: Double {
        item.price * (1 - memberDiscount)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    if memberDiscount > 0 {
                        Text("$\(item.price, specifier: "%.2f")")
                            .font(.caption)
                            .strikethrough()
                            .foregroundColor(.secondary)
                        
                        Text("$\(finalPrice, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    } else {
                        Text("$\(item.price, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                }
            }
            
            Spacer()
            
            Button(action: addToCart) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MerchandiseItemCard: View {
    let item: MerchandiseItem
    let addToCart: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Button(action: addToCart) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct LessonServiceCard: View {
    let service: LessonService
    let membershipType: String
    let bookLesson: () -> Void
    
    private var price: Double {
        membershipType == "member" ? service.memberPrice : service.guestPrice
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(service.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("\(service.duration) minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("$\(price, specifier: "%.0f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text(membershipType == "member" ? "Member Price" : "Guest Price")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(service.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(service.features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Text(feature)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Button(action: bookLesson) {
                Text("BOOK LESSON")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct InstructorCard: View {
    let instructor: Instructor
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.green.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(instructor.name)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(instructor.credentials)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(instructor.specialties.joined(separator: " • "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Account Tab
struct AccountTabView: View {
    @ObservedObject var sessionManager: CustomerSessionManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Current Bay Status
                    if sessionManager.isSessionActive || sessionManager.currentSession != nil {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("CURRENT SESSION")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                BayStatusBadge(sessionManager: sessionManager)
                            }
                            
                            BayStatusHeader(sessionManager: sessionManager, showDetails: true, showQuickActions: false)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Profile Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                            )
                        
                        Text("Welcome, Guest")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Sign in to access member benefits")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Quick Session Actions
                    if sessionManager.currentSession != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("QUICK ACTIONS")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                if sessionManager.isSessionActive {
                                    AccountQuickActionButton(title: "End Session", icon: "stop.circle", color: .red) {
                                        sessionManager.endSession()
                                    }
                                    
                                    AccountQuickActionButton(title: "Extend Time", icon: "plus.circle", color: .blue) {
                                        sessionManager.extendSession(additionalTime: 1800)
                                    }
                                } else if sessionManager.userBookingState == .upcomingBooking {
                                    AccountQuickActionButton(title: "Check In", icon: "checkmark.circle", color: .green) {
                                        // Would start the session
                                        print("Check in action")
                                    }
                                    
                                    AccountQuickActionButton(title: "Cancel", icon: "xmark.circle", color: .red) {
                                        sessionManager.clearSession()
                                    }
                                }
                                
                                AccountQuickActionButton(title: "New Booking", icon: "calendar.badge.plus", color: .blue) {
                                    // Navigate to booking
                                    print("New booking action")
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Account Action Buttons
                    VStack(spacing: 12) {
                        AccountActionButton(title: "Sign In", subtitle: "Access your member account", icon: "person.circle")
                        AccountActionButton(title: "Become a Member", subtitle: "Join Evergreen Golf Club", icon: "star.circle")
                        AccountActionButton(title: "Settings", subtitle: "App preferences", icon: "gearshape")
                        AccountActionButton(title: "Help & Support", subtitle: "Get assistance", icon: "questionmark.circle")
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Activity Tab Components
struct CurrentSessionStatsView: View {
    let session: CustomerSession
    @ObservedObject var sessionManager: CustomerSessionManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("CURRENT SESSION STATS")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                StatCard(title: "Time Remaining", value: sessionManager.sessionTimeRemainingText ?? "N/A", icon: "clock", color: .green)
                StatCard(title: "Bay", value: session.bayName.components(separatedBy: " - ").first ?? "Unknown", icon: "location", color: .blue)
                StatCard(title: "Session Type", value: session.sessionType.displayName, icon: session.sessionType.systemImage, color: .orange)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct SessionHistoryCard: View {
    let session: CustomerSession
    
    var body: some View {
        HStack(spacing: 16) {
            // Session Type Icon
            RoundedRectangle(cornerRadius: 8)
                .fill(session.statusColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: session.sessionType.systemImage)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(session.statusColor)
                )
            
            // Session Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.bayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(session.status.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(session.statusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(session.statusColor.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Text(session.timeSlotText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let actualDuration = session.actualDuration {
                    Text("Duration: \(Int(actualDuration/60)) minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Account Tab Components
struct AccountQuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AccountActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Evergreen Experience View
struct EvergreenExperienceView: View {
    let bayNumber: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Title Section
                    VStack(spacing: 12) {
                        HStack {
                            Rectangle()
                                .fill(.blue)
                                .frame(width: 120, height: 40)
                                .overlay(
                                    Text("EVERGREEN")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text("EXPERIENCE")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    
                    // Features
                    VStack(spacing: 24) {
                        EvergreenFeatureRow(
                            icon: "snow",
                            title: "Climate Controlled Comfort",
                            description: "Our indoor bays feature year-round climate control with heating and cooling systems to keep you comfortable in any season."
                        )
                        
                        EvergreenFeatureRow(
                            icon: "golf.tee",
                            title: "Premium Golf Equipment",
                            description: "Every bay includes premium golf clubs for all skill levels. Bring your own or use our professional-grade equipment."
                        )
                        
                        EvergreenFeatureRow(
                            icon: "infinity",
                            title: "Unlimited Practice Time",
                            description: "Take as many swings as you want during your session. Perfect your technique with unlimited balls and instant feedback."
                        )
                        
                        EvergreenFeatureRow(
                            icon: "figure.roll",
                            title: "Accessible for Everyone",
                            description: "All our bays are fully accessible with wheelchair-friendly entrances and adjustable equipment for every golfer."
                        )
                    }
                    .padding(.horizontal)
                    
                    // Continue Button
                    Button(action: {
                        // Navigate to booking details
                    }) {
                        Text("CONTINUE TO BAY \(bayNumber)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(.blue)
                            .cornerRadius(28)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct EvergreenFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

// MARK: - Bay Status Header Component
struct BayStatusHeader: View {
    @ObservedObject var sessionManager: CustomerSessionManager
    let showDetails: Bool
    let showQuickActions: Bool
    
    init(sessionManager: CustomerSessionManager, showDetails: Bool = true, showQuickActions: Bool = false) {
        self.sessionManager = sessionManager
        self.showDetails = showDetails
        self.showQuickActions = showQuickActions
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if let session = sessionManager.currentSession {
                switch session.status {
                case .active:
                    ActiveSessionHeader(session: session, sessionManager: sessionManager, showDetails: showDetails, showQuickActions: showQuickActions)
                case .scheduled:
                    UpcomingSessionHeader(session: session, sessionManager: sessionManager, showDetails: showDetails, showQuickActions: showQuickActions)
                default:
                    WalkInHeader(sessionManager: sessionManager, showDetails: showDetails)
                }
            } else {
                WalkInHeader(sessionManager: sessionManager, showDetails: showDetails)
            }
        }
    }
}

// MARK: - Active Session Header
struct ActiveSessionHeader: View {
    let session: CustomerSession
    @ObservedObject var sessionManager: CustomerSessionManager
    let showDetails: Bool
    let showQuickActions: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Indicator
            VStack(spacing: 4) {
                Circle()
                    .fill(.green)
                    .frame(width: 12, height: 12)
                
                if showDetails {
                    Text("ACTIVE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            
            // Bay Information
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.bayName)
                        .font(showDetails ? .headline : .subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if !showDetails {
                        Spacer()
                        
                        Text(sessionManager.sessionTimeRemainingText ?? "Active")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                if showDetails {
                    HStack {
                        Text(sessionManager.sessionTimeRemainingText ?? "Active")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(session.timeSlotText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if showDetails && !showQuickActions {
                Spacer()
                
                // Price/Member Info
                VStack(alignment: .trailing, spacing: 2) {
                    Text("$45/hr")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    if let tier = session.membershipTier {
                        Text("\(tier.displayName) Rate")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, showDetails ? 16 : 12)
        .padding(.vertical, showDetails ? 12 : 8)
        .background(Color.green.opacity(0.1))
        .cornerRadius(showDetails ? 12 : 8)
        .overlay(
            RoundedRectangle(cornerRadius: showDetails ? 12 : 8)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        
        // Quick Actions Row
        if showQuickActions && showDetails {
            SessionQuickActionsRow(session: session, sessionManager: sessionManager)
        }
    }
}

// MARK: - Upcoming Session Header
struct UpcomingSessionHeader: View {
    let session: CustomerSession
    @ObservedObject var sessionManager: CustomerSessionManager
    let showDetails: Bool
    let showQuickActions: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Indicator
            VStack(spacing: 4) {
                Circle()
                    .fill(.orange)
                    .frame(width: 12, height: 12)
                
                if showDetails {
                    Text("UPCOMING")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
            
            // Bay Information
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.bayName)
                        .font(showDetails ? .headline : .subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if !showDetails {
                        Spacer()
                        
                        Text(sessionManager.upcomingSessionTimeText ?? "Upcoming")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                if showDetails {
                    HStack {
                        Text(sessionManager.upcomingSessionTimeText ?? "Upcoming")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(session.timeSlotText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if showDetails && !showQuickActions {
                Spacer()
                
                // Start Time
                VStack(alignment: .trailing, spacing: 2) {
                    Text(session.formattedStartTime)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("\(Int(session.duration/60)) min")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, showDetails ? 16 : 12)
        .padding(.vertical, showDetails ? 12 : 8)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(showDetails ? 12 : 8)
        .overlay(
            RoundedRectangle(cornerRadius: showDetails ? 12 : 8)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        
        // Quick Actions Row
        if showQuickActions && showDetails {
            SessionQuickActionsRow(session: session, sessionManager: sessionManager)
        }
    }
}

// MARK: - Walk-in Header
struct WalkInHeader: View {
    @ObservedObject var sessionManager: CustomerSessionManager
    let showDetails: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Indicator
            VStack(spacing: 4) {
                Circle()
                    .fill(.blue)
                    .frame(width: 12, height: 12)
                
                if showDetails {
                    Text("AVAILABLE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            
            // Availability Information
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Book a Bay")
                        .font(showDetails ? .headline : .subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if !showDetails {
                        Spacer()
                        
                        Text("Available")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                if showDetails {
                    let availableCount = sessionManager.getAvailableBays(for: .tacoma).count
                    
                    HStack {
                        Text("\(availableCount) bays available")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("No wait time")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            if showDetails {
                Spacer()
                
                // Pricing
                VStack(alignment: .trailing, spacing: 2) {
                    Text("$45/hr")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Member Rate")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, showDetails ? 16 : 12)
        .padding(.vertical, showDetails ? 12 : 8)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(showDetails ? 12 : 8)
        .overlay(
            RoundedRectangle(cornerRadius: showDetails ? 12 : 8)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Session Quick Actions Row
struct SessionQuickActionsRow: View {
    let session: CustomerSession
    @ObservedObject var sessionManager: CustomerSessionManager
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(session.quickActionItems) { actionItem in
                SessionQuickActionButton(
                    title: actionItem.title,
                    icon: actionItem.icon,
                    color: actionItem.color
                ) {
                    handleQuickAction(actionItem.action)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func handleQuickAction(_ action: SessionActionType) {
        switch action {
        case .extendTime:
            sessionManager.extendSession(additionalTime: 1800) // 30 minutes
        case .orderFood:
            print("🍔 Opening food ordering")
        case .getHelp:
            print("🆘 Opening help")
        case .preOrder:
            print("🛒 Opening pre-order")
        case .viewDetails:
            print("ℹ️ Showing bay details")
        case .modify:
            print("✏️ Opening booking modification")
        default:
            print("🔧 Action not implemented: \(action)")
        }
    }
}

// MARK: - Session Quick Action Button
struct SessionQuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(color.opacity(0.1))
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Compact Bay Status Badge
struct BayStatusBadge: View {
    @ObservedObject var sessionManager: CustomerSessionManager
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(badgeColor)
                .frame(width: 8, height: 8)
            
            Text(badgeText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(badgeColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeColor.opacity(0.1))
        .cornerRadius(6)
    }
    
    private var badgeColor: Color {
        guard let session = sessionManager.currentSession else { return .blue }
        return session.statusColor
    }
    
    private var badgeText: String {
        guard let session = sessionManager.currentSession else { return "Available" }
        
        switch session.status {
        case .active:
            return sessionManager.sessionTimeRemainingText ?? "Active"
        case .scheduled:
            return sessionManager.upcomingSessionTimeText ?? "Upcoming"
        default:
            return "Available"
        }
    }
}

#Preview {
    ContentView()
}