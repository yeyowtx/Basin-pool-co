import SwiftUI

// MARK: - Extended Color System
// Comprehensive color system for Golf Sim App

extension Color {
    // MARK: - Extended Theme Colors
    static let extendedTheme = ExtendedColorTheme()
}

struct ExtendedColorTheme {
    // MARK: - Base Palette
    let evergreenPrimary = Color(hex: "#248A3D")
    let evergreenSecondary = Color(hex: "#2d5016")
    let evergreenLight = Color(hex: "#E5F8E9")
    let evergreenAccent = Color(hex: "#3a6b1c")
    
    // MARK: - Semantic Colors
    let success = Color(hex: "#248A3D")
    let warning = Color(hex: "#FF9500")
    let error = Color(hex: "#FF3B30")
    let info = Color(hex: "#007AFF")
    
    // MARK: - Status Colors
    let available = Color(hex: "#248A3D")
    let occupied = Color(hex: "#8E8E93")
    let pending = Color(hex: "#FF9500")
    let cancelled = Color(hex: "#FF3B30")
    let confirmed = Color(hex: "#34C759")
    
    // MARK: - Priority Colors
    let priorityLow = Color(hex: "#34C759")
    let priorityMedium = Color(hex: "#FF9500")
    let priorityHigh = Color(hex: "#FF3B30")
    let priorityCritical = Color(hex: "#AF52DE")
    
    // MARK: - Membership Tier Colors
    let guest = Color(hex: "#8E8E93")
    let member = Color(hex: "#248A3D")
    let premium = Color(hex: "#2d5016")
    let vip = Color(hex: "#AF52DE")
    
    // MARK: - Equipment Status Colors
    let equipmentActive = Color(hex: "#34C759")
    let equipmentMaintenance = Color(hex: "#FF9500")
    let equipmentInactive = Color(hex: "#8E8E93")
    let equipmentError = Color(hex: "#FF3B30")
    
    // MARK: - Rating Colors
    let rating1 = Color(hex: "#FF3B30")
    let rating2 = Color(hex: "#FF9500")
    let rating3 = Color(hex: "#FFCC00")
    let rating4 = Color(hex: "#30D158")
    let rating5 = Color(hex: "#248A3D")
    
    // MARK: - Time-based Colors
    let morning = Color(hex: "#FFD700")
    let afternoon = Color(hex: "#FF9500")
    let evening = Color(hex: "#AF52DE")
    let night = Color(hex: "#1D1D1F")
    
    // MARK: - Weather Colors
    let sunny = Color(hex: "#FFD700")
    let cloudy = Color(hex: "#8E8E93")
    let rainy = Color(hex: "#007AFF")
    let stormy = Color(hex: "#1D1D1F")
    
    // MARK: - Surface Colors
    let surface = Color(.systemBackground)
    let surfaceVariant = Color(.secondarySystemBackground)
    let surfaceTertiary = Color(.tertiarySystemBackground)
    
    // MARK: - Overlay Colors
    let overlay = Color.black.opacity(0.4)
    let overlayLight = Color.black.opacity(0.2)
    let overlayHeavy = Color.black.opacity(0.6)
    
    // MARK: - Gradient Combinations
    var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [evergreenPrimary, evergreenSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var successGradient: LinearGradient {
        LinearGradient(
            colors: [success, evergreenPrimary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var warningGradient: LinearGradient {
        LinearGradient(
            colors: [warning, Color(hex: "#FF6B00")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var errorGradient: LinearGradient {
        LinearGradient(
            colors: [error, Color(hex: "#D70015")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var premiumGradient: LinearGradient {
        LinearGradient(
            colors: [vip, premium],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Color Utilities
extension Color {
    // MARK: - Hex Initializer (Enhanced)
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
    
    // MARK: - Color Manipulation
    func lighter(by percentage: Double = 30.0) -> Color {
        return self.adjustBrightness(by: abs(percentage))
    }
    
    func darker(by percentage: Double = 30.0) -> Color {
        return self.adjustBrightness(by: -abs(percentage))
    }
    
    private func adjustBrightness(by percentage: Double) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            brightness += brightness * CGFloat(percentage / 100.0)
            brightness = max(min(brightness, 1.0), 0.0)
            return Color(UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha))
        }
        return self
    }
    
    // MARK: - Accessibility
    func contrastingTextColor() -> Color {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return luminance > 0.5 ? .black : .white
    }
    
    // MARK: - Color Blending
    func blended(with color: Color, ratio: Double = 0.5) -> Color {
        let selfUIColor = UIColor(self)
        let otherUIColor = UIColor(color)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        selfUIColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        otherUIColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let ratio = CGFloat(max(0, min(1, ratio)))
        
        return Color(
            red: Double(r1 * (1 - ratio) + r2 * ratio),
            green: Double(g1 * (1 - ratio) + g2 * ratio),
            blue: Double(b1 * (1 - ratio) + b2 * ratio),
            opacity: Double(a1 * (1 - ratio) + a2 * ratio)
        )
    }
}

// MARK: - Conditional Colors
extension Color {
    static func conditional(
        light: Color,
        dark: Color
    ) -> Color {
        return Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// MARK: - Status Color Extensions
extension BayStatus {
    var extendedThemeColor: Color {
        switch self {
        case .available:
            return Color.extendedTheme.available
        case .occupied:
            return Color.extendedTheme.occupied
        case .yours:
            return Color.extendedTheme.confirmed
        case .waiting:
            return Color.extendedTheme.pending
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .available:
            return Color.extendedTheme.successGradient
        case .occupied:
            return LinearGradient(colors: [Color.extendedTheme.occupied], startPoint: .top, endPoint: .bottom)
        case .yours:
            return Color.extendedTheme.primaryGradient
        case .waiting:
            return Color.extendedTheme.warningGradient
        }
    }
}

extension MembershipType {
    var extendedThemeColor: Color {
        switch self {
        case .guest:
            return Color.extendedTheme.guest
        case .member:
            return Color.extendedTheme.member
        case .premium:
            return Color.extendedTheme.premium
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .guest:
            return LinearGradient(colors: [Color.extendedTheme.guest], startPoint: .top, endPoint: .bottom)
        case .member:
            return Color.extendedTheme.successGradient
        case .premium:
            return Color.extendedTheme.premiumGradient
        }
    }
}