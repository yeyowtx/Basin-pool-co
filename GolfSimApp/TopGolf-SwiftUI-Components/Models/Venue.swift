//
//  Venue.swift
//  TopGolf-Inspired Golf Sim App
//
//  Venue data model based on TopGolf JSON structure analysis
//  Represents golf simulation facilities with location and operational data
//

import Foundation
import CoreLocation

// MARK: - Venue Model (From TopGolf IPA Analysis)
struct Venue: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let city: String
    let state: String
    let country: String
    let phone: String
    let address: String
    let postCode: String
    let latitude: Double
    let longitude: Double
    let timezone: String
    
    // Operational properties
    let supportsOnlineAccess: Bool
    let supportsMemberships: Bool
    let comingSoon: Bool
    let reservationLabel: String
    let reservationMaxGuests: Int
    
    // Hours and availability
    let timeAvailable: [TimeAvailability]
    let hours: [OperatingHours]
    
    // Features and offerings
    let gamesListLink: String?
    let foodMenu: String?
    let reservationEventLink: String?
    
    // Pricing and promotions
    let pricing: VenuePricing
    let defaultDepositPercentage: Int
    let heroDiscountTitle: String?
    let heroDiscountText: String?
    let promoDiscountTitle: String?
    let promoDiscountText: String?
    let promoDiscountDays: [Int]
    
    // Weather information
    let temperature: WeatherInfo?
    
    // System configuration
    let reservationSystem: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "siteId"
        case name, city, state, country, phone, address, postCode
        case latitude, longitude, timezone
        case supportsOnlineAccess, supportsMemberships, comingSoon
        case reservationLabel, reservationMaxGuests, timeAvailable, hours
        case gamesListLink, foodMenu, reservationEventLink
        case pricing, defaultDepositPercentage
        case heroDiscountTitle, heroDiscountText
        case promoDiscountTitle, promoDiscountText, promoDiscountDays
        case temperature, reservationSystem
    }
    
    // MARK: - Computed Properties
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var fullAddress: String {
        "\(address), \(city), \(state) \(postCode)"
    }
    
    var isOperational: Bool {
        supportsOnlineAccess && !comingSoon
    }
    
    var currentOperatingHours: OperatingHours? {
        let today = Calendar.current.component(.weekday, from: Date())
        return hours.first { $0.dayOfWeek == today }
    }
    
    var isCurrentlyOpen: Bool {
        guard let currentHours = currentOperatingHours,
              let openTime = currentHours.openTime,
              let closeTime = currentHours.closeTime else {
            return false
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        let todayOpen = calendar.date(bySettingHour: openTime.hour, 
                                     minute: openTime.minute, 
                                     second: 0, 
                                     of: now) ?? now
        
        var todayClose = calendar.date(bySettingHour: closeTime.hour,
                                      minute: closeTime.minute,
                                      second: 0,
                                      of: now) ?? now
        
        // Handle next day closing (e.g., close at 1:00 AM)
        if closeTime.hour < openTime.hour {
            todayClose = calendar.date(byAdding: .day, value: 1, to: todayClose) ?? todayClose
        }
        
        return now >= todayOpen && now <= todayClose
    }
    
    var subtitle: String {
        if comingSoon {
            return "Coming Soon"
        } else if !supportsOnlineAccess {
            return "Walk-ins Only"
        } else {
            return "\(city), \(state)"
        }
    }
    
    var statusColor: String {
        if comingSoon {
            return "orange"
        } else if !supportsOnlineAccess {
            return "gray"
        } else if isCurrentlyOpen {
            return "green"
        } else {
            return "red"
        }
    }
}

// MARK: - Supporting Models

struct TimeAvailability: Codable, Hashable {
    let days: String
    let hours: String
    
    var displayText: String {
        "\(days): \(hours)"
    }
}

struct OperatingHours: Codable, Hashable {
    let dayOfWeek: Int  // 1 = Sunday, 2 = Monday, etc.
    let times: [TimeSlot]
    
    var openTime: TimeComponents? {
        times.first?.openTime
    }
    
