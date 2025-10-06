import SwiftUI
import UIKit
import Foundation




// MARK: - Simulator Models
enum SimulatorStatus {
    case available
    case booked(until: Date)
    case maintenance
    case limited
    
    var color: Color {
        switch self {
        case .available: return .green
        case .booked: return .red
        case .maintenance: return .gray
        case .limited: return .orange
        }
    }
    
    var displayText: String {
        switch self {
        case .available: return "Available"
        case .booked(let until):
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Until \(formatter.string(from: until))"
        case .maintenance: return "Maintenance"
        case .limited: return "Limited"
        }
    }
    
    var isBooked: Bool {
        switch self {
        case .booked: return true
        default: return false
        }
    }
}

struct Simulator: Identifiable {
    let id = UUID()
    let name: String
    let shortName: String
    let status: SimulatorStatus
    let memberPrice: Double
    let guestPrice: Double
    let features: [String]
    
    var isBookable: Bool {
        switch status {
        case .available, .limited: return true
        case .booked, .maintenance: return false
        }
    }
    
    static func mockSimulators() -> [Simulator] {
        var simulators: [Simulator] = []
        
        // Tacoma Facility - 13 Simulators (Bays 1-13)
        let tacomaSimulators = [
            ("Woods", true), ("Irons", false), ("Driver", true), ("Wedges", false), ("Putter", false),
            ("Fairway", true), ("Rough", false), ("Bunker", false), ("Green", true), ("Tee", false),
            ("Approach", false), ("Chip", false), ("Pro", true)
        ]
        
        for (index, (name, isPremium)) in tacomaSimulators.enumerated() {
            let bayNumber = index + 1
            let status = generateRandomStatus()
            let features = generateTacomaFeatures(isPremium: isPremium)
            let (memberPrice, guestPrice) = generateTacomaPricing(isPremium: isPremium)
            
            simulators.append(Simulator(
                name: "\(name) - Bay \(bayNumber) (Tacoma)",
                shortName: "\(name) #\(bayNumber)",
                status: status,
                memberPrice: memberPrice,
                guestPrice: guestPrice,
                features: features
            ))
        }
        
        // Redmond Facility - 8 Simulators (Premium location)
        let redmondSimulators = ["Palmer", "Nicklaus", "Tiger", "Rory", "Spieth", "Koepka", "DJ", "Rahm"]
        
        for (index, name) in redmondSimulators.enumerated() {
            let bayNumber = index + 1
            let status = generateRandomStatus()
            let features = generateRedmondFeatures() // All premium
            let (memberPrice, guestPrice) = generateRedmondPricing()
            
            simulators.append(Simulator(
                name: "\(name) Suite - Bay \(bayNumber) (Redmond)",
                shortName: "\(name) #\(bayNumber)",
                status: status,
                memberPrice: memberPrice,
                guestPrice: guestPrice,
                features: features
            ))
        }
        
        return simulators
    }
    
    private static func generateRandomStatus() -> SimulatorStatus {
        let random = Int.random(in: 1...10)
        switch random {
        case 1...6: return .available
        case 7...8: return .booked(until: Calendar.current.date(byAdding: .hour, value: Int.random(in: 1...3), to: Date()) ?? Date())
        case 9: return .limited
        case 10: return .maintenance
        default: return .available
        }
    }
    
    private static func generateTacomaFeatures(isPremium: Bool) -> [String] {
        var features = ["TrackMan"]
        if isPremium {
            features.append(contentsOf: ["Premium", "HD Display", "Climate Control"])
        } else {
            features.append("Standard")
        }
        return features
    }
    
    private static func generateRedmondFeatures() -> [String] {
        return ["TrackMan", "Premium", "HD Display", "Climate Control", "Surround Sound", "Comfort Seating"]
    }
    
    private static func generateTacomaPricing(isPremium: Bool) -> (Double, Double) {
        if isPremium {
            return (34, 40) // Premium: $34 member, $40 guest
        } else {
            return (26, 31) // Standard: $26 member, $31 guest  
        }
    }
    
    private static func generateRedmondPricing() -> (Double, Double) {
        return (42, 50) // Redmond premium: $42 member, $50 guest
    }
}

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

