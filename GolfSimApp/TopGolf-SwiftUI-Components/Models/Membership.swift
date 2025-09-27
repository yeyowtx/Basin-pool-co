//
//  Membership.swift
//  TopGolf-Inspired Golf Sim App
//
//  Membership model based on TopGolf structure
//  Handles member tiers, benefits, and pricing
//

import Foundation

// MARK: - Membership Model
struct Membership: Identifiable, Codable, Hashable {
    let id = UUID()
    let type: MembershipType
    let name: String
    let description: String
    let benefits: [MembershipBenefit]
    let pricing: MembershipPricing
    let tier: Int
    let color: String
    let badgeIcon: String
    
    // Booking privileges
    let advanceBookingDays: Int
    let priorityBooking: Bool
    let sessionDiscount: Double // Percentage discount
    let freeSessionsPerMonth: Int
    let rolloverSessions: Bool
    
    // Additional perks
    let freeEquipmentRental: Bool
    let guestPasses: Int
    let instructorDiscount: Double
    let eventAccess: Bool
    let conciergeService: Bool
    
    enum CodingKeys: String, CodingKey {
        case type, name, description, benefits, pricing, tier, color, badgeIcon
        case advanceBookingDays, priorityBooking, sessionDiscount, freeSessionsPerMonth, rolloverSessions
        case freeEquipmentRental, guestPasses, instructorDiscount, eventAccess, conciergeService
    }
    
    init(type: MembershipType,
         name: String? = nil,
         description: String? = nil,
         benefits: [MembershipBenefit] = [],
         pricing: MembershipPricing,
         tier: Int? = nil,
         color: String? = nil,
         badgeIcon: String? = nil,
         advanceBookingDays: Int = 7,
         priorityBooking: Bool = false,
         sessionDiscount: Double = 0.0,
         freeSessionsPerMonth: Int = 0,
         rolloverSessions: Bool = false,
         freeEquipmentRental: Bool = false,
         guestPasses: Int = 0,
         instructorDiscount: Double = 0.0,
         eventAccess: Bool = false,
         conciergeService: Bool = false) {
        
        self.type = type
        self.name = name ?? type.displayName
        self.description = description ?? type.defaultDescription
        self.benefits = benefits.isEmpty ? type.defaultBenefits : benefits
        self.pricing = pricing
        self.tier = tier ?? type.tierLevel
        self.color = color ?? type.defaultColor
        self.badgeIcon = badgeIcon ?? type.defaultIcon
        self.advanceBookingDays = advanceBookingDays
        self.priorityBooking = priorityBooking
        self.sessionDiscount = sessionDiscount
        self.freeSessionsPerMonth = freeSessionsPerMonth
        self.rolloverSessions = rolloverSessions
        self.freeEquipmentRental = freeEquipmentRental
        self.guestPasses = guestPasses
        self.instructorDiscount = instructorDiscount
        self.eventAccess = eventAccess
        self.conciergeService = conciergeService
    }
    
    // MARK: - Computed Properties
    
    var isGuest: Bool {
        type == .guest
    }
    
    var isPaid: Bool {
        !isGuest
    }
    
    var monthlyValue: Double? {
        pricing.monthlyPrice
    }
    
    var annualValue: Double? {
        pricing.annualPrice
    }
    
    var savings: Double? {
        guard let monthly = monthlyValue, let annual = annualValue else { return nil }
        return (monthly * 12) - annual
    }
    
    var savingsPercentage: Double? {
        guard let monthly = monthlyValue, let savings = savings else { return nil }
        return savings / (monthly * 12) * 100
    }
    
    var displayPrice: String {
        if let monthly = monthlyValue {
            return String(format: "$%.0f/month", monthly)
        } else {
            return "Free"
        }
    }
    
    var hasBookingPrivileges: Bool {
        priorityBooking || advanceBookingDays > 7
    }
    
    var totalBenefitsCount: Int {
        benefits.count
    }
    
    var premiumBenefitsCount: Int {
        benefits.filter { $0.isPremium }.count
    }
}

// MARK: - Membership Type Enum
enum MembershipType: String, CaseIterable, Codable {
    case guest = "guest"
    case basic = "basic"
    case premium = "premium"
    case platinum = "platinum"
    case elite = "elite"
    
    var displayName: String {
        switch self {
        case .guest: return "Guest"
        case .basic: return "Basic"
        case .premium: return "Premium"
        case .platinum: return "Platinum"
        case .elite: return "Elite"
        }
    }
    
    var defaultDescription: String {
        switch self {
        case .guest: return "Pay-as-you-play access to golf simulators"
        case .basic: return "Essential membership with member pricing and basic perks"
        case .premium: return "Enhanced membership with priority booking and exclusive benefits"
        case .platinum: return "Premium membership with concierge service and maximum benefits"
        case .elite: return "Ultimate membership experience with unlimited access"
        }
    }
    
