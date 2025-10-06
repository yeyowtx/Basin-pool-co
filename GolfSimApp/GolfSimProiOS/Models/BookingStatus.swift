import SwiftUI
import Foundation
import Combine

// MARK: - Real-Time Bay Status System
class BayStatusManager: ObservableObject {
    @Published var bays: [BayStatus] = []
    @Published var isConnected = true
    @Published var lastUpdate = Date()
    
    private var timer: Timer?
    private let updateInterval: TimeInterval = 30.0
    
    init() {
        setupMockData()
        startRealTimeUpdates()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func setupMockData() {
        // Tacoma Location - 13 bays
        let tacomaBays: [BayStatus] = [
            BayStatus(id: UUID(), bayName: "Woods - Tacoma", location: .tacoma, isAvailable: true, currentBooking: nil, nextBooking: nil, lastCleaningTime: Date().addingTimeInterval(-900)),
            BayStatus(id: UUID(), bayName: "Mickelson - Tacoma", location: .tacoma, isAvailable: false, currentBooking: ActiveBooking(id: UUID(), memberName: "John Smith", startTime: Date().addingTimeInterval(-1800), endTime: Date().addingTimeInterval(1800), memberTier: .cascade), nextBooking: nil, lastCleaningTime: Date().addingTimeInterval(-3600)),
            BayStatus(id: UUID(), bayName: "Palmer - Tacoma", location: .tacoma, isAvailable: true, currentBooking: nil, nextBooking: UpcomingBooking(id: UUID(), memberName: "Sarah Johnson", startTime: Date().addingTimeInterval(3600), memberTier: .pike), lastCleaningTime: Date().addingTimeInterval(-600)),
            BayStatus(id: UUID(), bayName: "Nicklaus - Tacoma", location: .tacoma, isAvailable: false, currentBooking: nil, nextBooking: nil, lastCleaningTime: Date(), isUnderMaintenance: false, estimatedAvailable: Date().addingTimeInterval(900)),
            BayStatus(id: UUID(), bayName: "Ochoa - Tacoma", location: .tacoma, isAvailable: true, currentBooking: nil, nextBooking: nil, lastCleaningTime: Date().addingTimeInterval(-300)),
            BayStatus(id: UUID(), bayName: "Garcia - Tacoma", location: .tacoma, isAvailable: false, currentBooking: ActiveBooking(id: UUID(), memberName: "Mike Wilson", startTime: Date().addingTimeInterval(-2700), endTime: Date().addingTimeInterval(900), memberTier: .rainier), nextBooking: nil, lastCleaningTime: Date().addingTimeInterval(-4500)),
            BayStatus(id: UUID(), bayName: "McIlroy - Tacoma", location: .tacoma, isAvailable: true, currentBooking: nil, nextBooking: nil, lastCleaningTime: Date().addingTimeInterval(-1200)),
            BayStatus(id: UUID(), bayName: "Spieth - Tacoma", location: .tacoma, isAvailable: true, currentBooking: nil, nextBooking: UpcomingBooking(id: UUID(), memberName: "Guest User", startTime: Date().addingTimeInterval(7200), memberTier: nil), lastCleaningTime: Date().addingTimeInterval(-800)),
            BayStatus(id: UUID(), bayName: "Day - Tacoma", location: .tacoma, isAvailable: false, currentBooking: ActiveBooking(id: UUID(), memberName: "Jennifer Lee", startTime: Date().addingTimeInterval(-900), endTime: Date().addingTimeInterval(2700), memberTier: .cascade), nextBooking: nil, lastCleaningTime: Date().addingTimeInterval(-2100)),
            BayStatus(id: UUID(), bayName: "Fowler - Tacoma", location: .tacoma, isAvailable: true, currentBooking: nil, nextBooking: nil, lastCleaningTime: Date().addingTimeInterval(-450)),
            BayStatus(id: UUID(), bayName: "Thomas - Tacoma", location: .tacoma, isAvailable: true, currentBooking: nil, nextBooking: nil, lastCleaningTime: Date().addingTimeInterval(-1800)),
            BayStatus(id: UUID(), bayName: "Koepka - Tacoma", location: .tacoma, isAvailable: false, currentBooking: nil, nextBooking: nil, lastCleaningTime: Date(), isUnderMaintenance: true, estimatedAvailable: Date().addingTimeInterval(1800)),
            BayStatus(id: UUID(), bayName: "Rahm - Tacoma", location: .tacoma, isAvailable: true, currentBooking: nil, nextBooking: UpcomingBooking(id: UUID(), memberName: "Robert Chen", startTime: Date().addingTimeInterval(1800), memberTier: .pike), lastCleaningTime: Date().addingTimeInterval(-750))
        ]
        
        // Redmond Location - 8 bays
        let redmondBays: [BayStatus] = [
            BayStatus(id: UUID(), bayName: "Watson - Redmond", location: .redmond, isAvailable: true, currentBooking: nil, nextBooking: nil, lastCleaningTime: Date().addingTimeInterval(-600)),
            BayStatus(id: UUID(), bayName: "Hogan - Redmond", location: .redmond, isAvailable: false, currentBooking: ActiveBooking(id: UUID(), memberName: "Lisa Wang", startTime: Date().addingTimeInterval(-2400), endTime: Date().addingTimeInterval(1200), memberTier: .rainier), nextBooking: nil, lastCleaningTime: Date().addingTimeInterval(-3000)),
            BayStatus(id: UUID(), bayName: "Snead - Redmond", location: .redmond, isAvailable: true, currentBooking: nil, nextBooking: UpcomingBooking(id: UUID(), memberName: "David Park", startTime: Date().addingTimeInterval(2700), memberTier: .cascade), lastCleaningTime: Date().addingTimeInterval(-900)),
            BayStatus(id: UUID(), bayName: "Nelson - Redmond", location: .redmond, isAvailable: true, currentBooking: nil, nextBooking: nil, lastCleaningTime: Date().addingTimeInterval(-300)),
            BayStatus(id: UUID(), bayName: "Player - Redmond", location: .redmond, isAvailable: false, currentBooking: ActiveBooking(id: UUID(), memberName: "Guest Walk-in", startTime: Date().addingTimeInterval(-1200), endTime: Date().addingTimeInterval(2400), memberTier: nil), nextBooking: nil, lastCleaningTime: Date().addingTimeInterval(-2700)),
            BayStatus(id: UUID(), bayName: "Trevino - Redmond", location: .redmond, isAvailable: true, currentBooking: nil, nextBooking: nil, lastCleaningTime: Date().addingTimeInterval(-1500)),
            BayStatus(id: UUID(), bayName: "Couples - Redmond", location: .redmond, isAvailable: false, currentBooking: nil, nextBooking: nil, lastCleaningTime: Date(), isUnderMaintenance: false, estimatedAvailable: Date().addingTimeInterval(600)),
            BayStatus(id: UUID(), bayName: "Singh - Redmond", location: .redmond, isAvailable: true, currentBooking: nil, nextBooking: UpcomingBooking(id: UUID(), memberName: "Team Building Event", startTime: Date().addingTimeInterval(5400), memberTier: .pike), lastCleaningTime: Date().addingTimeInterval(-1050))
        ]
        
        bays = tacomaBays + redmondBays
    }
    
    func startRealTimeUpdates() {
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.updateBayStatuses()
        }
    }
    
