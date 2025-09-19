import SwiftUI

// MARK: - Bay Extensions
// Enhanced Bay model properties for premium UI components

extension Bay {
    var number: Int { id }
    var location: String { "Floor \(id <= 5 ? "1" : "2")" }
    var level: BayLevel { 
        switch id {
        case 1, 2, 3, 4, 5:
            return .standard
        case 6, 7, 8:
            return .premium
        case 9, 10:
            return .vip
        default:
            return .standard
        }
    }
    
    var equipment: [String] {
        switch level {
        case .standard:
            return ["TrackMan", "Golf Clubs", "Balls"]
        case .premium:
            return ["TrackMan Pro", "Premium Clubs", "Pro Balls", "Video Analysis"]
        case .vip:
            return ["TrackMan Pro+", "Luxury Clubs", "Pro Balls", "Video Analysis", "Personal Service"]
        }
    }
    
    var pricing: BayPricing {
        switch level {
        case .standard:
            return BayPricing(hourlyRate: 45, peakRate: 65, memberDiscount: 0.15)
        case .premium:
            return BayPricing(hourlyRate: 75, peakRate: 95, memberDiscount: 0.20)
        case .vip:
            return BayPricing(hourlyRate: 120, peakRate: 150, memberDiscount: 0.25)
        }
    }
    
    static let sampleBays: [Bay] = {
        var bays = mockBays()
        return Array(bays.prefix(10))
    }()
}

// MARK: - Bay Level
enum BayLevel: String, CaseIterable {
    case standard = "Standard"
    case premium = "Premium"
    case vip = "VIP"
    
    var displayName: String { rawValue }
    
    var themeColor: Color {
        switch self {
        case .standard:
            return Color.extendedTheme.guest
        case .premium:
            return Color.extendedTheme.member
        case .vip:
            return Color.extendedTheme.vip
        }
    }
}

// MARK: - Bay Pricing
struct BayPricing {
    let hourlyRate: Decimal
    let peakRate: Decimal
    let memberDiscount: Decimal
    
    init(hourlyRate: Double, peakRate: Double, memberDiscount: Double) {
        self.hourlyRate = Decimal(hourlyRate)
        self.peakRate = Decimal(peakRate)
        self.memberDiscount = Decimal(memberDiscount)
    }
    
    func finalRate(isPeak: Bool = false, isMember: Bool = false) -> Decimal {
        let baseRate = isPeak ? peakRate : hourlyRate
        return isMember ? baseRate * (1 - memberDiscount) : baseRate
    }
}

// MARK: - Enhanced Bay Status
extension BayStatus {
    var displayName: String {
        switch self {
        case .available:
            return "Available"
        case .occupied:
            return "Occupied"
        case .yours:
            return "Your Bay"
        case .waiting:
            return "Wait List"
        }
    }
    
    var systemImage: String {
        switch self {
        case .available:
            return "checkmark.circle.fill"
        case .occupied:
            return "xmark.circle.fill"
        case .yours:
            return "person.circle.fill"
        case .waiting:
            return "clock.circle.fill"
        }
    }
    
    var statusDescription: String {
        switch self {
        case .available:
            return "Ready to book"
        case .occupied:
            return "Currently in use"
        case .yours:
            return "Your reservation"
        case .waiting:
            return "Join waitlist"
        }
    }
}

