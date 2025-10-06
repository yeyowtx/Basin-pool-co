import SwiftUI
import Foundation
import Combine

// MARK: - Global Customer Session Manager
class CustomerSessionManager: ObservableObject {
    @Published var currentSession: CustomerSession?
    @Published var isSessionActive: Bool = false
    @Published var lastSessionUpdate = Date()
    
    // Reference to other managers
    @ObservedObject var bayStatusManager: BayStatusManager
    private var authService: AuthenticationService?
    
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
    
    func setAuthenticationService(_ authService: AuthenticationService) {
        self.authService = authService
    }
    
    func startSession(bayId: UUID, bayName: String, location: EvergreenLocationLaunch, duration: TimeInterval = 3600) {
        let session = CustomerSession(
            id: UUID(),
            customerId: authService?.currentUser?.id ?? UUID(),
            customerName: authService?.currentUser?.firstName ?? "Guest User",
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
            customerId: authService?.currentUser?.id ?? UUID(),
            customerName: authService?.currentUser?.firstName ?? "Guest User",
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
        case .completed, .cancelled:
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