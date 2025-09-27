//
//  Booking.swift
//  TopGolf-Inspired Golf Sim App
//
//  Booking and reservation models based on TopGolf flow analysis
//  Handles complete booking lifecycle from selection to completion
//

import Foundation

// MARK: - Booking Model
struct Booking: Identifiable, Codable {
    let id = UUID()
    let bookingNumber: String
    let timeSlot: TimeSlot
    let venue: Venue
    let customerInfo: CustomerInfo
    let partyDetails: PartyDetails
    let pricing: BookingPricing
    let payment: PaymentInfo?
    let status: BookingStatus
    let createdAt: Date
    let updatedAt: Date
    
    // Additional booking information
    let specialRequests: String?
    let promoCode: String?
    let referralSource: String?
    let marketingConsent: Bool
    
    // Confirmation details
    let confirmationSentAt: Date?
    let reminderSentAt: Date?
    let checkInTime: Date?
    let checkOutTime: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, bookingNumber, timeSlot, venue, customerInfo, partyDetails
        case pricing, payment, status, createdAt, updatedAt
        case specialRequests, promoCode, referralSource, marketingConsent
        case confirmationSentAt, reminderSentAt, checkInTime, checkOutTime
    }
    
    init(timeSlot: TimeSlot,
         venue: Venue,
         customerInfo: CustomerInfo,
         partyDetails: PartyDetails,
         pricing: BookingPricing,
         payment: PaymentInfo? = nil,
         status: BookingStatus = .pending,
         specialRequests: String? = nil,
         promoCode: String? = nil,
         referralSource: String? = nil,
         marketingConsent: Bool = false) {
        
        self.id = UUID()
        self.bookingNumber = Self.generateBookingNumber()
        self.timeSlot = timeSlot
        self.venue = venue
        self.customerInfo = customerInfo
        self.partyDetails = partyDetails
        self.pricing = pricing
        self.payment = payment
        self.status = status
        self.createdAt = Date()
        self.updatedAt = Date()
        self.specialRequests = specialRequests
        self.promoCode = promoCode
        self.referralSource = referralSource
        self.marketingConsent = marketingConsent
        self.confirmationSentAt = nil
        self.reminderSentAt = nil
        self.checkInTime = nil
        self.checkOutTime = nil
    }
    
    // MARK: - Computed Properties
    
    var isActive: Bool {
        status.isActive
    }
    
    var isPaid: Bool {
        payment?.status == .completed
    }
    
    var canBeCancelled: Bool {
        status.canBeCancelled && timeSlot.startTime > Date()
    }
    
    var canBeModified: Bool {
        status.canBeModified && timeSlot.startTime > Date().addingTimeInterval(24 * 60 * 60)
    }
    
    var requiresCheckIn: Bool {
        status == .confirmed && !isCheckedIn
    }
    
    var isCheckedIn: Bool {
        checkInTime != nil
    }
    
    var isCompleted: Bool {
        status == .completed || checkOutTime != nil
    }
    
    var duration: TimeInterval {
        timeSlot.duration
    }
    
    var totalCost: Double {
        pricing.totalAmount
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: timeSlot.startTime)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: timeSlot.startTime)) - \(formatter.string(from: timeSlot.endTime))"
    }
    
    var timeUntilSession: TimeInterval {
        timeSlot.startTime.timeIntervalSinceNow
    }
    
    var hoursUntilSession: Int {
        Int(timeUntilSession / 3600)
    }
    
    var needsReminder: Bool {
        status == .confirmed && reminderSentAt == nil && timeUntilSession <= 24 * 60 * 60
    }
    
    private static func generateBookingNumber() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        let letterPart = String((0..<2).map { _ in letters.randomElement()! })
        let numberPart = String((0..<6).map { _ in numbers.randomElement()! })
        return "\(letterPart)\(numberPart)"
    }
}

// MARK: - Booking Status
enum BookingStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case cancelled = "cancelled"
    case completed = "completed"
    case noShow = "no_show"
    case inProgress = "in_progress"
    case refunded = "refunded"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .cancelled: return "Cancelled"
        case .completed: return "Completed"
        case .noShow: return "No Show"
        case .inProgress: return "In Progress"
        case .refunded: return "Refunded"
        }
    }
    
    var isActive: Bool {
        switch self {
        case .confirmed, .inProgress: return true
        default: return false
        }
    }
    
    var canBeCancelled: Bool {
        switch self {
        case .pending, .confirmed: return true
        default: return false
        }
    }
    
    var canBeModified: Bool {
        switch self {
        case .pending, .confirmed: return true
        default: return false
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .confirmed: return "green"
        case .cancelled: return "red"
        case .completed: return "blue"
        case .noShow: return "red"
        case .inProgress: return "purple"
        case .refunded: return "gray"
        }
    }
}

