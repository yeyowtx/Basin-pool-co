//
//  EnhancedBookingView.swift
//  GolfSimApp
//
//  TopGolf-inspired booking flow for Evergreen Golf Club
//

import SwiftUI

enum EvergreenLocation: CaseIterable {
    case redmond
    case tacoma
    
    var name: String {
        switch self {
        case .redmond: return "Redmond"
        case .tacoma: return "Tacoma"
        }
    }
    
    var subtitle: String {
        switch self {
        case .redmond: return "Premier Indoor Golf"
        case .tacoma: return "Indoor Golf Club"
        }
    }
    
    var address: String {
        switch self {
        case .redmond: return "14603 NE 87th ST, Redmond, WA 98052"
        case .tacoma: return "2101 Mildred St W, Tacoma, WA 98466"
        }
    }
    
    var hours: String {
        return "8:00 AM - 7:00 PM"
    }
}

struct EnhancedBookingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var bookingManager = BookingManager()
    @State private var currentStep: BookingStep = .membershipCheck
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    private let evergreenSecondary = Color(red: 28/255, green: 115/255, blue: 48/255)
    private let evergreenLight = Color(red: 76/255, green: 175/255, blue: 80/255)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                switch currentStep {
                case .membershipCheck:
                    MembershipCheckView(bookingManager: bookingManager, onContinue: {
                        currentStep = .playerSelection
                    }, onBack: {
                        // Handle back navigation - could go to previous screen or dismiss
                        currentStep = .playerSelection // or implement proper back navigation
                    })
                case .playerSelection:
                    PlayerSelectionView(bookingManager: bookingManager) {
                        currentStep = .dateTimeSelection
                    }
                case .dateTimeSelection:
                    DateTimeSelectionView(bookingManager: bookingManager) {
                        currentStep = .pricingSelection
                    }
                case .pricingSelection:
                    PricingSelectionView(bookingManager: bookingManager) {
                        currentStep = .phoneVerification
                    }
                case .phoneVerification:
                    PhoneVerificationView(bookingManager: bookingManager) {
                        currentStep = .confirmation
                    }
                case .confirmation:
                    BookingConfirmationView(bookingManager: bookingManager) {
                        dismiss()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

enum BookingStep {
    case membershipCheck, playerSelection, dateTimeSelection, pricingSelection, phoneVerification, confirmation
}

class BookingManager: ObservableObject {
    @Published var playerCount: Int = 2
    @Published var selectedDate = Date()
    @Published var selectedTimeSlot: String = ""
    @Published var selectedPricing: PricingTier?
    @Published var phoneNumber: String = ""
    @Published var location: EvergreenLocation = .redmond
    @Published var membershipManager = MembershipManager()
    @Published var isExistingMember: Bool = false
    @Published var membershipStep: MembershipFlowStep = .ageVerification
    
    var totalPrice: Double {
        guard let pricing = selectedPricing else { return 0 }
        let basePrice = pricing.hourlyRate
        return membershipManager.calculateMemberPrice(basePrice: basePrice)
    }
    
    var memberDiscount: Double {
        guard let pricing = selectedPricing else { return 0 }
        let basePrice = pricing.hourlyRate
        return basePrice - totalPrice
    }
    
    var sessionDuration: Int {
        selectedPricing?.duration ?? 60
    }
    
    var depositAmount: Double {
        totalPrice * 0.25 // 25% deposit
    }
}

struct PlayerSelectionView: View {
    @ObservedObject var bookingManager: BookingManager
    let onContinue: () -> Void
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Text("EVERGREEN")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(evergreenPrimary)
                    
                    Spacer()
                }
                
                Text("\(bookingManager.location.name.uppercased()) LOCATION")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Main Content
            VStack(spacing: 32) {
                Text("BOOK 1 BAY + GOLF PRACTICE\n1-6 PLAYERS")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                // Player Selection
                VStack(spacing: 16) {
                    Text("PLAYERS")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Button(action: {
                            if bookingManager.playerCount > 1 {
                                bookingManager.playerCount -= 1
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(evergreenPrimary)
                        }
                        .disabled(bookingManager.playerCount <= 1)
                        
                        Spacer()
                        
                        Text("\(bookingManager.playerCount) PLAYERS")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            if bookingManager.playerCount < 6 {
                                bookingManager.playerCount += 1
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(evergreenPrimary)
                        }
                        .disabled(bookingManager.playerCount >= 6)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(12)
                }
                
                // Date Selection
                VStack(spacing: 16) {
                    Text("DATE")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    DatePicker("", selection: $bookingManager.selectedDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                
                // Time Selection Placeholder
                VStack(spacing: 16) {
                    Text("TIME")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: onContinue) {
                        HStack {
                            Text("Pick a Time")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                }
                
                // Info Box
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(evergreenPrimary)
                            .font(.system(size: 20))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Includes golf practice in one bay, starting at the selected time.")
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                            
                            Text("25% deposit due at time of booking. Max capacity of 6 players.")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                }
                .padding(16)
                .background(Color(red: 76/255, green: 175/255, blue: 80/255).opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Continue Button
            Button(action: onContinue) {
                Text("CHECK AVAILABILITY")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(evergreenPrimary)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}

struct DateTimeSelectionView: View {
    @ObservedObject var bookingManager: BookingManager
    let onContinue: () -> Void
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    private let evergreenLight = Color(red: 76/255, green: 175/255, blue: 80/255)
    
    private let timeSlots = ["9:15 AM", "9:30 AM", "9:45 AM", "10:00 AM", "10:15 AM"]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with back button
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Time Slots
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(timeSlots, id: \.self) { timeSlot in
                    Button(action: {
                        bookingManager.selectedTimeSlot = timeSlot
                        onContinue()
                    }) {
                        Text(timeSlot)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(evergreenPrimary)
                            .cornerRadius(8)
                    }
                }
                
                // View All button
                Button(action: {}) {
                    Text("VIEW ALL")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(evergreenPrimary)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(evergreenPrimary, lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

struct PricingSelectionView: View {
    @ObservedObject var bookingManager: BookingManager
    let onContinue: () -> Void
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    private let evergreenLight = Color(red: 76/255, green: 175/255, blue: 80/255)
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            VStack(spacing: 16) {
                Text("FRIDAY")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                HStack {
                    Text("PRICING PER BAY")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button("What is a bay?") {}
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(evergreenPrimary)
                }
            }
            .padding(.horizontal, 20)
            
            // Pricing Options
            VStack(spacing: 0) {
                PricingRow(
                    timeRange: "OPEN - 12 PM",
                    price: "$36",
                    tier: .morning,
                    isSelected: bookingManager.selectedPricing?.tier == .morning,
                    onTap: {
                        bookingManager.selectedPricing = PricingTier.morningTier
                        onContinue()
                    }
                )
                
                Divider()
                
                PricingRow(
                    timeRange: "12 PM - 5 PM",
                    price: "$48",
                    tier: .afternoon,
                    isSelected: bookingManager.selectedPricing?.tier == .afternoon,
                    onTap: {
                        bookingManager.selectedPricing = PricingTier.afternoonTier
                        onContinue()
                    }
                )
                
                Divider()
                
                PricingRow(
                    timeRange: "5 PM - 10 PM",
                    price: "$60",
                    tier: .evening,
                    isSelected: bookingManager.selectedPricing?.tier == .evening,
                    onTap: {
                        bookingManager.selectedPricing = PricingTier.eveningTier
                        onContinue()
                    }
                )
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 20)
            
            // Special Offer
            VStack(spacing: 12) {
                HStack {
                    Text("EVERGREEN NIGHTS")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("10 PM - CLOSE")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(evergreenLight)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    Text("$30")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("/HR")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Color(red: 0.2, green: 0.3, blue: 0.4))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .onTapGesture {
                bookingManager.selectedPricing = PricingTier.nightTier
                onContinue()
            }
            
            Text("Prices do not include sales tax. $5 one-time member fee required for new players.")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .padding(.horizontal, 20)
            
            Spacer()
            
            // Current Selection
            if !bookingManager.selectedTimeSlot.isEmpty {
                VStack(spacing: 12) {
                    HStack {
                        Text("Current Selection")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("CONTINUE") {
                            onContinue()
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(evergreenPrimary)
                        .cornerRadius(20)
                    }
                    
                    Text(bookingManager.selectedTimeSlot)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
                .background(Color(red: 0.2, green: 0.3, blue: 0.4))
            }
        }
    }
}

struct PhoneVerificationView: View {
    @ObservedObject var bookingManager: BookingManager
    let onContinue: () -> Void
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Booking Summary
            VStack(spacing: 12) {
                Text("EVERGREEN")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(evergreenPrimary)
                
                Text("\(bookingManager.location.name.uppercased()) LOCATION")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                HStack {
                    Text("1-\(bookingManager.playerCount) PLAYERS")
                    Text("1 BAY")
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Fri, Sep 19")
                            .font(.system(size: 14, weight: .medium))
                        
                        Text("\(bookingManager.selectedTimeSlot) - 11:00 AM")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .font(.system(size: 14))
                
                Text("90 MIN")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding(20)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            
            // Phone Number Section
            VStack(spacing: 16) {
                Text("What's your mobile number?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(evergreenPrimary)
                
                Text("We'll use your phone number to text your bay assignment and reservation-related updates!")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
            
            // Phone Input
            HStack(spacing: 12) {
                HStack {
                    Text("+1")
                        .font(.system(size: 18))
                        .foregroundColor(.primary)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                TextField("Mobile Number", text: $bookingManager.phoneNumber)
                    .font(.system(size: 18))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .keyboardType(.phonePad)
            }
            .padding(.horizontal, 20)
            
            // Terms
            VStack(spacing: 8) {
                Text("By tapping \"SEND CODE\", you agree that Evergreen Golf Club may send you recurring text messages, to your mobile number above, regarding bay assignments and reservation-related updates. Message and data rates may apply. Reply HELP for help, STOP to opt out.")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                HStack {
                    Button("Privacy Policy") {}
                        .font(.system(size: 12))
                        .foregroundColor(evergreenPrimary)
                    
                    Text("|")
                        .foregroundColor(.gray)
                    
                    Button("Terms & Conditions") {}
                        .font(.system(size: 12))
                        .foregroundColor(evergreenPrimary)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Send Code Button
            Button(action: onContinue) {
                Text("SEND CODE")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(evergreenPrimary)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            .disabled(bookingManager.phoneNumber.isEmpty)
            .opacity(bookingManager.phoneNumber.isEmpty ? 0.5 : 1.0)
        }
    }
}

struct BookingConfirmationView: View {
    @ObservedObject var bookingManager: BookingManager
    let onComplete: () -> Void
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(evergreenPrimary)
                
                Text("Booking Confirmed!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                // Booking Details
                VStack(spacing: 16) {
                    Text("Your bay reservation is confirmed for:")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("\(bookingManager.location.name) Location")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text("\(bookingManager.selectedTimeSlot)")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text("\(bookingManager.playerCount) Players")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        
                        Divider()
                        
                        // Pricing Breakdown
                        VStack(spacing: 8) {
                            HStack {
                                Text("Base Rate")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text("$\(Int(bookingManager.selectedPricing?.hourlyRate ?? 0))")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            if bookingManager.memberDiscount > 0 {
                                HStack {
                                    Text("\(bookingManager.membershipManager.currentMembership.displayName) Discount")
                                        .font(.system(size: 14))
                                        .foregroundColor(evergreenPrimary)
                                    
                                    Spacer()
                                    
                                    Text("-$\(Int(bookingManager.memberDiscount))")
                                        .font(.system(size: 14))
                                        .foregroundColor(evergreenPrimary)
                                }
                            }
                            
                            HStack {
                                Text("Total")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("$\(Int(bookingManager.totalPrice))")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(evergreenPrimary)
                            }
                            
                            HStack {
                                Text("Deposit (25%)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text("$\(Int(bookingManager.depositAmount))")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                .padding(20)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Membership Upsell (if guest)
                if bookingManager.membershipManager.currentMembership == .guest {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            
                            Text("Save on Future Bookings!")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        Text("Become a member and save 15-35% on all bay bookings, plus get priority access and exclusive perks.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                        
                        Button("Upgrade to Membership") {
                            // Handle membership upgrade
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(evergreenPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(evergreenPrimary.opacity(0.1))
                        .cornerRadius(20)
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(evergreenPrimary.opacity(0.3), lineWidth: 1)
                    )
                }
                
                Text("A confirmation text has been sent to \(bookingManager.phoneNumber)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    // Record the session
                    bookingManager.membershipManager.addSession()
                    onComplete()
                }) {
                    Text("DONE")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(evergreenPrimary)
                        .cornerRadius(25)
                }
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20)
        }
    }
}

struct PricingRow: View {
    let timeRange: String
    let price: String
    let tier: PricingTierType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(timeRange)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 2) {
                    Text(price)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("/HR")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .alignmentGuide(.bottom) { d in d[.bottom] }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Models

enum PricingTierType {
    case morning, afternoon, evening, night
}

struct PricingTier {
    let tier: PricingTierType
    let hourlyRate: Double
    let duration: Int
    
    static let morningTier = PricingTier(tier: .morning, hourlyRate: 36, duration: 60)
    static let afternoonTier = PricingTier(tier: .afternoon, hourlyRate: 48, duration: 60)
    static let eveningTier = PricingTier(tier: .evening, hourlyRate: 60, duration: 60)
    static let nightTier = PricingTier(tier: .night, hourlyRate: 30, duration: 60)
}

enum MembershipFlowStep {
    case ageVerification, phoneEntry, phoneVerification, membershipWelcome
}

struct MembershipCheckView: View {
    @ObservedObject var bookingManager: BookingManager
    let onContinue: () -> Void
    let onBack: () -> Void
    @State private var showMembershipFlow = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 30
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    private let evergreenSecondary = Color(red: 28/255, green: 115/255, blue: 48/255)
    
    var body: some View {
        ZStack {
            // Background matching welcome screen
            LinearGradient(
                colors: [.white, evergreenPrimary.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header with back button
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("Back")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(evergreenPrimary)
                    }
                    
                    Spacer()
                    
                    Text("Membership")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(evergreenPrimary)
                    
                    Spacer()
                    
                    Text("Back")
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // Welcome content with animation
                VStack(spacing: 32) {
                    // Logo matching welcome screen
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [evergreenPrimary, evergreenSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "person.badge.plus")
                            .foregroundColor(.white)
                            .font(.system(size: 50))
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    
                    // Membership text
                    VStack(spacing: 12) {
                        Text("Join Evergreen")
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(.gray)
                        
                        Text("Golf Club")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(evergreenPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("Unlock premium benefits and exclusive access")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .offset(y: contentOffset)
                    .opacity(logoOpacity)
                }
                
                Spacer()
                
                // Membership buttons
                VStack(spacing: 16) {
                    Button(action: {
                        // Start new membership flow
                        bookingManager.isExistingMember = false
                        bookingManager.membershipStep = .ageVerification
                        showMembershipFlow = true
                    }) {
                        HStack {
                            Text("Become a Member")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [evergreenPrimary, evergreenSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                        .shadow(color: evergreenPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    Button(action: {
                        // Start existing member flow
                        bookingManager.isExistingMember = true
                        bookingManager.membershipStep = .phoneEntry
                        showMembershipFlow = true
                    }) {
                        Text("I'm Already a Member")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(evergreenPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(evergreenPrimary, lineWidth: 2)
                            )
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        // Continue as guest
                        onContinue()
                    }) {
                        Text("Continue as Guest")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .underline()
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startMembershipAnimation()
        }
        .sheet(isPresented: $showMembershipFlow) {
            MembershipFlowView(bookingManager: bookingManager, onComplete: {
                showMembershipFlow = false
                onContinue()
            })
        }
    }
    
    private func startMembershipAnimation() {
        // Animate logo entrance
        withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Animate content
        withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
            contentOffset = 0
        }
    }
}

struct MembershipFlowView: View {
    @ObservedObject var bookingManager: BookingManager
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    
    var body: some View {
        NavigationView {
            VStack {
                switch bookingManager.membershipStep {
                case .ageVerification:
                    AgeVerificationView(bookingManager: bookingManager)
                case .phoneEntry:
                    PhoneEntryView(bookingManager: bookingManager)
                case .phoneVerification:
                    PhoneVerificationFlowView(bookingManager: bookingManager)
                case .membershipWelcome:
                    MembershipWelcomeView(bookingManager: bookingManager, onComplete: onComplete)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct AgeVerificationView: View {
    @ObservedObject var bookingManager: BookingManager
    @State private var age: String = ""
    @Environment(\.dismiss) private var dismiss
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with back button
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(evergreenPrimary)
                }
                
                Spacer()
                
                Text("Step 1 of 4")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("Back")
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            VStack(spacing: 16) {
                Text("Before we get started, please tell us how old you are:")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                TextField("your age", text: $age)
                    .font(.system(size: 18))
                    .padding(.leading, 16)
                    .frame(height: 50)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .keyboardType(.numberPad)
                    .overlay(
                        Rectangle()
                            .frame(width: 3, height: 50)
                            .foregroundColor(evergreenPrimary)
                            .offset(x: -8)
                        , alignment: .leading
                    )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button(action: {
                bookingManager.membershipStep = .phoneEntry
            }) {
                Text("CONTINUE")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(evergreenPrimary)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            .disabled(age.isEmpty)
            .opacity(age.isEmpty ? 0.5 : 1.0)
        }
        .background(Color(.systemBackground))
    }
}

struct PhoneEntryView: View {
    @ObservedObject var bookingManager: BookingManager
    @Environment(\.dismiss) private var dismiss
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with back button
            HStack {
                Button(action: {
                    if bookingManager.isExistingMember {
                        dismiss()
                    } else {
                        bookingManager.membershipStep = .ageVerification
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(evergreenPrimary)
                }
                
                Spacer()
                
                Text(bookingManager.isExistingMember ? "Member Login" : "Step 2 of 4")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("Back")
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            VStack(spacing: 16) {
                Text("What is your current mobile number?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text("We'll send you important updates about your visit that will improve your experience.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 12) {
                    HStack {
                        Text("+1")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    TextField("Mobile Number", text: $bookingManager.phoneNumber)
                        .font(.system(size: 16))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .keyboardType(.phonePad)
                }
                
                Text("Message and data rates may apply")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button(action: {
                bookingManager.membershipStep = .phoneVerification
            }) {
                Text("CONTINUE")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(evergreenPrimary)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            .disabled(bookingManager.phoneNumber.isEmpty)
            .opacity(bookingManager.phoneNumber.isEmpty ? 0.5 : 1.0)
        }
        .background(Color(.systemBackground))
    }
}

struct PhoneVerificationFlowView: View {
    @ObservedObject var bookingManager: BookingManager
    @State private var verificationCode: String = ""
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    
    var body: some View {
        VStack(spacing: 24) {
            // Progress indicators
            HStack(spacing: 8) {
                ForEach(1...2, id: \.self) { number in
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Text("\(number)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                        )
                }
                
                Circle()
                    .fill(evergreenPrimary)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Text("3")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 30, height: 30)
                    .overlay(
                        Text("4")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    )
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Mock SMS notification
            VStack {
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text("55777")
                        .font(.system(size: 14, weight: .medium))
                    
                    Spacer()
                    
                    Text("now")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Text("Your Evergreen verification code is: 3371.")
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(Color(.systemGray5))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                Text("Please enter the verification code that was sent to \(bookingManager.phoneNumber)")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Button("CHANGE PHONE NUMBER") {}
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(evergreenPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Verification code input
                HStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { index in
                        Rectangle()
                            .fill(index == 0 ? Color.blue.opacity(0.1) : Color(.systemGray6))
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                            .overlay(
                                Text(index == 0 ? "3" : "")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                            )
                    }
                }
                
                Button("RESEND CODE") {}
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(evergreenPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button(action: {
                // Check if member exists
                if bookingManager.isExistingMember {
                    // Simulate finding existing membership
                    bookingManager.membershipManager.currentMembership = .basic
                    bookingManager.membershipStep = .membershipWelcome
                } else {
                    // Create new membership
                    bookingManager.membershipManager.currentMembership = .basic
                    bookingManager.membershipStep = .membershipWelcome
                }
            }) {
                Text("VERIFY")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(evergreenPrimary)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Color(.systemBackground))
    }
}

struct MembershipWelcomeView: View {
    @ObservedObject var bookingManager: BookingManager
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    private let evergreenLight = Color(red: 76/255, green: 175/255, blue: 80/255)
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            if bookingManager.isExistingMember {
                // Existing member welcome
                VStack(spacing: 16) {
                    Rectangle()
                        .fill(evergreenPrimary)
                        .frame(height: 60)
                        .overlay(
                            Text("WELCOME BACK")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(evergreenLight)
                                .rotationEffect(.degrees(-2))
                        )
                    
                    Text("LAURENCIO")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(evergreenPrimary)
                    
                    Text("Your Lifetime Membership has been active since 2016")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            } else {
                // New member welcome
                VStack(spacing: 16) {
                    Text("🎉")
                        .font(.system(size: 60))
                    
                    Text("Welcome to Evergreen!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(evergreenPrimary)
                    
                    Text("You're now a Basic Training member with 15% off all bookings!")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    dismiss()
                    onComplete()
                }) {
                    Text("CONTINUE")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(evergreenPrimary)
                        .cornerRadius(25)
                }
                
                if bookingManager.isExistingMember {
                    Button("NOT YOUR MEMBERSHIP?") {}
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(evergreenPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(evergreenPrimary, lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    EnhancedBookingView()
}