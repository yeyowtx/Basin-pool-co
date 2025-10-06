import SwiftUI
import Foundation

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
        return "\(bayName) • \(location.rawValue)"
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

// MARK: - Session Extensions for UI
extension CustomerSession {
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