    var closeTime: TimeComponents? {
        times.first?.closeTime
    }
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.weekdaySymbols = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return formatter.weekdaySymbols[dayOfWeek - 1]
    }
    
    struct TimeSlot: Codable, Hashable {
        let open: String    // "09:00"
        let close: String   // "00:00"
        
        var openTime: TimeComponents? {
            TimeComponents(from: open)
        }
        
        var closeTime: TimeComponents? {
            TimeComponents(from: close)
        }
        
        var displayHours: String {
            guard let openTime = openTime,
                  let closeTime = closeTime else {
                return "\(open) - \(close)"
            }
            
            let openDisplay = openTime.hour == 0 ? "12:00 AM" : 
                             openTime.hour <= 12 ? "\(openTime.hour):\(String(format: "%02d", openTime.minute)) AM" :
                             "\(openTime.hour - 12):\(String(format: "%02d", openTime.minute)) PM"
            
            let closeDisplay = closeTime.hour == 0 ? "12:00 AM" :
                              closeTime.hour <= 12 ? "\(closeTime.hour):\(String(format: "%02d", closeTime.minute)) AM" :
                              "\(closeTime.hour - 12):\(String(format: "%02d", closeTime.minute)) PM"
            
            return "\(openDisplay) - \(closeDisplay)"
        }
    }
}

struct TimeComponents: Codable, Hashable {
    let hour: Int
    let minute: Int
    
    init?(from timeString: String) {
        let components = timeString.split(separator: ":").compactMap { Int($0) }
        guard components.count == 2 else { return nil }
        self.hour = components[0]
        self.minute = components[1]
    }
    
    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
}

struct WeatherInfo: Codable, Hashable {
    let icon: String
    let temperature: Int?
    let condition: String?
    
    var displayTemperature: String {
        guard let temp = temperature else { return "N/A" }
        return "\(temp)°F"
    }
}

// MARK: - Venue Pricing Structure
struct VenuePricing: Codable, Hashable {
    let siteSystem: Int
    let siteState: Int
    let pricingStructure: Int
    let guestTypes: [GuestType]
    
    var defaultGuestType: GuestType? {
        guestTypes.first { $0.guestType == 1 }
    }
    
    var memberGuestType: GuestType? {
        guestTypes.first { $0.guestType == 2 }
    }
}

struct GuestType: Codable, Hashable, Identifiable {
    let id = UUID()
    let guestType: Int
    let label: String
    let floors: [FloorPricing]
    
    var isDefault: Bool {
        guestType == 1
    }
    
    var isMember: Bool {
        guestType == 2
    }
    
    var displayName: String {
        switch guestType {
        case 1: return "Guest"
        case 2: return "Member"
        default: return label.capitalized
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case guestType, label, floors
    }
}

struct FloorPricing: Codable, Hashable, Identifiable {
    let id: Int
    let floors: String
    let floorIds: [Int]
    let pricingTiers: [PricingTierData]?
    
    var floorNumbers: [Int] {
        return floorIds.sorted()
    }
    
    var displayFloors: String {
        if floorNumbers.count == 1 {
            return "Floor \(floorNumbers[0])"
        } else {
            return "Floors \(floors)"
        }
    }
}

struct PricingTierData: Codable, Hashable, Identifiable {
    let id = UUID()
    let tier: String
    let price: Double
    let startTime: String
    let endTime: String
    let dayOfWeek: [Int]?
    
    var tierType: PricingTierType {
        PricingTierType(rawValue: tier.lowercased()) ?? .morning
    }
    
    var timeRange: String {
        "\(startTime) - \(endTime)"
    }
    
    var isActiveToday: Bool {
        guard let days = dayOfWeek else { return true }
        let today = Calendar.current.component(.weekday, from: Date())
        return days.contains(today)
    }
    
    enum CodingKeys: String, CodingKey {
        case tier, price, startTime, endTime, dayOfWeek
    }
}

enum PricingTierType: String, CaseIterable, Codable {
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"
    case night = "night"
    case peak = "peak"
    case offPeak = "off_peak"
    
    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        case .night: return "Night"
        case .peak: return "Peak"
        case .offPeak: return "Off-Peak"
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
        }
    }
}