    var tierLevel: Int {
        switch self {
        case .guest: return 0
        case .basic: return 1
        case .premium: return 2
        case .platinum: return 3
        case .elite: return 4
        }
    }
    
    var defaultColor: String {
        switch self {
        case .guest: return "gray"
        case .basic: return "blue"
        case .premium: return "orange"
        case .platinum: return "black"
        case .elite: return "gold"
        }
    }
    
    var defaultIcon: String {
        switch self {
        case .guest: return "person"
        case .basic: return "star"
        case .premium: return "star.fill"
        case .platinum: return "crown"
        case .elite: return "crown.fill"
        }
    }
    
    var defaultBenefits: [MembershipBenefit] {
        switch self {
        case .guest:
            return [
                MembershipBenefit(title: "Pay-per-session pricing", description: "Access to all simulators", isPremium: false),
                MembershipBenefit(title: "Basic customer support", description: "Standard assistance", isPremium: false)
            ]
        case .basic:
            return [
                MembershipBenefit(title: "Member pricing", description: "15% off all sessions", isPremium: false),
                MembershipBenefit(title: "7-day advance booking", description: "Book up to 1 week ahead", isPremium: false),
                MembershipBenefit(title: "Session history tracking", description: "Track your progress", isPremium: false),
                MembershipBenefit(title: "Basic equipment rental", description: "Standard club rental", isPremium: false)
            ]
        case .premium:
            return [
                MembershipBenefit(title: "Premium member pricing", description: "20% off all sessions", isPremium: false),
                MembershipBenefit(title: "14-day advance booking", description: "Book up to 2 weeks ahead", isPremium: false),
                MembershipBenefit(title: "Priority booking", description: "Get first access to premium times", isPremium: true),
                MembershipBenefit(title: "Free equipment rental", description: "Complimentary club rental", isPremium: true),
                MembershipBenefit(title: "2 guest passes/month", description: "Bring friends at member rates", isPremium: true),
                MembershipBenefit(title: "Performance analytics", description: "Detailed swing analysis", isPremium: true)
            ]
        case .platinum:
            return [
                MembershipBenefit(title: "Platinum pricing", description: "25% off all sessions", isPremium: false),
                MembershipBenefit(title: "30-day advance booking", description: "Book up to 1 month ahead", isPremium: false),
                MembershipBenefit(title: "VIP priority booking", description: "First access to all time slots", isPremium: true),
                MembershipBenefit(title: "Premium equipment included", description: "Top-tier club selection", isPremium: true),
                MembershipBenefit(title: "5 guest passes/month", description: "Bring more friends", isPremium: true),
                MembershipBenefit(title: "Private lesson discount", description: "20% off instruction", isPremium: true),
                MembershipBenefit(title: "Exclusive event access", description: "Members-only tournaments", isPremium: true),
                MembershipBenefit(title: "Concierge service", description: "Personal booking assistance", isPremium: true)
            ]
        case .elite:
            return [
                MembershipBenefit(title: "Elite unlimited access", description: "Unlimited simulator sessions", isPremium: true),
                MembershipBenefit(title: "Anytime booking", description: "Book any available time", isPremium: true),
                MembershipBenefit(title: "Personal concierge", description: "Dedicated service representative", isPremium: true),
                MembershipBenefit(title: "Premium equipment suite", description: "Exclusive club access", isPremium: true),
                MembershipBenefit(title: "Unlimited guest passes", description: "Bring anyone, anytime", isPremium: true),
                MembershipBenefit(title: "Free private lessons", description: "Monthly complimentary instruction", isPremium: true),
                MembershipBenefit(title: "Elite events", description: "Exclusive elite member experiences", isPremium: true),
                MembershipBenefit(title: "Course access partnerships", description: "Preferred rates at partner courses", isPremium: true)
            ]
        }
    }
}

// MARK: - Membership Benefit
struct MembershipBenefit: Identifiable, Codable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let isPremium: Bool
    let icon: String?
    let value: String?
    
    enum CodingKeys: String, CodingKey {
        case title, description, isPremium, icon, value
    }
    
    init(title: String, description: String, isPremium: Bool = false, icon: String? = nil, value: String? = nil) {
        self.title = title
        self.description = description
        self.isPremium = isPremium
        self.icon = icon
        self.value = value
    }
    
    var displayIcon: String {
        icon ?? (isPremium ? "star.fill" : "checkmark.circle")
    }
}

// MARK: - Membership Pricing
struct MembershipPricing: Codable, Hashable {
    let monthlyPrice: Double?
    let annualPrice: Double?
    let setupFee: Double?
    let hasFreeTrial: Bool
    let trialDays: Int?
    let cancellationFee: Double?
    let promoPrice: Double?
    let promoDescription: String?
    