// MARK: - USchedule Service Types
enum ServiceCategory: String, CaseIterable, Identifiable {
    case simulator = "simulator"
    case lessons = "lessons" 
    case junior = "junior"
    case elite = "elite"
    case tours = "tours"
    case conference = "conference"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .simulator: return "Simulator Sessions"
        case .lessons: return "Private Instruction"
        case .junior: return "Junior Programs"
        case .elite: return "Elite Training"
        case .tours: return "Facility Tours"
        case .conference: return "Conference Rooms"
        }
    }
    
    var icon: String {
        switch self {
        case .simulator: return "tv.and.hifispeaker"
        case .lessons: return "person.fill.checkmark"
        case .junior: return "figure.and.child.holdinghands"
        case .elite: return "star.fill"
        case .tours: return "building.2"
        case .conference: return "person.3.fill"
        }
    }
    
    var description: String {
        switch self {
        case .simulator: return "Golf simulation and practice sessions"
        case .lessons: return "One-on-one professional instruction"
        case .junior: return "Youth programs and group lessons"
        case .elite: return "Advanced player development"
        case .tours: return "Guided facility demonstrations"
        case .conference: return "Private meeting spaces"
        }
    }
}

struct UScheduleService: Identifiable {
    let id = UUID()
    let name: String
    let category: ServiceCategory
    let duration: Int // minutes
    let memberPrice: Double
    let guestPrice: Double
    let maxPlayers: Int
    let requiresInstructor: Bool
    let description: String
    
    var memberSavings: Double {
        guestPrice - memberPrice
    }
}

extension UScheduleService {
    static func allServices() -> [UScheduleService] {
        [
            // Simulator Services
            UScheduleService(
                name: "Cascade Simulator",
                category: .simulator,
                duration: 60,
                memberPrice: 30.60,
                guestPrice: 36.00,
                maxPlayers: 6,
                requiresInstructor: false,
                description: "Entry-level simulator with basic analytics"
            ),
            UScheduleService(
                name: "Pike Simulator", 
                category: .simulator,
                duration: 60,
                memberPrice: 40.80,
                guestPrice: 48.00,
                maxPlayers: 6,
                requiresInstructor: false,
                description: "Mid-tier simulator with advanced TrackMan data"
            ),
            UScheduleService(
                name: "Rainier Simulator",
                category: .simulator,
                duration: 60,
                memberPrice: 51.00,
                guestPrice: 60.00,
                maxPlayers: 6,
                requiresInstructor: false,
                description: "Premium simulator with full analytics suite"
            ),
            
            // Private Instruction
            UScheduleService(
                name: "Private Lesson - 30 Minutes",
                category: .lessons,
                duration: 30,
                memberPrice: 63.75,
                guestPrice: 75.00,
                maxPlayers: 1,
                requiresInstructor: true,
                description: "One-on-one instruction with PGA professional"
            ),
            UScheduleService(
                name: "Private Lesson - 60 Minutes",
                category: .lessons,
                duration: 60,
                memberPrice: 106.25,
                guestPrice: 125.00,
                maxPlayers: 1,
                requiresInstructor: true,
                description: "Extended private session with detailed analysis"
            ),
            UScheduleService(
                name: "Skills Assessment",
                category: .lessons,
                duration: 30,
                memberPrice: 55.25,
                guestPrice: 65.00,
                maxPlayers: 1,
                requiresInstructor: true,
                description: "Comprehensive evaluation with lesson plan"
            ),
            
            // Junior Programs
            UScheduleService(
                name: "Junior Lesson - 30 Minutes",
                category: .junior,
                duration: 30,
                memberPrice: 42.50,
                guestPrice: 50.00,
                maxPlayers: 1,
                requiresInstructor: true,
                description: "Age-appropriate instruction for players under 18"
            ),
            UScheduleService(
                name: "Junior Group Lesson",
                category: .junior,
                duration: 45,
                memberPrice: 29.75,
                guestPrice: 35.00,
                maxPlayers: 4,
                requiresInstructor: true,
                description: "Small group instruction for young golfers"
            ),
            
            // Elite Programs
            UScheduleService(
                name: "Elite Performance Session",
                category: .elite,
                duration: 120,
                memberPrice: 170.00,
                guestPrice: 200.00,
                maxPlayers: 1,
                requiresInstructor: true,
                description: "Advanced player development with analysis"
            ),
            
            // Tours
            UScheduleService(
                name: "Facility Tour",
                category: .tours,
                duration: 30,
                memberPrice: 0.00,
                guestPrice: 0.00,
                maxPlayers: 8,
                requiresInstructor: false,
                description: "Guided tour and equipment demonstration"
            ),
            
            // Conference
            UScheduleService(
                name: "Conference Room Rental",
                category: .conference,
                duration: 120,
                memberPrice: 63.75,
                guestPrice: 75.00,
                maxPlayers: 12,
                requiresInstructor: false,
                description: "Private meeting space rental"
            )
        ]
    }
}

// MARK: - Book Tab
struct BookTabView: View {
    @ObservedObject var sessionManager: CustomerSessionManager
    @State private var selectedSimulator: Simulator?
    @State private var showingSimulatorBooking = false
    @State private var simulators: [Simulator] = []
    
