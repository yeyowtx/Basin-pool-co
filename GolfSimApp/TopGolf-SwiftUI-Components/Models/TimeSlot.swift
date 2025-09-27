//
//  TimeSlot.swift
//  TopGolf-Inspired Golf Sim App
//
//  Time slot model for booking system based on TopGolf analysis
//  Handles pricing tiers, availability, and member discounts
//

import Foundation

// MARK: - Time Slot Model
struct TimeSlot: Identifiable, Codable, Hashable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    let available: Bool
    let price: Double
    let tier: PricingTier
    let simulatorCount: Int
    let memberPrice: Double?
    let venueId: Int
    let date: Date
    
    // Booking constraints
    let maxPlayers: Int
    let requiresDeposit: Bool
    let depositAmount: Double?
    let cancellationDeadline: Date?
    
    // Promotional pricing
    let hasPromotion: Bool
    let promotionDiscount: Double?
    let promotionDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case startTime, endTime, available, price, tier
        case simulatorCount, memberPrice, venueId, date
        case maxPlayers, requiresDeposit, depositAmount, cancellationDeadline
        case hasPromotion, promotionDiscount, promotionDescription
    }
    
    init(startTime: Date, 
         endTime: Date, 
         available: Bool = true, 
         price: Double, 
         tier: PricingTier, 
         simulatorCount: Int = 1, 
         memberPrice: Double? = nil, 
         venueId: Int, 
         date: Date = Date(),
         maxPlayers: Int = 6,
         requiresDeposit: Bool = false,
         depositAmount: Double? = nil,
         cancellationDeadline: Date? = nil,
         hasPromotion: Bool = false,
         promotionDiscount: Double? = nil,
         promotionDescription: String? = nil) {
        
        self.startTime = startTime
        self.endTime = endTime
        self.available = available
        self.price = price
        self.tier = tier
        self.simulatorCount = simulatorCount
        self.memberPrice = memberPrice
        self.venueId = venueId
        self.date = date
        self.maxPlayers = maxPlayers
        self.requiresDeposit = requiresDeposit
        self.depositAmount = depositAmount
        self.cancellationDeadline = cancellationDeadline
        self.hasPromotion = hasPromotion
        self.promotionDiscount = promotionDiscount
        self.promotionDescription = promotionDescription
    }
    
    // MARK: - Computed Properties
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var durationInHours: Double {
        duration / 3600
    }
    
    var durationText: String {
        let hours = Int(durationInHours)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if minutes == 0 {
            return "\(hours)h"
        } else {
            return "\(hours)h \(minutes)m"
        }
    }
    
    var timeRangeText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    var startTimeText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
    
    var endTimeText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: endTime)
    }
    
    var pricePerHour: Double {
        price / durationInHours
    }
    
    var effectivePrice: Double {
        if let memberPrice = memberPrice {
            return memberPrice
        }
        
        if hasPromotion, let discount = promotionDiscount {
            return price * (1 - discount)
        }
        
        return price
    }
    
    var savings: Double? {
        if let memberPrice = memberPrice {
            return price - memberPrice
        }
        
        if hasPromotion, let discount = promotionDiscount {
            return price * discount
        }
        
        return nil
    }
    
    var savingsText: String? {
        guard let savings = savings else { return nil }
        return String(format: "Save $%.0f", savings)
    }
    
    var isBookable: Bool {
        available && startTime > Date()
    }
    
    var isPast: Bool {
        endTime <= Date()
    }
    
    var isActive: Bool {
        let now = Date()
        return now >= startTime && now <= endTime
    }
    
    var isSoon: Bool {
        let thirtyMinutesFromNow = Date().addingTimeInterval(30 * 60)
        return startTime <= thirtyMinutesFromNow && startTime > Date()
    }
    
    var statusText: String {
        if isPast {
            return "Past"
        } else if isActive {
            return "Active"
        } else if isSoon {
            return "Starting Soon"
        } else if !available {
            return "Unavailable"
        } else {
            return "Available"
        }
    }
    
    var requiresCancellationFee: Bool {
        guard let deadline = cancellationDeadline else { return false }
        return Date() > deadline
    }
    
    var simulatorCountText: String {
        if simulatorCount == 1 {
            return "1 simulator"
        } else {
            return "\(simulatorCount) simulators"
        }
    }
}