    private func updateBayStatuses() {
        DispatchQueue.main.async {
            // Simulate real-time updates
            for index in 0..<self.bays.count {
                // Random chance of status change
                if Bool.random() && Double.random(in: 0...1) < 0.1 {
                    self.bays[index].simulateStatusChange()
                }
            }
            
            self.lastUpdate = Date()
            
            // Simulate connection status
            if Double.random(in: 0...1) < 0.05 {
                self.isConnected = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.isConnected = true
                }
            }
        }
    }
    
    func getBaysByLocation(_ location: EvergreenLocationLaunch) -> [BayStatus] {
        return bays.filter { $0.location == location }
    }
    
    func getAvailableBaysCount(for location: EvergreenLocationLaunch) -> Int {
        return getBaysByLocation(location).filter { $0.isAvailable }.count
    }
    
    func getTotalBaysCount(for location: EvergreenLocationLaunch) -> Int {
        return getBaysByLocation(location).count
    }
}

// MARK: - Bay Status Models
struct BayStatus: Identifiable, Equatable {
    let id: UUID
    let bayName: String
    let location: EvergreenLocationLaunch
    var isAvailable: Bool
    var currentBooking: ActiveBooking?
    var nextBooking: UpcomingBooking?
    var lastCleaningTime: Date
    var isUnderMaintenance: Bool = false
    var estimatedAvailable: Date?
    