    // Enhanced USchedule Service Selection
    @State private var selectedServiceCategory: ServiceCategory = .simulator
    @State private var selectedService: UScheduleService?
    @State private var playerCount: Int = 1
    @State private var showingServiceDetails = false
    
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
                    
                    // Enhanced Facility Info with Service Selection
                    VStack(alignment: .leading, spacing: 16) {
                        // Facility Header
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
                        
                        // USchedule Service Category Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("🎯 Choose Your Experience")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            // Service Category Buttons in 2x3 Grid
                            VStack(spacing: 6) {
                                HStack(spacing: 8) {
                                    // Simulator Sessions
                                    Button(action: { selectedServiceCategory = .simulator }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "tv.and.hifispeaker")
                                                .font(.caption2)
                                            Text("Simulators")
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(selectedServiceCategory == .simulator ? .white : .blue)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(selectedServiceCategory == .simulator ? Color.blue : Color.blue.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                    
                                    // Private Instruction
                                    Button(action: { selectedServiceCategory = .lessons }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "person.fill.checkmark")
                                                .font(.caption2)
                                            Text("Lessons")
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(selectedServiceCategory == .lessons ? .white : .green)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(selectedServiceCategory == .lessons ? Color.green : Color.green.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                    
                                    // Junior Programs
                                    Button(action: { selectedServiceCategory = .junior }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "figure.and.child.holdinghands")
                                                .font(.caption2)
                                            Text("Junior")
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(selectedServiceCategory == .junior ? .white : .orange)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(selectedServiceCategory == .junior ? Color.orange : Color.orange.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                                
                                HStack(spacing: 8) {
                                    // Elite Training
                                    Button(action: { selectedServiceCategory = .elite }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "star.fill")
                                                .font(.caption2)
                                            Text("Elite")
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(selectedServiceCategory == .elite ? .white : .purple)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(selectedServiceCategory == .elite ? Color.purple : Color.purple.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                    
                                    // Facility Tours
                                    Button(action: { selectedServiceCategory = .tours }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "building.2")
                                                .font(.caption2)
                                            Text("Tours")
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(selectedServiceCategory == .tours ? .white : .teal)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(selectedServiceCategory == .tours ? Color.teal : Color.teal.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                    
                                    // Conference Rooms
                                    Button(action: { selectedServiceCategory = .conference }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "person.3.fill")
                                                .font(.caption2)
                                            Text("Conference")
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(selectedServiceCategory == .conference ? .white : .gray)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(selectedServiceCategory == .conference ? Color.gray : Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    
                    // Machine-Focused Simulator Grid
                    VStack(spacing: 20) {
                        // Availability summary
                        HStack {
                            Text("Choose Your Bay")
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Text("\(availableSimulatorCount) Open")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        
                        // Wide Simulator Cards Stack
                        LazyVStack(spacing: 16) {
                            ForEach(simulators) { simulator in
                                WideSimulatorCardView(
                                    simulator: simulator,
                                    userMembershipTier: userMembershipTier,
                                    onTap: {
                                        selectedSimulator = simulator
                                        showingSimulatorBooking = true
                                    }
                                )
                                .frame(height: 120)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadSimulators()
            }
            .sheet(isPresented: $showingSimulatorBooking) {
                if let simulator = selectedSimulator {
                    SimulatorBookingSheet(
                        simulator: simulator,
                        userMembershipTier: userMembershipTier,
                        sessionManager: sessionManager
                    )
                }
            }
        }
    }
    
    // Dynamic user display name
    private var userDisplayName: String {
        if let session = sessionManager.currentSession {
            return session.customerName
        }
        return "Guest User" // Default name - in real app would get from user input
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
    
    // User membership tier
    private var userMembershipTier: MembershipTier? {
        sessionManager.currentSession?.membershipTier
    }
    
    // Available simulator count
    private var availableSimulatorCount: Int {
        simulators.filter { $0.isBookable }.count
    }
    
    // Load simulator data
    private func loadSimulators() {
        // In real app, this would fetch from API
        simulators = Simulator.mockSimulators()
    }
}

// MARK: - Simulator Card View
struct SimulatorCardView: View {
    let simulator: Simulator
    let userMembershipTier: MembershipTier?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Header with status
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(simulator.shortName)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(simulator.status.displayText)
                            .font(.caption)
                            .foregroundColor(simulator.status.color)
                    }
                    
                    Spacer()
                    
                    Circle()
                        .fill(simulator.status.color)
                        .frame(width: 12, height: 12)
                }
                
                // Pricing
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        if let _ = userMembershipTier {
                            Text("$\(Int(simulator.memberPrice))/hr")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Text("Member Rate")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("$\(Int(simulator.guestPrice))/hr")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Guest Rate")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if let _ = userMembershipTier {
                        Text("MEMBER")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .cornerRadius(4)
                    }
                }
                
                // Features
                HStack {
                    ForEach(simulator.features.prefix(2), id: \.self) { feature in
                        Text(feature)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray6))
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    if simulator.isBookable {
                        Text("Tap to book")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(simulator.isBookable ? Color(.systemBackground) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(simulator.status.color.opacity(0.3), lineWidth: simulator.isBookable ? 2 : 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!simulator.isBookable)
        .opacity(simulator.isBookable ? 1.0 : 0.7)
    }
}

// MARK: - iOS Standard Simulator Card View
struct WideSimulatorCardView: View {
    let simulator: Simulator
    let userMembershipTier: MembershipTier?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Top Section: Status & Bay Name
                HStack(spacing: 12) {
                    Circle()
                        .fill(simulator.status.color)
                        .frame(width: 16, height: 16)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(simplifiedBayName)
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundColor(.primary)
                        
                        Text(simplifiedStatus)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(simulator.status.color)
                    }
                    
                    Spacer()
                }
                
                // Bottom Section: Pricing & Action
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(simplifiedPricing)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        if !simulator.isBookable && simulator.status.isBooked {
                            Text(nextAvailableText)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    actionButton
                }
            }
            .padding(20)
            .background(cardBackgroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(simulator.status.color.opacity(0.15), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!simulator.isBookable && !isLimitedStatus())
    }
    
    // MARK: - Computed Properties for Simplified Language
    private var simplifiedBayName: String {
        // Convert "Woods #1" to "Bay 1 - Woods"
        let parts = simulator.shortName.split(separator: "#")
        if parts.count == 2 {
            let name = String(parts[0]).trimmingCharacters(in: .whitespaces)
            let number = String(parts[1])
            return "Bay \(number) - \(name)"
        }
        return simulator.shortName
    }
    
    private var simplifiedStatus: String {
        switch simulator.status {
        case .available:
            return "Open"
        case .limited:
            return "Almost Full"
        case .booked(let until):
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Busy Until \(formatter.string(from: until))"
        case .maintenance:
            return "Closed for Setup"
        }
    }
    
    private var simplifiedPricing: String {
        let price = userMembershipTier != nil ? Int(simulator.memberPrice) : Int(simulator.guestPrice)
        return "$\(price)/hour"
    }
    
    private var nextAvailableText: String {
        if case .booked(let until) = simulator.status {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Next: \(formatter.string(from: until))"
        }
        return ""
    }
    
    private var actionButton: some View {
        Group {
            if simulator.isBookable {
                Text(getBookingButtonText())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(12)
            } else {
                Text(getUnavailableButtonText())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.gray)
                    .cornerRadius(12)
            }
        }
        .frame(minWidth: 80, minHeight: 44) // iOS minimum touch target
    }
    
    private var cardBackgroundColor: Color {
        if simulator.isBookable {
            return Color(.systemBackground)
        } else {
            return Color(.systemGray6)
        }
    }
    
    private func isLimitedStatus() -> Bool {
        switch simulator.status {
        case .limited:
            return true
        default:
            return false
        }
    }
    
    private func getBookingButtonText() -> String {
        switch simulator.status {
        case .limited:
            return "Join"
        default:
            return "Book Now"
        }
    }
    
    private func getUnavailableButtonText() -> String {
        switch simulator.status {
        case .maintenance:
            return "Closed"
        default:
            return "Wait List"
        }
    }
}

// MARK: - Simulator Booking Sheet
struct SimulatorBookingSheet: View {
    let simulator: Simulator
    let userMembershipTier: MembershipTier?
    @ObservedObject var sessionManager: CustomerSessionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTimeSlot: Date?
    @State private var duration: Int = 60 // minutes
    @State private var playerCount: Int = 1
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Simulator details
                    simulatorHeader
                    
                    // Time slot selection
                    timeSlotSection
                    
                    // Duration and party size
                    bookingOptions
                    
                    // Pricing breakdown
                    pricingBreakdown
                    
                    // Book button
                    bookButton
                }
                .padding()
            }
            .navigationTitle("Book \(simulator.shortName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private var simulatorHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(simulator.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 8) {
                        ForEach(Array(simulator.features.prefix(3)), id: \.self) { feature in
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle")
                                    .font(.caption)
                                Text(feature)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray6))
                            .cornerRadius(6)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let _ = userMembershipTier {
                        Text("$\(Int(simulator.memberPrice))/hr")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Member Rate")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("$\(Int(simulator.guestPrice))/hr")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Guest Rate")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var timeSlotSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Time")
                .font(.headline)
                .fontWeight(.bold)
            
            let timeSlots = generateTimeSlots()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(timeSlots, id: \.self) { timeSlot in
                    Button(action: {
                        selectedTimeSlot = timeSlot
                    }) {
                        Text(timeSlot, style: .time)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedTimeSlot == timeSlot ? .white : .primary)
                            .frame(height: 40)
                            .frame(maxWidth: .infinity)
                            .background(selectedTimeSlot == timeSlot ? Color.blue : Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var bookingOptions: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Duration")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Picker("Duration", selection: $duration) {
                    Text("30 min").tag(30)
                    Text("60 min").tag(60)
                    Text("90 min").tag(90)
                    Text("120 min").tag(120)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
            
            HStack {
                Text("Party Size")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: { if playerCount > 1 { playerCount -= 1 } }) {
                        Image(systemName: "minus.circle")
                            .font(.title2)
                            .foregroundColor(playerCount > 1 ? .blue : .gray)
                    }
                    .disabled(playerCount <= 1)
                    
                    Text("\(playerCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 30)
                    
                    Button(action: { if playerCount < 6 { playerCount += 1 } }) {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                            .foregroundColor(playerCount < 6 ? .blue : .gray)
                    }
                    .disabled(playerCount >= 6)
                }
            }
        }
    }
    
    private var pricingBreakdown: some View {
        VStack(spacing: 12) {
            Text("Pricing")
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 8) {
                let hourlyRate = userMembershipTier != nil ? simulator.memberPrice : simulator.guestPrice
                let subtotal = hourlyRate * Double(duration) / 60.0
                let tax = subtotal * 0.10
                let total = subtotal + tax
                
                HStack {
                    Text("\(simulator.shortName) - \(duration) min")
                    Spacer()
                    Text("$\(subtotal, specifier: "%.2f")")
                }
                
                if userMembershipTier != nil {
                    let guestRate = simulator.guestPrice * Double(duration) / 60.0
                    let savings = guestRate - subtotal
                    
                    HStack {
                        Text("Member Savings")
                        Spacer()
                        Text("-$\(savings, specifier: "%.2f")")
                            .foregroundColor(.green)
                    }
                }
                
                HStack {
                    Text("Tax (10%)")
                    Spacer()
                    Text("$\(tax, specifier: "%.2f")")
                }
                
                Divider()
                
                HStack {
                    Text("Total")
                        .fontWeight(.bold)
                    Spacer()
                    Text("$\(total, specifier: "%.2f")")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var bookButton: some View {
        Button(action: {
            // Handle booking
            dismiss()
        }) {
            Text("BOOK \(simulator.shortName.uppercased())")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(selectedTimeSlot != nil ? Color.blue : Color.gray)
                .cornerRadius(28)
        }
        .disabled(selectedTimeSlot == nil)
    }
    
    // Generate available time slots
    private func generateTimeSlots() -> [Date] {
        let calendar = Calendar.current
        var slots: [Date] = []
        
        // Generate slots from current time + 1 hour to 10 PM
        let startHour = max(Calendar.current.component(.hour, from: Date()) + 1, 9)
        let endHour = 22
        
        for hour in startHour...endHour {
            for minute in [0, 30] {
                if let slotTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) {
                    if slotTime > Date() {
                        slots.append(slotTime)
                    }
                }
            }
        }
        
        return slots
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
                VStack(spacing: 16) {
                    // Compact Shop Header (moved to top)
                    compactShopHeader
                    
                    // Live Bay Status Card - Prominent bay tracking
                    LiveBayCard(sessionManager: sessionManager)
                        .padding(.horizontal)
                    
                    // Prominent Split Bill Button
                    splitBillSection
                    
                    // Enhanced Categories (Simplified - No Games)
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
    
    // MARK: - Clean Shop Header (One line, member widget)
    private var compactShopHeader: some View {
        VStack(spacing: 12) {
            // Top row - Title and Cart
            HStack(alignment: .center) {
                // Single line title
                Text("EVERGREEN SHOP")
                    .font(.system(size: 20, weight: .black, design: .default))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Cart Button only
                Button(action: { showCart = true }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "cart.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        // Notification badge
                        if cartCount > 0 {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Text("\(cartCount)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 15, y: -15)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Member Widget (separate row, widget style)
            if membershipType == "member" {
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("Cascade Member")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("15% Off")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Prominent Split Bill Section
    private var splitBillSection: some View {
        Button(action: { showBillSplit = true }) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: "person.2.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.purple)
                    .cornerRadius(12)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("Split Bill")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Divide costs with your group")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Split options indicator
                VStack(alignment: .trailing, spacing: 2) {
                    Text("4 Ways")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    Text("Even • Amount • % • Items")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.purple.opacity(0.2), lineWidth: 2)
            )
            .shadow(color: .purple.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
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


// MARK: - Live Bay Card Components

// MARK: - Live Bay Card Component
// MARK: - Interactive Live Bay Card (Primary Focus Component)
struct LiveBayCard: View {
    @ObservedObject var sessionManager: CustomerSessionManager
    @State private var isPressed = false
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 0) {
            if let session = sessionManager.currentSession {
                // Interactive Active/Scheduled Session Card
                InteractiveActiveBayCard(session: session, sessionManager: sessionManager)
            } else {
                // Interactive Available Bay Card with prominent booking CTA
                InteractiveAvailableBayCard(sessionManager: sessionManager)
            }
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
            handleBayCardTap()
        }
    }
    
    private func handleBayCardTap() {
        if sessionManager.currentSession != nil {
            // Navigate to active session details
            print("🎯 Navigate to Session Details")
        } else {
            // Navigate to booking flow
            print("🎯 Navigate to Booking Flow")
        }
    }
}

// MARK: - Interactive Active Bay Card (Enhanced Design)
struct InteractiveActiveBayCard: View {
    let session: CustomerSession
    @ObservedObject var sessionManager: CustomerSessionManager
    @State private var isQuickActionsExpanded = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Compact header
            compactHeader
            
            // Session info
            sessionInfoSection
            
            // Expandable quick actions
            quickActionsWidget
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    session.statusColor.opacity(0.08),
                    Color.clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(session.statusColor.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: session.statusColor.opacity(0.15), radius: 4, x: 0, y: 2)
    }
    
    private var compactHeader: some View {
        HStack(spacing: 12) {
            // Simple static icon
            ZStack {
                Circle()
                    .fill(session.statusColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: session.sessionType.systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(session.statusColor)
            }
            
            // Bay info
            VStack(alignment: .leading, spacing: 2) {
                Text(session.bayName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(session.location.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Simple status badge
            compactStatusBadge
        }
    }
    
    private var compactStatusBadge: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // Status indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(session.statusColor)
                    .frame(width: 8, height: 8)
                
                Text(session.status.displayName.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(session.statusColor)
            }
            
            // Time info
            if session.status == .active {
                Text(sessionManager.sessionTimeRemainingText ?? "Active")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(session.statusColor)
            } else if session.status == .scheduled {
                Text(sessionManager.upcomingSessionTimeText ?? "Scheduled")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(session.statusColor)
            }
        }
    }
    
    private var sessionInfoSection: some View {
        HStack {
            // Session details - compact
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                        .foregroundColor(session.statusColor)
                    
                    Text(session.timeSlotText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(session.sessionType.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Compact member tier badge
            if let tier = session.membershipTier {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    
                    Text(tier.displayName)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(6)
            }
        }
    }
    
    private var quickActionsWidget: some View {
        VStack(spacing: 8) {
            Divider()
                .background(session.statusColor.opacity(0.2))
            
            // Clickable widget header
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isQuickActionsExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "bolt.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(session.statusColor)
                    
                    Text("Quick Actions")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isQuickActionsExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(session.statusColor)
                        .rotationEffect(.degrees(isQuickActionsExpanded ? 0 : 0))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(session.statusColor.opacity(0.1))
                .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expandable actions
            if isQuickActionsExpanded {
                expandedQuickActions
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
    }
    
    private var expandedQuickActions: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(session.quickActionItems.prefix(3)) { action in
                    Button(action: {
                        handleQuickAction(action.action)
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: action.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(action.color)
                            
                            Text(action.title)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(action.color)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(action.color.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(action.color.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.top, 4)
    }
    
    private func handleQuickAction(_ action: SessionActionType) {
        switch action {
        case .extendTime:
            extendSessionTime()
        case .orderFood:
            openFoodOrdering()
        case .getHelp:
            requestHelp()
        case .preOrder:
            openPreOrdering()
        case .viewDetails:
            showBayDetails()
        case .modify:
            openBookingModification()
        default:
            print("🔧 Action not implemented: \(action)")
        }
    }
    
    // MARK: - Quick Action Implementations
    
    private func extendSessionTime() {
        print("⏰ Extending session time...")
        
        // Add 30 minutes to current session
        sessionManager.extendSession(additionalTime: 1800) // 30 minutes in seconds
        
        // Show success feedback
        showActionFeedback("Extended session by 30 minutes", icon: "clock.badge.plus", color: .green)
    }
    
    private func openFoodOrdering() {
        print("🍔 Opening food ordering...")
        
        // Navigate to food & beverage menu
        // In a real app, this would trigger navigation
        showActionFeedback("Opening F&B Menu", icon: "fork.knife", color: .orange)
    }
    
    private func requestHelp() {
        print("🆘 Requesting help...")
        
        // Call staff assistance
        // In a real app, this would send a notification to staff
        showActionFeedback("Staff notified - Help on the way!", icon: "bell.badge", color: .blue)
    }
    
    private func openPreOrdering() {
        print("🛒 Opening pre-ordering...")
        
        // Navigate to pre-order menu for upcoming sessions
        showActionFeedback("Opening Pre-Order Menu", icon: "cart.badge.plus", color: .purple)
    }
    
    private func showBayDetails() {
        print("ℹ️ Showing bay details...")
        
        // Show detailed bay information and amenities
        showActionFeedback("Bay Details", icon: "info.circle", color: .cyan)
    }
    
    private func openBookingModification() {
        print("✏️ Opening booking modification...")
        
        // Navigate to booking modification screen
        showActionFeedback("Opening Booking Options", icon: "pencil.circle", color: .indigo)
    }
    
    private func showActionFeedback(_ message: String, icon: String, color: Color) {
        // In a real app, this would show a toast notification or alert
        print("✅ \(message)")
        
        // Haptic feedback for user confirmation
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Auto-collapse quick actions after action is taken
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isQuickActionsExpanded = false
            }
        }
    }
}

// MARK: - Interactive Available Bay Card (Enhanced Design)
struct InteractiveAvailableBayCard: View {
    @ObservedObject var sessionManager: CustomerSessionManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Compact booking header
            compactBookingHeader
            
            // Simple availability info
            availabilityInfo
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.08),
                    Color.clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.blue.opacity(0.15), radius: 4, x: 0, y: 2)
    }
    
    private var compactBookingHeader: some View {
        HStack(spacing: 12) {
            // Simple icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "figure.golf")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.blue)
            }
            
            // Booking info
            VStack(alignment: .leading, spacing: 2) {
                Text("Ready to Play?")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Book your perfect bay")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Availability badge
            HStack(spacing: 6) {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                
                Text("AVAILABLE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        }
    }
    
    private var availabilityInfo: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                let availableCount = sessionManager.getAvailableBays(for: .tacoma).count
                Text("\(availableCount) bays ready")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("No wait time")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            // Quick book button
            Button(action: {
                handleQuickBooking()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text("Book Now")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func handleQuickBooking() {
        print("📅 Quick booking initiated...")
        
        // In a real app, this would navigate to booking flow
        // For now, provide feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        print("✅ Opening booking selection...")
    }
    
}

// MARK: - Legacy Active Bay Card (Deprecated - Use InteractiveActiveBayCard)
struct ActiveBayCard: View {
    let session: CustomerSession
    @ObservedObject var sessionManager: CustomerSessionManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with bay name and status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.bayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(session.location.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status indicator
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(session.statusColor)
                            .frame(width: 10, height: 10)
                        
                        Text(session.status.displayName.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(session.statusColor)
                    }
                    
                    if session.status == .active {
                        Text(sessionManager.sessionTimeRemainingText ?? "Active")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(session.statusColor)
                    } else if session.status == .scheduled {
                        Text(sessionManager.upcomingSessionTimeText ?? "Scheduled")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(session.statusColor)
                    }
                }
            }
            
            // Session details
            HStack {
                // Session type and time
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.sessionType.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(session.timeSlotText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Member tier if available
                if let tier = session.membershipTier {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text(tier.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(session.statusColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(session.statusColor.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

// MARK: - Available Bay Card
struct AvailableBayCard: View {
    @ObservedObject var sessionManager: CustomerSessionManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ready to Book")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Select a bay to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Available bays indicator
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 10, height: 10)
                        
                        Text("AVAILABLE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    let availableCount = sessionManager.getAvailableBays(for: .tacoma).count
                    Text("\(availableCount) Bays Open")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            
            // Quick booking info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next Available")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Now - No wait time")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                // Member pricing
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text("$45/hr Member Rate")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.green.opacity(0.1))
                .cornerRadius(6)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                )
        )
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

// MARK: - Enhanced USchedule Service Selection Interface
struct ServiceSelectionView: View {
    @Binding var selectedCategory: ServiceCategory
    @Binding var selectedService: UScheduleService?
    @Binding var playerCount: Int
    let userMembershipTier: MembershipTier?
    
    @State private var showingAllServices = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Service Category Selection
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Choose Your Service")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if userMembershipTier != nil {
                        Text("Member Pricing")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
                
                // Service Category Cards
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(ServiceCategory.allCases) { category in
                        ServiceCategoryCard(
                            category: category,
                            isSelected: selectedCategory == category,
                            userMembershipTier: userMembershipTier
                        ) {
                            selectedCategory = category
                            selectedService = nil // Reset service selection
                        }
                    }
                }
            }
            
            // Selected Service Details
            if selectedCategory == .simulator {
                SimulatorServiceSelection(
                    selectedService: $selectedService,
                    playerCount: $playerCount,
                    userMembershipTier: userMembershipTier
                )
            } else {
                OtherServicesSelection(
                    category: selectedCategory,
                    selectedService: $selectedService,
                    playerCount: $playerCount,
                    userMembershipTier: userMembershipTier
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct ServiceCategoryCard: View {
    let category: ServiceCategory
    let isSelected: Bool
    let userMembershipTier: MembershipTier?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .blue)
                
                VStack(spacing: 4) {
                    Text(category.displayName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isSelected ? .white : .primary)
                        .multilineTextAlignment(.center)
                    
                    Text(category.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(isSelected ? Color.blue : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SimulatorServiceSelection: View {
    @Binding var selectedService: UScheduleService?
    @Binding var playerCount: Int
    let userMembershipTier: MembershipTier?
    
    var simulatorServices: [UScheduleService] {
        UScheduleService.allServices().filter { $0.category == .simulator }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Simulator Tier")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(simulatorServices) { service in
                    SimulatorTierCard(
                        service: service,
                        isSelected: selectedService?.id == service.id,
                        userMembershipTier: userMembershipTier
                    ) {
                        selectedService = service
                    }
                }
            }
            
            // Player Count Selection
            if selectedService != nil {
                PlayerCountSelection(playerCount: $playerCount, maxPlayers: selectedService?.maxPlayers ?? 6)
            }
        }
    }
}

struct SimulatorTierCard: View {
    let service: UScheduleService
    let isSelected: Bool
    let userMembershipTier: MembershipTier?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(service.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let userMembershipTier = userMembershipTier {
                        Text("$\(Int(service.memberPrice))/hr")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(isSelected ? .white : .green)
                        
                        Text("Save $\(Int(service.memberSavings))")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(isSelected ? .white.opacity(0.8) : .green)
                    } else {
                        Text("$\(Int(service.guestPrice))/hr")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(isSelected ? .white : .primary)
                        
                        Text("Guest Rate")
                            .font(.caption)
                            .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    }
                }
            }
            .padding(16)
            .background(isSelected ? Color.blue : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OtherServicesSelection: View {
    let category: ServiceCategory
    @Binding var selectedService: UScheduleService?
    @Binding var playerCount: Int
    let userMembershipTier: MembershipTier?
    
    var categoryServices: [UScheduleService] {
        UScheduleService.allServices().filter { $0.category == category }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(category.displayName) Options")
                .font(.headline)
                .fontWeight(.semibold)
            
            if categoryServices.isEmpty {
                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(categoryServices) { service in
                        ServiceOptionCard(
                            service: service,
                            isSelected: selectedService?.id == service.id,
                            userMembershipTier: userMembershipTier
                        ) {
                            selectedService = service
                        }
                    }
                }
                
                // Player Count Selection for non-simulator services
                if let selected = selectedService, selected.maxPlayers > 1 {
                    PlayerCountSelection(playerCount: $playerCount, maxPlayers: selected.maxPlayers)
                }
            }
        }
    }
}

struct ServiceOptionCard: View {
    let service: UScheduleService
    let isSelected: Bool
    let userMembershipTier: MembershipTier?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(service.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Text("\(service.duration) min")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .cornerRadius(4)
                        
                        if service.requiresInstructor {
                            Text("Instructor")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let userMembershipTier = userMembershipTier {
                        Text("$\(String(format: "%.0f", service.memberPrice))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(isSelected ? .white : .green)
                        
                        if service.memberSavings > 0 {
                            Text("Save $\(Int(service.memberSavings))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(isSelected ? .white.opacity(0.8) : .green)
                        }
                    } else {
                        Text("$\(String(format: "%.0f", service.guestPrice))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(isSelected ? .white : .primary)
                    }
                }
            }
            .padding(16)
            .background(isSelected ? Color.blue : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PlayerCountSelection: View {
    @Binding var playerCount: Int
    let maxPlayers: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Number of Players")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                ForEach(1...min(maxPlayers, 6), id: \.self) { count in
                    Button(action: {
                        playerCount = count
                    }) {
                        Text("\(count)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(playerCount == count ? .white : .primary)
                            .frame(width: 44, height: 44)
                            .background(playerCount == count ? Color.blue : Color(.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(playerCount == count ? Color.blue : Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}