// MARK: - Pricing Tier
struct PricingTier: Codable, Hashable, Identifiable {
    let id = UUID()
    let type: PricingTierType
    let name: String
    let timeRange: String
    let color: String
    let basePrice: Double
    let memberDiscount: Double // Percentage discount for members
    
    enum CodingKeys: String, CodingKey {
        case type, name, timeRange, color, basePrice, memberDiscount
    }
    
    init(type: PricingTierType, 
         name: String? = nil, 
         timeRange: String? = nil, 
         color: String? = nil, 
         basePrice: Double, 
         memberDiscount: Double = 0.15) {
        
        self.type = type
        self.name = name ?? type.displayName
        self.timeRange = timeRange ?? type.defaultTimeRange
        self.color = color ?? type.defaultColor
        self.basePrice = basePrice
        self.memberDiscount = memberDiscount
    }
    
    var memberPrice: Double {
        basePrice * (1 - memberDiscount)
    }
    
    var isCurrentlyActive: Bool {
        type.isCurrentlyActive
    }
}

enum PricingTierType: String, CaseIterable, Codable {
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"
    case night = "night"
    case peak = "peak"
    case offPeak = "off_peak"
    case special = "special"
    
    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        case .night: return "Night"
        case .peak: return "Peak"
        case .offPeak: return "Off-Peak"
        case .special: return "Special"
        }
    }
    
    var defaultTimeRange: String {
        switch self {
        case .morning: return "OPEN - 12:00 PM"
        case .afternoon: return "12:00 PM - 5:00 PM"
        case .evening: return "5:00 PM - 10:00 PM"
        case .night: return "10:00 PM - CLOSE"
        case .peak: return "Peak Hours"
        case .offPeak: return "Off-Peak Hours"
        case .special: return "Special Event"
        }
    }
    
    var defaultColor: String {
        switch self {
        case .morning: return "green"
        case .afternoon: return "blue"
        case .evening: return "orange"
        case .night: return "red"
        case .peak: return "purple"
        case .offPeak: return "gray"
        case .special: return "yellow"
        }
    }
    
    var defaultPrice: Double {
        switch self {
        case .morning: return 36.0
        case .afternoon: return 48.0
        case .evening: return 60.0
        case .night: return 30.0
        case .peak: return 75.0
        case .offPeak: return 25.0
        case .special: return 50.0
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .morning: return 0
        case .afternoon: return 1
        case .evening: return 2
        case .night: return 3
        case .peak: return 4
        case .offPeak: return 5
        case .special: return 6
        }
    }
    
    var isCurrentlyActive: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch self {
        case .morning: return hour >= 6 && hour < 12
        case .afternoon: return hour >= 12 && hour < 17
        case .evening: return hour >= 17 && hour < 22
        case .night: return hour >= 22 || hour < 6
        case .peak: return (hour >= 17 && hour < 22) || (hour >= 12 && hour < 14)
        case .offPeak: return hour < 12 || hour >= 22
        case .special: return false // Special events are manually activated
        }
    }
    
    static func current() -> PricingTierType {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 6..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<22: return .evening
        default: return .night
        }
    }
}

// MARK: - Time Slot Generation
extension TimeSlot {
    
