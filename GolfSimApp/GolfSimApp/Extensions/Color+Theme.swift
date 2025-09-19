import SwiftUI

extension Color {
    // Golf Sim App Color Scheme
    static let theme = ColorTheme()
}

struct ColorTheme {
    // Evergreen Golf Club Brand Colors
    let evergreenPrimary = Color(hex: "#248A3D")    // Main green - #248A3D
    let evergreenSecondary = Color(hex: "#2d5016")  // Dark green - #2d5016
    let evergreenLight = Color(hex: "#E5F8E9")      // Light green background
    let evergreenAccent = Color(hex: "#3a6b1c")     // Medium green accent
    
    // Primary Colors (Updated to Evergreen theme)
    let primary = Color(hex: "#248A3D")     // Evergreen primary
    let secondary = Color(hex: "#007AFF")   // iOS blue for secondary actions
    let warning = Color(hex: "#FF9500")     // Orange - Wait times
    let error = Color(hex: "#FF3B30")       // Red - Occupied/Errors
    
    // Semantic Colors (Updated to Evergreen theme)
    let available = Color(hex: "#248A3D")   // Evergreen primary
    let occupied = Color(hex: "#8E8E93")    // Gray for occupied
    let yourBooking = Color(hex: "#248A3D") // Evergreen primary for your bays
    let waiting = Color(hex: "#FF9500")     // Orange
    
    // Membership Colors
    let guest = Color.gray
    let member = Color(hex: "#248A3D")      // Evergreen primary
    let premium = Color(hex: "#2d5016")     // Evergreen dark
    
    // UI Colors
    let background = Color(.systemBackground)
    let cardBackground = Color(.systemBackground)
    let groupedBackground = Color(.systemGroupedBackground)
    let lightBackground = Color(hex: "#E5F8E9")  // Evergreen light for cards
}

// Helper extension for hex colors
extension Color {
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Bay Status Colors
extension BayStatus {
    var themeColor: Color {
        switch self {
        case .available:
            return Color.theme.available
        case .occupied:
            return Color.theme.occupied
        case .yours:
            return Color.theme.yourBooking
        case .waiting:
            return Color.theme.waiting
        }
    }
}

// Membership Colors
extension MembershipType {
    var themeColor: Color {
        switch self {
        case .guest:
            return Color.theme.guest
        case .member:
            return Color.theme.member
        case .premium:
            return Color.theme.premium
        }
    }
}