    var statusColor: Color {
        if isUnderMaintenance {
            return .orange
        } else if isAvailable {
            return .green
        } else {
            return .red
        }
    }
    
    var statusText: String {
        if isUnderMaintenance {
            return "Maintenance"
        } else if isAvailable {
            return "Available"
        } else if currentBooking != nil {
            return "In Use"
        } else {
            return "Cleaning"
        }
    }
    
    var nextAvailableText: String? {
        if let estimated = estimatedAvailable {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Available at \(formatter.string(from: estimated))"
        }
        return nil
    }
    
    mutating func simulateStatusChange() {
        // Simulate bay becoming available/unavailable
        if isAvailable {
            // Bay might become occupied
            if Bool.random() {
                isAvailable = false
                currentBooking = ActiveBooking(
                    id: UUID(),
                    memberName: ["John Doe", "Jane Smith", "Guest User", "Mike Wilson"].randomElement()!,
                    startTime: Date(),
                    endTime: Date().addingTimeInterval(3600),
                    memberTier: MembershipTier.allCases.randomElement()
                )
            }
        } else {
            // Bay might become available
            if Bool.random() {
                isAvailable = true
                currentBooking = nil
                lastCleaningTime = Date()
            }
        }
    }
}

struct ActiveBooking: Identifiable, Equatable {
    let id: UUID
    let memberName: String
    let startTime: Date
    let endTime: Date
    let memberTier: MembershipTier?
    
    var timeRemaining: TimeInterval {
        return endTime.timeIntervalSince(Date())
    }
    
    var timeRemainingText: String {
        let remaining = timeRemaining
        if remaining <= 0 {
            return "Overtime"
        }
        
        let hours = Int(remaining) / 3600
        let minutes = Int(remaining.truncatingRemainder(dividingBy: 3600)) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m remaining"
        } else {
            return "\(minutes)m remaining"
        }
    }
}

struct UpcomingBooking: Identifiable, Equatable {
    let id: UUID
    let memberName: String
    let startTime: Date
    let memberTier: MembershipTier?
    
    var timeUntilStart: TimeInterval {
        return startTime.timeIntervalSince(Date())
    }
    
    var timeUntilStartText: String {
        let until = timeUntilStart
        if until <= 0 {
            return "Starting now"
        }
        
        let hours = Int(until) / 3600
        let minutes = Int(until.truncatingRemainder(dividingBy: 3600)) / 60
        
        if hours > 0 {
            return "Next: \(hours)h \(minutes)m"
        } else {
            return "Next: \(minutes)m"
        }
    }
}

// MARK: - Real-Time Bay Status View
struct RealTimeBayStatusView: View {
    @StateObject private var bayStatusManager = BayStatusManager()
    let location: EvergreenLocationLaunch
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    private let evergreenSecondary = Color(red: 28/255, green: 115/255, blue: 48/255)
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with connection status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("LIVE BAY STATUS")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(evergreenPrimary)
                    
                    HStack {
                        Circle()
                            .fill(bayStatusManager.isConnected ? .green : .red)
                            .frame(width: 8, height: 8)
                        
                        Text(bayStatusManager.isConnected ? "Live" : "Reconnecting...")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(bayStatusManager.getAvailableBaysCount(for: location))/\(bayStatusManager.getTotalBaysCount(for: location)) AVAILABLE")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(evergreenPrimary)
                    
                    Text("Updated \(timeAgoText(bayStatusManager.lastUpdate))")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            
            // Bay status grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(bayStatusManager.getBaysByLocation(location)) { bay in
                    BayStatusCard(bay: bay)
                }
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            bayStatusManager.startRealTimeUpdates()
        }
    }
    
    private func timeAgoText(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval / 60)
        
        if minutes < 1 {
            return "now"
        } else if minutes == 1 {
            return "1m ago"
        } else {
            return "\(minutes)m ago"
        }
    }
}