    init(monthlyPrice: Double? = nil,
         annualPrice: Double? = nil,
         setupFee: Double? = nil,
         hasFreeTrial: Bool = false,
         trialDays: Int? = nil,
         cancellationFee: Double? = nil,
         promoPrice: Double? = nil,
         promoDescription: String? = nil) {
        
        self.monthlyPrice = monthlyPrice
        self.annualPrice = annualPrice
        self.setupFee = setupFee
        self.hasFreeTrial = hasFreeTrial
        self.trialDays = trialDays
        self.cancellationFee = cancellationFee
        self.promoPrice = promoPrice
        self.promoDescription = promoDescription
    }
    
    var isFree: Bool {
        monthlyPrice == nil && annualPrice == nil
    }
    
    var effectiveMonthlyPrice: Double? {
        promoPrice ?? monthlyPrice
    }
    
    var hasPromotion: Bool {
        promoPrice != nil
    }
    
    var monthlySavings: Double? {
        guard let regular = monthlyPrice, let promo = promoPrice else { return nil }
        return regular - promo
    }
    
    var annualSavings: Double? {
        guard let monthly = monthlyPrice, let annual = annualPrice else { return nil }
        return (monthly * 12) - annual
    }
}

// MARK: - Member Profile
struct MemberProfile: Identifiable, Codable {
    let id = UUID()
    let userId: String
    let membership: Membership
    let joinDate: Date
    let renewalDate: Date?
    let status: MembershipStatus
    let sessionsUsed: Int
    let sessionsRemaining: Int?
    let guestPassesUsed: Int
    let guestPassesRemaining: Int
    let totalSpent: Double
    let memberNumber: String
    
    enum MembershipStatus: String, CaseIterable, Codable {
        case active = "active"
        case suspended = "suspended"
        case cancelled = "cancelled"
        case expired = "expired"
        case pendingRenewal = "pending_renewal"
        
        var displayName: String {
            switch self {
            case .active: return "Active"
            case .suspended: return "Suspended"
            case .cancelled: return "Cancelled"
            case .expired: return "Expired"
            case .pendingRenewal: return "Pending Renewal"
            }
        }
        
        var isActive: Bool {
            self == .active
        }
    }
    
    var memberSince: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: joinDate)
    }
    
    var yearsOfMembership: Int {
        Calendar.current.dateComponents([.year], from: joinDate, to: Date()).year ?? 0
    }
    
    var needsRenewal: Bool {
        guard let renewal = renewalDate else { return false }
        let thirtyDaysFromNow = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        return renewal <= thirtyDaysFromNow
    }
    
    var utilization: Double {
        guard let remaining = sessionsRemaining, remaining > 0 else { return 0 }
        let total = sessionsUsed + remaining
        return Double(sessionsUsed) / Double(total)
    }
}

// MARK: - Predefined Memberships
extension Membership {
    static let guestMembership = Membership(
        type: .guest,
        pricing: MembershipPricing()
    )
    
    static let basicMembership = Membership(
        type: .basic,
        pricing: MembershipPricing(
            monthlyPrice: 29.99,
            annualPrice: 299.99,
            hasFreeTrial: true,
            trialDays: 7
        ),
        advanceBookingDays: 7,
        sessionDiscount: 0.15,
        freeEquipmentRental: true
    )
    
    static let premiumMembership = Membership(
        type: .premium,
        pricing: MembershipPricing(
            monthlyPrice: 59.99,
            annualPrice: 599.99,
            hasFreeTrial: true,
            trialDays: 14
        ),
        advanceBookingDays: 14,
        priorityBooking: true,
        sessionDiscount: 0.20,
        freeEquipmentRental: true,
        guestPasses: 2,
        instructorDiscount: 0.10,
        eventAccess: true
    )
    
    static let platinumMembership = Membership(
        type: .platinum,
        pricing: MembershipPricing(
            monthlyPrice: 99.99,
            annualPrice: 999.99,
            hasFreeTrial: true,
            trialDays: 30
        ),
        advanceBookingDays: 30,
        priorityBooking: true,
        sessionDiscount: 0.25,
        freeSessionsPerMonth: 2,
        rolloverSessions: true,
        freeEquipmentRental: true,
        guestPasses: 5,
        instructorDiscount: 0.20,
        eventAccess: true,
        conciergeService: true
    )
    
    static let eliteMembership = Membership(
        type: .elite,
        pricing: MembershipPricing(
            monthlyPrice: 199.99,
            annualPrice: 1999.99,
            hasFreeTrial: true,
            trialDays: 30
        ),
        advanceBookingDays: 365,
        priorityBooking: true,
        sessionDiscount: 1.0, // 100% - unlimited sessions
        freeSessionsPerMonth: -1, // Unlimited
        rolloverSessions: true,
        freeEquipmentRental: true,
        guestPasses: -1, // Unlimited
        instructorDiscount: 1.0, // Free lessons
        eventAccess: true,
        conciergeService: true
    )
    
    static let allMemberships: [Membership] = [
        guestMembership,
        basicMembership,
        premiumMembership,
        platinumMembership,
        eliteMembership
    ]
}