// MARK: - Customer Information
struct CustomerInfo: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let dateOfBirth: Date?
    let membershipNumber: String?
    let emergencyContact: EmergencyContact?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let firstInitial = firstName.prefix(1).uppercased()
        let lastInitial = lastName.prefix(1).uppercased()
        return "\(firstInitial)\(lastInitial)"
    }
    
    var isMember: Bool {
        membershipNumber != nil
    }
    
    var formattedPhone: String {
        // Format as (XXX) XXX-XXXX
        let cleaned = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if cleaned.count == 10 {
            let areaCode = cleaned.prefix(3)
            let exchange = cleaned.dropFirst(3).prefix(3)
            let number = cleaned.suffix(4)
            return "(\(areaCode)) \(exchange)-\(number)"
        }
        return phone
    }
}

struct EmergencyContact: Codable {
    let name: String
    let relationship: String
    let phone: String
}

// MARK: - Party Details
struct PartyDetails: Codable {
    let numberOfPlayers: Int
    let players: [PlayerInfo]
    let specialAccommodations: [String]
    let skillLevels: [SkillLevel]
    let groupType: GroupType
    let isPrivateEvent: Bool
    
    enum GroupType: String, CaseIterable, Codable {
        case casual = "casual"
        case business = "business"
        case birthday = "birthday"
        case bachelor = "bachelor"
        case corporate = "corporate"
        case lesson = "lesson"
        case tournament = "tournament"
        
        var displayName: String {
            switch self {
            case .casual: return "Casual Fun"
            case .business: return "Business Event"
            case .birthday: return "Birthday Party"
            case .bachelor: return "Bachelor/Bachelorette"
            case .corporate: return "Corporate Event"
            case .lesson: return "Golf Lesson"
            case .tournament: return "Tournament"
            }
        }
    }
    
    var averageSkillLevel: SkillLevel {
        guard !skillLevels.isEmpty else { return .beginner }
        let totalLevel = skillLevels.map { $0.numericValue }.reduce(0, +)
        let averageValue = totalLevel / skillLevels.count
        return SkillLevel.fromNumericValue(averageValue)
    }
    
    var requiresInstructor: Bool {
        groupType == .lesson || skillLevels.contains(.beginner)
    }
}

struct PlayerInfo: Identifiable, Codable {
    let id = UUID()
    let name: String
    let skillLevel: SkillLevel
    let isLeftHanded: Bool
    let preferredClubs: [String]
    let medicalConditions: [String]
    
    enum CodingKeys: String, CodingKey {
        case name, skillLevel, isLeftHanded, preferredClubs, medicalConditions
    }
}

enum SkillLevel: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case professional = "professional"
    
    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .professional: return "Professional"
        }
    }
    
    var numericValue: Int {
        switch self {
        case .beginner: return 1
        case .intermediate: return 2
        case .advanced: return 3
        case .professional: return 4
        }
    }
    
    static func fromNumericValue(_ value: Int) -> SkillLevel {
        switch value {
        case 1: return .beginner
        case 2: return .intermediate
        case 3: return .advanced
        case 4: return .professional
        default: return .beginner
        }
    }
    
    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "orange"
        case .advanced: return "red"
        case .professional: return "purple"
        }
    }
}

// MARK: - Booking Pricing
struct BookingPricing: Codable {
    let baseAmount: Double
    let memberDiscount: Double
    let promoDiscount: Double
    let taxes: Double
    let fees: Double
    let totalAmount: Double
    let depositRequired: Double?
    let depositPaid: Double?
    
    var subtotal: Double {
        baseAmount - memberDiscount - promoDiscount
    }
    
    var totalDiscount: Double {
        memberDiscount + promoDiscount
    }
    
    var hasDiscount: Bool {
        totalDiscount > 0
    }
    
    var effectiveRate: Double {
        subtotal + taxes + fees
    }
    
    var remainingBalance: Double {
        totalAmount - (depositPaid ?? 0)
    }
    
    var isFullyPaid: Bool {
        remainingBalance <= 0
    }
    
    var depositStatus: String {
        guard let required = depositRequired else { return "No deposit required" }
        let paid = depositPaid ?? 0
        
        if paid >= required {
            return "Deposit paid"
        } else if paid > 0 {
            return "Partial deposit paid"
        } else {
            return "Deposit pending"
        }
    }
}

// MARK: - Payment Information
struct PaymentInfo: Codable {
    let paymentId: String
    let method: PaymentMethod
    let status: PaymentStatus
    let amount: Double
    let currency: String
    let processedAt: Date?
    let transactionId: String?
    let lastFourDigits: String?
    let cardBrand: String?
    let refundAmount: Double?
    let refundedAt: Date?
    
    enum PaymentMethod: String, CaseIterable, Codable {
        case creditCard = "credit_card"
        case debitCard = "debit_card"
        case applePay = "apple_pay"
        case googlePay = "google_pay"
        case giftCard = "gift_card"
        case cash = "cash"
        
        var displayName: String {
            switch self {
            case .creditCard: return "Credit Card"
            case .debitCard: return "Debit Card"
            case .applePay: return "Apple Pay"
            case .googlePay: return "Google Pay"
            case .giftCard: return "Gift Card"
            case .cash: return "Cash"
            }
        }
        