    /// Generate time slots for a given date and venue
    static func generateTimeSlots(for date: Date, venue: Venue, simulatorCount: Int = 4) -> [TimeSlot] {
        var slots: [TimeSlot] = []
        let calendar = Calendar.current
        
        // Get operating hours for the day
        let weekday = calendar.component(.weekday, from: date)
        guard let operatingHours = venue.hours.first(where: { $0.dayOfWeek == weekday }),
              let firstTimeSlot = operatingHours.times.first,
              let openTime = firstTimeSlot.openTime,
              let closeTime = firstTimeSlot.closeTime else {
            return slots
        }
        
        // Create opening time for the date
        guard var currentTime = calendar.date(bySettingHour: openTime.hour, 
                                             minute: openTime.minute, 
                                             second: 0, 
                                             of: date) else {
            return slots
        }
        
        // Create closing time
        var endOfDay = calendar.date(bySettingHour: closeTime.hour,
                                    minute: closeTime.minute,
                                    second: 0,
                                    of: date) ?? date
        
        // Handle next day closing
        if closeTime.hour < openTime.hour {
            endOfDay = calendar.date(byAdding: .day, value: 1, to: endOfDay) ?? endOfDay
        }
        
        // Generate hourly slots
        while currentTime < endOfDay {
            guard let slotEndTime = calendar.date(byAdding: .hour, value: 1, to: currentTime) else {
                break
            }
            
            // Don't create slots that end after closing
            if slotEndTime > endOfDay {
                break
            }
            
            let tier = determinePricingTier(for: currentTime)
            let basePrice = tier.basePrice
            let memberPrice = tier.memberPrice
            
            // Simulate availability (in real app, this would come from backend)
            let isAvailable = simulateAvailability(for: currentTime, date: date)
            let availableSimulators = isAvailable ? Int.random(in: 1...simulatorCount) : 0
            
            let slot = TimeSlot(
                startTime: currentTime,
                endTime: slotEndTime,
                available: isAvailable,
                price: basePrice,
                tier: tier,
                simulatorCount: availableSimulators,
                memberPrice: memberPrice,
                venueId: venue.id,
                date: date,
                maxPlayers: 6,
                requiresDeposit: basePrice >= 50,
                depositAmount: basePrice >= 50 ? basePrice * 0.25 : nil,
                cancellationDeadline: calendar.date(byAdding: .hour, value: -2, to: currentTime)
            )
            
            slots.append(slot)
            
            // Move to next hour
            currentTime = slotEndTime
        }
        
        return slots
    }
    
    private static func determinePricingTier(for time: Date) -> PricingTier {
        let hour = Calendar.current.component(.hour, from: time)
        let tierType = PricingTierType.current()
        
        return PricingTier(
            type: tierType,
            basePrice: tierType.defaultPrice
        )
    }
    
    private static func simulateAvailability(for time: Date, date: Date) -> Bool {
        // Don't allow booking in the past
        if time <= Date() {
            return false
        }
        
        // Simulate realistic availability patterns
        let hour = Calendar.current.component(.hour, from: time)
        let dayOfWeek = Calendar.current.component(.weekday, from: date)
        
        // Weekend evenings are less available
        if [1, 7].contains(dayOfWeek) && hour >= 17 && hour <= 20 {
            return Double.random(in: 0...1) > 0.3
        }
        
        // Weekday evenings moderately available
        if [2, 3, 4, 5, 6].contains(dayOfWeek) && hour >= 17 && hour <= 20 {
            return Double.random(in: 0...1) > 0.2
        }
        
        // Mornings and late nights generally available
        if hour < 12 || hour > 21 {
            return Double.random(in: 0...1) > 0.1
        }
        
        // Afternoons generally available
        return Double.random(in: 0...1) > 0.15
    }
}

// MARK: - Sample Data
extension TimeSlot {
    static let sampleTimeSlots: [TimeSlot] = {
        let today = Date()
        let calendar = Calendar.current
        var slots: [TimeSlot] = []
        
        // Generate slots for next 7 days
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            
            // Generate slots for each hour from 9 AM to 9 PM
            for hour in 9...21 {
                guard let startTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date),
                      let endTime = calendar.date(byAdding: .hour, value: 1, to: startTime) else {
                    continue
                }
                
                let tierType: PricingTierType
                switch hour {
                case 9..<12: tierType = .morning
                case 12..<17: tierType = .afternoon
                case 17..<22: tierType = .evening
                default: tierType = .night
                }
                
                let tier = PricingTier(type: tierType, basePrice: tierType.defaultPrice)
                
                let slot = TimeSlot(
                    startTime: startTime,
                    endTime: endTime,
                    available: Bool.random(),
                    price: tier.basePrice,
                    tier: tier,
                    simulatorCount: Int.random(in: 1...4),
                    memberPrice: tier.memberPrice,
                    venueId: 1,
                    date: date
                )
                
                slots.append(slot)
            }
        }
        
        return slots
    }()
}