struct BayStatusCard: View {
    let bay: BayStatus
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Bay name and status
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(bay.bayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack {
                        Circle()
                            .fill(bay.statusColor)
                            .frame(width: 8, height: 8)
                        
                        Text(bay.statusText)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(bay.statusColor)
                    }
                }
                
                Spacer()
            }
            
            // Current booking info
            if let currentBooking = bay.currentBooking {
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentBooking.memberName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(currentBooking.timeRemainingText)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            
            // Next booking or availability info
            if let nextBooking = bay.nextBooking {
                Text(nextBooking.timeUntilStartText)
                    .font(.system(size: 10))
                    .foregroundColor(evergreenPrimary)
            } else if let nextAvailable = bay.nextAvailableText {
                Text(nextAvailable)
                    .font(.system(size: 10))
                    .foregroundColor(.orange)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(bay.statusColor.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Customer Session Models

struct CustomerSession: Identifiable, Codable, Equatable {
    let id: UUID
    let customerId: UUID
    var customerName: String
    var membershipTier: MembershipTier?
    
    // Bay Information
    let bayId: UUID
    var bayName: String
    var location: EvergreenLocationLaunch
    
    // Session Timing
    var startTime: Date
    var plannedEndTime: Date
    var actualEndTime: Date?
    var lastUpdated: Date
    
    // Session Status
    var status: SessionStatus
    var sessionType: SessionType
    
    // Additional Properties
    var notes: String?
    var totalCost: Double?
    var paymentStatus: PaymentStatus?
    
    init(id: UUID = UUID(), customerId: UUID, customerName: String, membershipTier: MembershipTier?, bayId: UUID, bayName: String, location: EvergreenLocationLaunch, startTime: Date, plannedEndTime: Date, status: SessionStatus, sessionType: SessionType) {
        self.id = id
        self.customerId = customerId
        self.customerName = customerName
        self.membershipTier = membershipTier
        self.bayId = bayId
        self.bayName = bayName
        self.location = location
        self.startTime = startTime
        self.plannedEndTime = plannedEndTime
        self.status = status
        self.sessionType = sessionType
        self.lastUpdated = Date()
    }
    
    // MARK: - Computed Properties
    
    var duration: TimeInterval {
        return plannedEndTime.timeIntervalSince(startTime)
    }
    
    var actualDuration: TimeInterval? {
        guard let endTime = actualEndTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    var isActive: Bool {
        return status == .active
    }
    
    var isScheduled: Bool {
        return status == .scheduled
    }
    
    var isCompleted: Bool {
        return status == .completed
    }
    
    var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
    
    var formattedEndTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: plannedEndTime)
    }
    
    var timeSlotText: String {
        return "\(formattedStartTime) - \(formattedEndTime)"
    }
    
    var statusColor: Color {
        switch status {
        case .scheduled:
            return .orange
        case .active:
            return .green
        case .completed:
            return .blue
        case .cancelled:
            return .red
        case .noShow:
            return .gray
        }
    }
    
    var locationDisplayName: String {
        return "\(bayName) • \(location.name)"
    }
    
    // MARK: - Session Actions
    
    mutating func markAsStarted() {
        status = .active
        startTime = Date()
        lastUpdated = Date()
    }
    
    mutating func markAsCompleted(endTime: Date = Date()) {
        status = .completed
        actualEndTime = endTime
        lastUpdated = Date()
    }
    
    mutating func markAsCancelled() {
        status = .cancelled
        lastUpdated = Date()
    }
    
    mutating func markAsNoShow() {
        status = .noShow
        lastUpdated = Date()
    }
    
    mutating func extendSession(by additionalTime: TimeInterval) {
        plannedEndTime = plannedEndTime.addingTimeInterval(additionalTime)
        lastUpdated = Date()
    }
    
    mutating func updateCustomerInfo(name: String, tier: MembershipTier?) {
        customerName = name
        membershipTier = tier
        lastUpdated = Date()
    }
    
    var quickActionItems: [SessionQuickAction] {
        switch status {
        case .active:
            return [
                SessionQuickAction(title: "Extend Time", icon: "plus.circle", color: .blue, action: .extendTime),
                SessionQuickAction(title: "Order F&B", icon: "fork.knife", color: .orange, action: .orderFood),
                SessionQuickAction(title: "Get Help", icon: "questionmark.circle", color: .gray, action: .getHelp)
            ]
        case .scheduled:
            return [
                SessionQuickAction(title: "Pre-Order", icon: "cart", color: .orange, action: .preOrder),
                SessionQuickAction(title: "Bay Details", icon: "info.circle", color: .blue, action: .viewDetails),
                SessionQuickAction(title: "Modify", icon: "calendar", color: .gray, action: .modify)
            ]
        default:
            return []
        }
    }
}

// MARK: - Session Status
enum SessionStatus: String, CaseIterable, Codable {
    case scheduled = "scheduled"
    case active = "active"
    case completed = "completed"
    case cancelled = "cancelled"
    case noShow = "no_show"
    
    var displayName: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .active: return "Active"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .noShow: return "No Show"
        }
    }
    
    var systemImage: String {
        switch self {
        case .scheduled: return "calendar"
        case .active: return "play.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        case .noShow: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Session Type
enum SessionType: String, CaseIterable, Codable {
    case simulator = "simulator"
    case lesson = "lesson"
    case event = "event"
    case tournament = "tournament"
    
    var displayName: String {
        switch self {
        case .simulator: return "Simulator Session"
        case .lesson: return "Golf Lesson"
        case .event: return "Special Event"
        case .tournament: return "Tournament"
        }
    }
    
    var systemImage: String {
        switch self {
        case .simulator: return "tv.and.hifispeaker"
        case .lesson: return "person.fill.checkmark"
        case .event: return "calendar.badge.plus"
        case .tournament: return "trophy.fill"
        }
    }
}

// MARK: - Payment Status
enum PaymentStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case authorized = "authorized"
    case charged = "charged"
    case refunded = "refunded"
    case failed = "failed"
    
    var displayName: String {
        switch self {
        case .pending: return "Payment Pending"
        case .authorized: return "Payment Authorized"
        case .charged: return "Payment Complete"
        case .refunded: return "Refunded"
        case .failed: return "Payment Failed"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .authorized: return .blue
        case .charged: return .green
        case .refunded: return .gray
        case .failed: return .red
        }
    }
}

struct SessionQuickAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let action: SessionActionType
}

enum SessionActionType {
    case extendTime
    case orderFood
    case getHelp
    case preOrder
    case viewDetails
    case modify
    case cancel
    case checkin
}

// MARK: - Session History Helper
struct SessionHistory {
    static func mockSessions() -> [CustomerSession] {
        let now = Date()
        return [
            CustomerSession(
                customerId: UUID(),
                customerName: "John Smith",
                membershipTier: .cascade,
                bayId: UUID(),
                bayName: "Mickelson - Tacoma",
                location: .tacoma,
                startTime: now.addingTimeInterval(-7200), // 2 hours ago
                plannedEndTime: now.addingTimeInterval(-3600), // 1 hour ago
                status: .completed,
                sessionType: .simulator
            ),
            CustomerSession(
                customerId: UUID(),
                customerName: "John Smith",
                membershipTier: .cascade,
                bayId: UUID(),
                bayName: "Palmer - Tacoma",
                location: .tacoma,
                startTime: now.addingTimeInterval(-86400), // Yesterday
                plannedEndTime: now.addingTimeInterval(-82800), // Yesterday + 1 hour
                status: .completed,
                sessionType: .simulator
            ),
            CustomerSession(
                customerId: UUID(),
                customerName: "John Smith",
                membershipTier: .cascade,
                bayId: UUID(),
                bayName: "Woods - Tacoma",
                location: .tacoma,
                startTime: now.addingTimeInterval(-172800), // 2 days ago
                plannedEndTime: now.addingTimeInterval(-169200), // 2 days ago + 1 hour
                status: .completed,
                sessionType: .lesson
            )
        ]
    }
}

// MARK: - Global Customer Session Manager
class CustomerSessionManager: ObservableObject {
    @Published var currentSession: CustomerSession?
    @Published var isSessionActive: Bool = false
    @Published var lastSessionUpdate = Date()
    
    // Reference to other managers
    @ObservedObject var bayStatusManager: BayStatusManager
    
    // Session tracking
    private var sessionTimer: Timer?
    private var sessionStartTime: Date?
    private var cancellables = Set<AnyCancellable>()
    
    init(bayStatusManager: BayStatusManager) {
        self.bayStatusManager = bayStatusManager
        setupSessionTracking()
        startSessionMonitoring()
    }
    
    deinit {
        sessionTimer?.invalidate()
        cancellables.removeAll()
    }
    
    // MARK: - Session Management
    
    func startSession(bayId: UUID, bayName: String, location: EvergreenLocationLaunch, duration: TimeInterval = 3600) {
        let session = CustomerSession(
            id: UUID(),
            customerId: UUID(),
            customerName: "Guest User",
            membershipTier: getCurrentMembershipTier(),
            bayId: bayId,
            bayName: bayName,
            location: location,
            startTime: Date(),
            plannedEndTime: Date().addingTimeInterval(duration),
            status: .active,
            sessionType: .simulator
        )
        
        currentSession = session
        isSessionActive = true
        sessionStartTime = Date()
        lastSessionUpdate = Date()
        
        // Start session timer
        startSessionTimer()
        
        print("🎯 Session started: \(bayName) for \(duration/60) minutes")
    }
    
    func extendSession(additionalTime: TimeInterval) {
        guard var session = currentSession else { return }
        
        session.plannedEndTime = session.plannedEndTime.addingTimeInterval(additionalTime)
        session.lastUpdated = Date()
        currentSession = session
        lastSessionUpdate = Date()
        
        print("⏰ Session extended by \(additionalTime/60) minutes")
    }
    
    func endSession() {
        guard var session = currentSession else { return }
        
        session.actualEndTime = Date()
        session.status = .completed
        session.lastUpdated = Date()
        
        // Archive the session (in real app, save to persistence layer)
        currentSession = nil
        isSessionActive = false
        sessionTimer?.invalidate()
        sessionStartTime = nil
        lastSessionUpdate = Date()
        
        print("🏁 Session ended: \(session.bayName)")
    }
    
    func scheduleUpcomingSession(bayId: UUID, bayName: String, location: EvergreenLocationLaunch, startTime: Date, duration: TimeInterval = 3600) {
        let session = CustomerSession(
            id: UUID(),
            customerId: UUID(),
            customerName: "Guest User",
            membershipTier: getCurrentMembershipTier(),
            bayId: bayId,
            bayName: bayName,
            location: location,
            startTime: startTime,
            plannedEndTime: startTime.addingTimeInterval(duration),
            status: .scheduled,
            sessionType: .simulator
        )
        
        currentSession = session
        lastSessionUpdate = Date()
        
        print("📅 Upcoming session scheduled: \(bayName) at \(startTime)")
    }
    
    // MARK: - Session State Queries
    
    var userBookingState: UserBookingState {
        guard let session = currentSession else { return .walkIn }
        
        switch session.status {
        case .active:
            return .currentlyPlaying
        case .scheduled:
            return .upcomingBooking
        case .completed, .cancelled, .noShow:
            return .walkIn
        }
    }
    
    var currentBayName: String? {
        return currentSession?.bayName
    }
    
    var currentLocation: EvergreenLocationLaunch? {
        return currentSession?.location
    }
    
    var sessionTimeRemaining: TimeInterval? {
        guard let session = currentSession, session.status == .active else { return nil }
        return session.plannedEndTime.timeIntervalSince(Date())
    }
    
    var sessionTimeRemainingText: String? {
        guard let remaining = sessionTimeRemaining else { return nil }
        
        if remaining <= 0 {
            return "Overtime"
        }
        
        let hours = Int(remaining) / 3600
        let minutes = Int(remaining.truncatingRemainder(dividingBy: 3600)) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m remaining"
        } else {
            return "\(minutes)m remaining"
        }
    }
    
    var upcomingSessionTimeUntilStart: TimeInterval? {
        guard let session = currentSession, session.status == .scheduled else { return nil }
        return session.startTime.timeIntervalSince(Date())
    }
    
    var upcomingSessionTimeText: String? {
        guard let until = upcomingSessionTimeUntilStart else { return nil }
        
        if until <= 0 {
            return "Starting now"
        }
        
        let hours = Int(until) / 3600
        let minutes = Int(until.truncatingRemainder(dividingBy: 3600)) / 60
        
        if hours > 0 {
            return "Starts in \(hours)h \(minutes)m"
        } else {
            return "Starts in \(minutes)m"
        }
    }
    
    // MARK: - Bay Status Integration
    
    func getCurrentBayStatus() -> BayStatus? {
        guard let session = currentSession else { return nil }
        return bayStatusManager.bays.first { $0.id == session.bayId }
    }
    
    func getAvailableBays(for location: EvergreenLocationLaunch) -> [BayStatus] {
        return bayStatusManager.getBaysByLocation(location).filter { $0.isAvailable }
    }
    
    // MARK: - Private Methods
    
    private func setupSessionTracking() {
        // Monitor bay status changes that might affect our session
        bayStatusManager.$bays
            .sink { [weak self] bays in
                self?.checkSessionValidity(against: bays)
            }
            .store(in: &cancellables)
    }
    
    private func startSessionMonitoring() {
        // Check for session state changes every 30 seconds
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.updateSessionStatus()
        }
    }
    
    private func startSessionTimer() {
        // Session-specific timer for active sessions
        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.updateActiveSession()
        }
    }
    
    private func updateActiveSession() {
        guard var session = currentSession, session.status == .active else { return }
        
        // Check if session should transition to upcoming or end
        let now = Date()
        
        if now >= session.plannedEndTime {
            // Session time is up - could auto-end or mark as overtime
            session.status = .completed
            session.actualEndTime = now
            currentSession = session
            endSession()
        } else {
            // Update last activity
            session.lastUpdated = now
            currentSession = session
            lastSessionUpdate = now
        }
        
        // Trigger UI updates
        objectWillChange.send()
    }
    
    private func updateSessionStatus() {
        guard let session = currentSession else { return }
        
        let now = Date()
        
        // Handle scheduled sessions that should start
        if session.status == .scheduled && now >= session.startTime {
            var updatedSession = session
            updatedSession.status = .active
            updatedSession.lastUpdated = now
            currentSession = updatedSession
            isSessionActive = true
            sessionStartTime = now
            
            // Switch to active session timer
            startSessionTimer()
        }
        
        lastSessionUpdate = now
        objectWillChange.send()
    }
    
    private func checkSessionValidity(against bays: [BayStatus]) {
        guard let session = currentSession else { return }
        
        // Find our bay in the current bay status
        if let bayStatus = bays.first(where: { $0.id == session.bayId }) {
            // Check if our session is still valid based on bay status
            if session.status == .active && !bayStatus.isAvailable {
                // Bay is still in use, session is valid
                return
            } else if session.status == .active && bayStatus.isAvailable {
                // Bay became available but we think we're still playing - investigate
                print("⚠️ Session bay status mismatch detected")
            }
        }
    }
    
    private func getCurrentMembershipTier() -> MembershipTier? {
        // In real app, this would come from authenticated user
        return .cascade // Mock tier for now
    }
    
    // MARK: - Mock Data for Development
    
    func startMockActiveSession() {
        startSession(
            bayId: UUID(),
            bayName: "Mickelson - Tacoma",
            location: .tacoma,
            duration: 3600 // 1 hour
        )
    }
    
    func startMockUpcomingSession() {
        scheduleUpcomingSession(
            bayId: UUID(),
            bayName: "Palmer - Tacoma", 
            location: .tacoma,
            startTime: Date().addingTimeInterval(1500), // 25 minutes from now
            duration: 3600
        )
    }
    
    func clearSession() {
        currentSession = nil
        isSessionActive = false
        sessionTimer?.invalidate()
        sessionStartTime = nil
        lastSessionUpdate = Date()
    }
}

// MARK: - Customer Session State
enum UserBookingState: CaseIterable {
    case currentlyPlaying
    case upcomingBooking
    case walkIn
    
    var displayText: String {
        switch self {
        case .currentlyPlaying: return "Currently Playing"
        case .upcomingBooking: return "Upcoming Booking"
        case .walkIn: return "Walk-in"
        }
    }
}