        var icon: String {
            switch self {
            case .creditCard, .debitCard: return "creditcard"
            case .applePay: return "applelogo"
            case .googlePay: return "g.circle"
            case .giftCard: return "gift"
            case .cash: return "dollarsign.circle"
            }
        }
    }
    
    enum PaymentStatus: String, CaseIterable, Codable {
        case pending = "pending"
        case processing = "processing"
        case completed = "completed"
        case failed = "failed"
        case cancelled = "cancelled"
        case refunded = "refunded"
        case partiallyRefunded = "partially_refunded"
        
        var displayName: String {
            switch self {
            case .pending: return "Pending"
            case .processing: return "Processing"
            case .completed: return "Completed"
            case .failed: return "Failed"
            case .cancelled: return "Cancelled"
            case .refunded: return "Refunded"
            case .partiallyRefunded: return "Partially Refunded"
            }
        }
        
        var isSuccessful: Bool {
            self == .completed
        }
        
        var isFinal: Bool {
            switch self {
            case .completed, .failed, .cancelled, .refunded: return true
            default: return false
            }
        }
    }
    
    var maskedCardNumber: String {
        guard let lastFour = lastFourDigits else { return "****" }
        return "**** **** **** \(lastFour)"
    }
    
    var isRefundable: Bool {
        status == .completed && refundAmount == nil
    }
    
    var refundableAmount: Double {
        amount - (refundAmount ?? 0)
    }
}

// MARK: - Booking Extensions
extension Booking {
    
    // Booking modifications
    func withUpdatedStatus(_ newStatus: BookingStatus) -> Booking {
        var updated = self
        // In a real implementation, this would be handled by a proper data model
        return updated
    }
    
    func withCheckIn() -> Booking {
        var updated = self
        // In a real implementation, this would be handled by a proper data model
        return updated
    }
    
    func withCheckOut() -> Booking {
        var updated = self
        // In a real implementation, this would be handled by a proper data model
        return updated
    }
    
    // Validation
    var isValid: Bool {
        !customerInfo.firstName.isEmpty &&
        !customerInfo.lastName.isEmpty &&
        !customerInfo.email.isEmpty &&
        !customerInfo.phone.isEmpty &&
        partyDetails.numberOfPlayers > 0 &&
        partyDetails.numberOfPlayers <= timeSlot.maxPlayers
    }
    
    var validationErrors: [String] {
        var errors: [String] = []
        
        if customerInfo.firstName.isEmpty {
            errors.append("First name is required")
        }
        
        if customerInfo.lastName.isEmpty {
            errors.append("Last name is required")
        }
        
        if customerInfo.email.isEmpty {
            errors.append("Email is required")
        }
        
        if customerInfo.phone.isEmpty {
            errors.append("Phone number is required")
        }
        
        if partyDetails.numberOfPlayers <= 0 {
            errors.append("At least one player is required")
        }
        
        if partyDetails.numberOfPlayers > timeSlot.maxPlayers {
            errors.append("Too many players for this time slot")
        }
        
        return errors
    }
}

// MARK: - Sample Data
extension Booking {
    static let sampleBooking = Booking(
        timeSlot: TimeSlot.sampleTimeSlots.first!,
        venue: Venue.sampleVenues.first!,
        customerInfo: CustomerInfo(
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@email.com",
            phone: "(555) 123-4567",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -30, to: Date()),
            membershipNumber: "TG123456",
            emergencyContact: EmergencyContact(
                name: "Jane Doe",
                relationship: "Spouse",
                phone: "(555) 987-6543"
            )
        ),
        partyDetails: PartyDetails(
            numberOfPlayers: 3,
            players: [
                PlayerInfo(name: "John Doe", skillLevel: .intermediate, isLeftHanded: false, preferredClubs: ["Driver", "7-Iron"], medicalConditions: []),
                PlayerInfo(name: "Mike Smith", skillLevel: .beginner, isLeftHanded: true, preferredClubs: ["Driver"], medicalConditions: []),
                PlayerInfo(name: "Sarah Johnson", skillLevel: .advanced, isLeftHanded: false, preferredClubs: ["Driver", "Wedges"], medicalConditions: [])
            ],
            specialAccommodations: ["Left-handed clubs needed"],
            skillLevels: [.intermediate, .beginner, .advanced],
            groupType: .casual,
            isPrivateEvent: false
        ),
        pricing: BookingPricing(
            baseAmount: 180.0,
            memberDiscount: 27.0,
            promoDiscount: 0.0,
            taxes: 15.30,
            fees: 5.0,
            totalAmount: 173.30,
            depositRequired: 43.30,
            depositPaid: 43.30
        ),
        payment: PaymentInfo(
            paymentId: "pay_123456789",
            method: .creditCard,
            status: .completed,
            amount: 173.30,
            currency: "USD",
            processedAt: Date(),
            transactionId: "txn_987654321",
            lastFourDigits: "4242",
            cardBrand: "Visa",
            refundAmount: nil,
            refundedAt: nil
        ),
        status: .confirmed
    )
}