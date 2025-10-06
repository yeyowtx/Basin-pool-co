import SwiftUI

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
            // Navigate to menu/food ordering
            print("🍔 Opening food ordering")
        case .getHelp:
            // Open help/support
            print("🆘 Opening help")
        case .preOrder:
            // Open pre-ordering
            print("🛒 Opening pre-order")
        case .viewDetails:
            // Show bay details
            print("ℹ️ Showing bay details")
        case .modify:
            // Open booking modification
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
    VStack(spacing: 20) {
        // Mock session manager for preview
        let bayManager = BayStatusManager()
        let sessionManager = CustomerSessionManager(bayStatusManager: bayManager)
        
        // Active session preview
        BayStatusHeader(sessionManager: sessionManager, showDetails: true, showQuickActions: true)
            .onAppear {
                sessionManager.startMockActiveSession()
            }
        
        // Compact badge preview
        BayStatusBadge(sessionManager: sessionManager)
    }
    .padding()
}