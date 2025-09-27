//
//  Colors+Extensions.swift
//  TopGolf-Inspired Golf Sim App
//
//  Complete color system extracted from TopGolf IPA analysis
//  Includes exact TopGolf colors + golf simulation adaptations for legal differentiation
//

import SwiftUI

// MARK: - TopGolf Color System (Extracted from Assets.car)
extension Color {
    
    // MARK: - Primary TopGolf Brand Colors
    static let topgolfBlue = Color(hex: "0066CC")
    static let topgolfOrange = Color(hex: "FF6B00") 
    static let topgolfGreen = Color(hex: "00A651")
    static let topgolfRed = Color(hex: "E31E24")
    static let topgolfYellow = Color(hex: "FFD200")
    
    // MARK: - TopGolf Neutral Colors
    static let topgolfDarkGrey = Color(hex: "2C2C2C")
    static let topgolfMediumGrey = Color(hex: "6B6B6B")
    static let topgolfLightGrey = Color(hex: "F5F5F5")
    static let topgolfOffWhite = Color(hex: "FAFAFA")
    static let topgolfWhite = Color(hex: "FFFFFF")
    
    // MARK: - TopGolf Semantic Colors
    static let topgolfSuccess = Color(hex: "28A745")
    static let topgolfWarning = Color(hex: "FFC107")
    static let topgolfError = Color(hex: "DC3545")
    static let topgolfInfo = Color(hex: "17A2B8")
    
    // MARK: - TopGolf Pricing Tier Colors
    static let morningTierColor = Color(hex: "00A651")     // Green
    static let afternoonTierColor = Color(hex: "0066CC")   // Blue
    static let eveningTierColor = Color(hex: "FF6B00")     // Orange
    static let nightTierColor = Color(hex: "E31E24")       // Red
    
    // MARK: - TopGolf Membership Colors
    static let guestMemberColor = Color(hex: "6B6B6B")     // Medium Grey
    static let basicMemberColor = Color(hex: "0066CC")     // Blue
    static let premiumMemberColor = Color(hex: "FF6B00")   // Orange
    static let platinumMemberColor = Color(hex: "2C2C2C")  // Dark Grey
    
    // MARK: - Golf Simulation Adaptations (Legal Differentiation)
    // Using golf course inspired colors for differentiation
    static let evergreenPrimary = Color(hex: "248A3D")     // Golf course green
    static let evergreenSecondary = Color(hex: "1C7330")   // Darker green
    static let evergreenLight = Color(hex: "4CAF50")       // Light green
    static let evergreenAccent = Color(hex: "C9A961")      // Golf tee accent
    
    // Golf simulation semantic colors
    static let golfSimSuccess = Color.evergreenPrimary
    static let golfSimWarning = Color.evergreenAccent
    static let golfSimError = Color(hex: "D32F2F")
    static let golfSimInfo = Color(hex: "1976D2")
    
    // MARK: - Background Colors
    static let backgroundPrimary = Color.topgolfWhite
    static let backgroundSecondary = Color.topgolfLightGrey
    static let backgroundTertiary = Color.topgolfOffWhite
    
    // MARK: - Text Colors
    static let textPrimary = Color.topgolfDarkGrey
    static let textSecondary = Color.topgolfMediumGrey
    static let textTertiary = Color(hex: "A0A0A0")
    static let textInverse = Color.topgolfWhite
    
    // MARK: - Interactive Colors
    static let buttonPrimary = Color.topgolfBlue
    static let buttonSecondary = Color.topgolfOrange
    static let buttonDisabled = Color.topgolfMediumGrey
    static let buttonDestructive = Color.topgolfError
    
    // Golf sim button colors (for differentiation)
    static let golfButtonPrimary = Color.evergreenPrimary
    static let golfButtonSecondary = Color.evergreenAccent
    
    // MARK: - Border Colors
    static let borderPrimary = Color.topgolfMediumGrey.opacity(0.3)
    static let borderSecondary = Color.topgolfLightGrey
    static let borderActive = Color.topgolfBlue
    
    // MARK: - Shadow Colors
    static let shadowDefault = Color.black.opacity(0.1)
    static let shadowElevated = Color.black.opacity(0.15)
    static let shadowPressed = Color.black.opacity(0.2)
    
    // MARK: - Hex Color Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // MARK: - Color Utilities
    var hexString: String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(red * 255)),
            lroundf(Float(green * 255)),
            lroundf(Float(blue * 255))
        )
    }
}

// MARK: - Color Schemes
struct TopgolfColorScheme {
    static let light = TopgolfColorScheme(
        primary: .topgolfBlue,
        secondary: .topgolfOrange,
        background: .backgroundPrimary,
        surface: .backgroundSecondary,
        onPrimary: .textInverse,
        onSecondary: .textInverse,
        onBackground: .textPrimary,
        onSurface: .textPrimary
    )
    
    static let golfSim = TopgolfColorScheme(
        primary: .evergreenPrimary,
        secondary: .evergreenAccent,
        background: .backgroundPrimary,
        surface: .backgroundSecondary,
        onPrimary: .textInverse,
        onSecondary: .textPrimary,
        onBackground: .textPrimary,
        onSurface: .textPrimary
    )
    
    let primary: Color
    let secondary: Color
    let background: Color
    let surface: Color
    let onPrimary: Color
    let onSecondary: Color
    let onBackground: Color
    let onSurface: Color
}

// MARK: - Color Extensions for Common Use Cases
extension Color {
    
    // Pricing tier color mapping
    static func pricingTierColor(for tier: String) -> Color {
        switch tier.lowercased() {
        case "morning":
            return .morningTierColor
        case "afternoon":
            return .afternoonTierColor
        case "evening":
            return .eveningTierColor
        case "night":
            return .nightTierColor
        default:
            return .topgolfMediumGrey
        }
    }
    
    // Membership tier color mapping
    static func membershipColor(for tier: String) -> Color {
        switch tier.lowercased() {
        case "guest":
            return .guestMemberColor
        case "basic":
            return .basicMemberColor
        case "premium":
            return .premiumMemberColor
        case "platinum":
            return .platinumMemberColor
        default:
            return .topgolfMediumGrey
        }
    }
    
    // Availability status colors
    static func availabilityColor(isAvailable: Bool) -> Color {
        return isAvailable ? .topgolfSuccess : .topgolfError
    }
    
    // Golf skill level colors
    static func skillLevelColor(level: Int) -> Color {
        switch level {
        case 1...3:
            return .topgolfError
        case 4...6:
            return .topgolfWarning
        case 7...8:
            return .evergreenPrimary
        case 9...10:
            return .topgolfSuccess
        default:
            return .topgolfMediumGrey
        }
    }
}