// MARK: - Sample Data
extension Venue {
    static let sampleVenues = [
        Venue(
            id: 1,
            name: "Golf Sim Pro - Downtown",
            city: "Seattle",
            state: "Washington",
            country: "USA",
            phone: "(206) 555-0123",
            address: "123 Pine Street",
            postCode: "98101",
            latitude: 47.6062,
            longitude: -122.3321,
            timezone: "America/Los_Angeles",
            supportsOnlineAccess: true,
            supportsMemberships: true,
            comingSoon: false,
            reservationLabel: "Book Simulator",
            reservationMaxGuests: 6,
            timeAvailable: [
                TimeAvailability(days: "Mon - Thu", hours: "9:00 AM - 10:00 PM"),
                TimeAvailability(days: "Fri - Sat", hours: "9:00 AM - 11:00 PM"),
                TimeAvailability(days: "Sunday", hours: "10:00 AM - 9:00 PM")
            ],
            hours: [
                OperatingHours(dayOfWeek: 1, times: [OperatingHours.TimeSlot(open: "10:00", close: "21:00")]),
                OperatingHours(dayOfWeek: 2, times: [OperatingHours.TimeSlot(open: "09:00", close: "22:00")]),
                OperatingHours(dayOfWeek: 3, times: [OperatingHours.TimeSlot(open: "09:00", close: "22:00")]),
                OperatingHours(dayOfWeek: 4, times: [OperatingHours.TimeSlot(open: "09:00", close: "22:00")]),
                OperatingHours(dayOfWeek: 5, times: [OperatingHours.TimeSlot(open: "09:00", close: "22:00")]),
                OperatingHours(dayOfWeek: 6, times: [OperatingHours.TimeSlot(open: "09:00", close: "23:00")]),
                OperatingHours(dayOfWeek: 7, times: [OperatingHours.TimeSlot(open: "09:00", close: "23:00")])
            ],
            gamesListLink: nil,
            foodMenu: nil,
            reservationEventLink: nil,
            pricing: VenuePricing(
                siteSystem: 2,
                siteState: 1,
                pricingStructure: 1,
                guestTypes: [
                    GuestType(guestType: 1, label: "guest", floors: []),
                    GuestType(guestType: 2, label: "member", floors: [])
                ]
            ),
            defaultDepositPercentage: 25,
            heroDiscountTitle: "Member Discount",
            heroDiscountText: "Members receive 15% off all simulator sessions",
            promoDiscountTitle: nil,
            promoDiscountText: nil,
            promoDiscountDays: [],
            temperature: WeatherInfo(icon: "sun", temperature: 72, condition: "Clear"),
            reservationSystem: 5
        ),
        
        Venue(
            id: 2,
            name: "Evergreen Golf Academy",
            city: "Redmond", 
            state: "Washington",
            country: "USA",
            phone: "(425) 555-0456",
            address: "456 Golf Way",
            postCode: "98052",
            latitude: 47.6740,
            longitude: -122.1215,
            timezone: "America/Los_Angeles",
            supportsOnlineAccess: true,
            supportsMemberships: true,
            comingSoon: false,
            reservationLabel: "Book Session",
            reservationMaxGuests: 4,
            timeAvailable: [
                TimeAvailability(days: "Daily", hours: "8:00 AM - 9:00 PM")
            ],
            hours: [
                OperatingHours(dayOfWeek: 1, times: [OperatingHours.TimeSlot(open: "08:00", close: "21:00")]),
                OperatingHours(dayOfWeek: 2, times: [OperatingHours.TimeSlot(open: "08:00", close: "21:00")]),
                OperatingHours(dayOfWeek: 3, times: [OperatingHours.TimeSlot(open: "08:00", close: "21:00")]),
                OperatingHours(dayOfWeek: 4, times: [OperatingHours.TimeSlot(open: "08:00", close: "21:00")]),
                OperatingHours(dayOfWeek: 5, times: [OperatingHours.TimeSlot(open: "08:00", close: "21:00")]),
                OperatingHours(dayOfWeek: 6, times: [OperatingHours.TimeSlot(open: "08:00", close: "21:00")]),
                OperatingHours(dayOfWeek: 7, times: [OperatingHours.TimeSlot(open: "08:00", close: "21:00")])
            ],
            gamesListLink: nil,
            foodMenu: nil,
            reservationEventLink: nil,
            pricing: VenuePricing(
                siteSystem: 2,
                siteState: 1,
                pricingStructure: 1,
                guestTypes: [
                    GuestType(guestType: 1, label: "guest", floors: []),
                    GuestType(guestType: 2, label: "member", floors: [])
                ]
            ),
            defaultDepositPercentage: 0,
            heroDiscountTitle: nil,
            heroDiscountText: nil,
            promoDiscountTitle: "New Member Special",
            promoDiscountText: "First month free with annual membership",
            promoDiscountDays: [],
            temperature: WeatherInfo(icon: "cloud", temperature: 68, condition: "Partly Cloudy"),
            reservationSystem: 5
        )
    ]
}