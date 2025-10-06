import SwiftUI

// TopGolf-style time selection with USchedule pricing and member discounts
struct TimeSelectionView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject var bayStatusManager: BayStatusManager
    let onContinue: () -> Void
    @State private var selectedTime = "9:30 AM"
    @Environment(\.dismiss) private var dismiss
    
    init(appState: AppStateManager, bayStatusManager: BayStatusManager? = nil, onContinue: @escaping () -> Void) {
        self.appState = appState
        self.bayStatusManager = bayStatusManager ?? BayStatusManager()
        self.onContinue = onContinue
    }
    
    // Real-time time slot availability
    private var availableTimeSlots: [TimeSlot] {
        let times = ["9:15 AM", "9:30 AM", "9:45 AM", "10:00 AM", "10:15 AM"]
        let location = appState.selectedLocation.locationName
        let availableBaysCount = bayStatusManager.getAvailableBaysCount(for: location)
        
        return times.map { time in
            // Simulate different availability for different times
            let availableBays = max(0, availableBaysCount - Int.random(in: 0...3))
            return TimeSlot(
                time: time,
                availableBays: availableBays,
                isAvailable: availableBays > 0
            )
        }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(.white)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Available time slots with real-time availability
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                            ForEach(availableTimeSlots, id: \.time) { timeSlot in
                                Button(action: {
                                    selectedTime = timeSlot.time
                                }) {
                                    VStack(spacing: 4) {
                                        Text(timeSlot.time)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(selectedTime == timeSlot.time ? .white : (timeSlot.isAvailable ? Color(red: 0.1, green: 0.2, blue: 0.8) : .gray))
                                        
                                        Text("\(timeSlot.availableBays) bays")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(selectedTime == timeSlot.time ? .white.opacity(0.8) : .secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedTime == timeSlot.time ? Color(red: 0.1, green: 0.2, blue: 0.8) : .clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(timeSlot.isAvailable ? Color(red: 0.1, green: 0.2, blue: 0.8) : .gray, lineWidth: 2)
                                            )
                                    )
                                }
                                .disabled(!timeSlot.isAvailable)
                            }
                            
                            // View all button
                            Button(action: {}) {
                                Text("VIEW ALL")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.8))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(red: 0.1, green: 0.2, blue: 0.8), lineWidth: 1)
                                            .fill(.clear)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Pricing section with member-specific pricing
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("FRIDAY")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // Member discount badge
                                if appState.currentUser?.membership != nil {
                                    Text("15% MEMBER DISCOUNT")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(.green)
                                        )
                                }
                            }
                            
                            HStack {
                                Text("PRICING PER BAY")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Button(action: {}) {
                                    Text("What is a bay?")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.cyan)
                                        .underline()
                                }
                            }
                            
                            // USchedule pricing tiers with member discounts
                            VStack(spacing: 0) {
                                MemberPricingRow(timeRange: "OPEN - 12 PM", regularPrice: 36, appState: appState)
                                MemberPricingRow(timeRange: "12 PM - 5 PM", regularPrice: 48, appState: appState)
                                MemberPricingRow(timeRange: "5 PM - 10 PM", regularPrice: 60, appState: appState)
                                
                                // TopGolf Nights (special pricing)
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("TOPGOLF NIGHTS")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.green)
                                        Text("10 PM - CLOSE")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(.green)
                                            )
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        if appState.currentUser?.membership != nil {
                                            HStack(alignment: .bottom, spacing: 2) {
                                                Text("$26")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.green)
                                                Text("/HR")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.secondary)
                                            }
                                            Text("$30")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.secondary)
                                                .strikethrough()
                                        } else {
                                            HStack(alignment: .bottom, spacing: 2) {
                                                Text("$30")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.primary)
                                                Text("/HR")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 0.15, green: 0.2, blue: 0.3))
                                )
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                            )
                            
                            // Pricing notes with deposit info
                            VStack(alignment: .leading, spacing: 8) {
                                Text("**25% deposit required at booking.** Prices do not include sales tax.")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                if appState.currentUser?.membership != nil {
                                    Text("✓ Member pricing automatically applied")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.green)
                                } else {
                                    Text("$5 one-time member fee required for new players.")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 120)
                    }
                }
                
                // Bottom section with deposit calculation
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(.gray.opacity(0.2))
                        .frame(height: 0.5)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Selection")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            Text(selectedTime)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            
                            // Show estimated deposit
                            if let depositAmount = calculateDeposit(for: selectedTime) {
                                Text("Deposit: $\(depositAmount, specifier: "%.2f")")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: onContinue) {
                            Text("CONTINUE")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 140, height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color(red: 0.1, green: 0.2, blue: 0.8))
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(.white)
                }
            }
        }
    }
    
    // Calculate deposit based on selected time and membership status
    private func calculateDeposit(for time: String) -> Double? {
        let hour = extractHour(from: time)
        let regularPrice = getPriceForHour(hour)
        let memberPrice = appState.currentUser?.membership != nil ? regularPrice * 0.85 : regularPrice
        return memberPrice * 0.25 // 25% deposit
    }
    
    private func extractHour(from timeString: String) -> Int {
        // Simple hour extraction for time slots
        if timeString.contains("9:") { return 9 }
        if timeString.contains("10:") { return 10 }
        if timeString.contains("11:") { return 11 }
        return 9 // Default to morning rate
    }
    
    private func getPriceForHour(_ hour: Int) -> Double {
        if hour < 12 { return 36.0 }
        if hour < 17 { return 48.0 }
        return 60.0
    }
}

// Member-aware pricing row component
struct MemberPricingRow: View {
    let timeRange: String
    let regularPrice: Double
    @ObservedObject var appState: AppStateManager
    
    private var memberPrice: Double {
        appState.currentUser?.membership != nil ? regularPrice * 0.85 : regularPrice
    }
    
    private var isMember: Bool {
        appState.currentUser?.membership != nil
    }
    
    var body: some View {
        HStack {
            Text(timeRange)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            if isMember {
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(alignment: .bottom, spacing: 2) {
                        Text("$\(Int(memberPrice))")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.green)
                        Text("/HR")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    Text("$\(Int(regularPrice))")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .strikethrough()
                }
            } else {
                HStack(alignment: .bottom, spacing: 2) {
                    Text("$\(Int(regularPrice))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    Text("/HR")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(.white)
    }
}

// Legacy pricing row component (for compatibility)
struct PricingRow: View {
    let timeRange: String
    let price: String
    let period: String
    
    var body: some View {
        HStack {
            Text(timeRange)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(alignment: .bottom, spacing: 2) {
                Text(price)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                Text(period)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(.white)
    }
}

// Time slot data structure for real availability tracking
struct TimeSlot {
    let time: String
    let availableBays: Int
    let isAvailable: Bool
}

#Preview {
    TimeSelectionView(appState: AppStateManager()) {
        print("Continue to player selection")
    }
}