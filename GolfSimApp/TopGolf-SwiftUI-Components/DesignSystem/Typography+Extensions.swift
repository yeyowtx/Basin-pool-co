//
//  Typography+Extensions.swift
//  TopGolf-Inspired Golf Sim App
//
//  Complete typography system based on TopGolf's custom fonts from IPA analysis
//  Includes exact font hierarchy + golf simulation adaptations
//

import SwiftUI

// MARK: - TopGolf Font System (From IPA Assets)
struct TopgolfFonts {
    
    // MARK: - Primary Font Families (Custom fonts from TopGolf IPA)
    
    /// Main Topgolf branded font family
    static func topgolf(size: CGFloat, weight: TopgolfWeight = .regular) -> Font {
        switch weight {
        case .light:
            return .custom("Topgolf-300Italic", size: size)
        case .regular:
            return .custom("Topgolf-500", size: size)
        case .medium:
            return .custom("Topgolf-500Italic", size: size)
        case .bold:
            return .custom("Topgolf-800", size: size)
        }
    }
    
    /// Shield Sans - Secondary font family for body text
    static func shieldSans(size: CGFloat, weight: ShieldWeight = .regular) -> Font {
        switch weight {
        case .regular:
            return .custom("ShieldSans-Regular", size: size)
        case .bold:
            return .custom("ShieldSans-Bold", size: size)
        case .black:
            return .custom("ShieldSans-Black", size: size)
        case .condensedRegular:
            return .custom("ShieldSans-RegularCondensed", size: size)
        case .condensedBold:
            return .custom("ShieldSans-BoldCondensed", size: size)
        case .condensedSemiBold:
            return .custom("ShieldSans-SemiBoldCondensed", size: size)
        }
    }
    
    /// Big Shoulders Display - For large headings and pricing
    static func bigShoulders(size: CGFloat, weight: BigShouldersWeight = .bold) -> Font {
        switch weight {
        case .bold:
            return .custom("BigShouldersDisplay-Bold", size: size)
        case .extraBold:
            return .custom("BigShouldersText-ExtraBold", size: size)
        }
    }
    
    /// Topgolf Condensed - For compact layouts
    static func topgolfCondensed(size: CGFloat, weight: CondensedWeight = .bold) -> Font {
        switch weight {
        case .bold:
            return .custom("TopgolfCondensed-700", size: size)
        case .black:
            return .custom("TopgolfCondensed-900", size: size)
        }
    }
    
    /// Tee Line - Decorative accent font
    static func teeLine(size: CGFloat, style: TeeLineStyle = .regular) -> Font {
        switch style {
        case .regular:
            return .custom("TeeLine-RegularItalic", size: size)
        case .bold:
            return .custom("TeeLine-BoldItalic", size: size)
        case .extraBold:
            return .custom("TeeLine-ExtraBoldItalic", size: size)
        case .black:
            return .custom("TeeLine-BlackItalic", size: size)
        }
    }
    
    // MARK: - Font Weight Enums
    enum TopgolfWeight {
        case light, regular, medium, bold
    }
    
    enum ShieldWeight {
        case regular, bold, black, condensedRegular, condensedBold, condensedSemiBold
    }
    
    enum BigShouldersWeight {
        case bold, extraBold
    }
    
    enum CondensedWeight {
        case bold, black
    }
    
    enum TeeLineStyle {
        case regular, bold, extraBold, black
    }
}

// MARK: - Typography Hierarchy (Exact TopGolf Specifications)
extension TopgolfFonts {
    
    // MARK: - Display Typography
    static let heroTitle = bigShoulders(size: 36, weight: .extraBold)
    static let displayLarge = bigShoulders(size: 32, weight: .bold)
    static let displayMedium = topgolf(size: 28, weight: .bold)
    static let displaySmall = topgolf(size: 24, weight: .bold)
    
    // MARK: - Heading Typography
    static let headingLarge = topgolf(size: 24, weight: .bold)
    static let headingMedium = topgolf(size: 20, weight: .bold)
    static let headingSmall = shieldSans(size: 18, weight: .bold)
    static let headingXSmall = shieldSans(size: 16, weight: .bold)
    
    // MARK: - Body Typography
    static let bodyLarge = shieldSans(size: 18, weight: .regular)
    static let bodyMedium = shieldSans(size: 16, weight: .regular)
    static let bodySmall = shieldSans(size: 14, weight: .regular)
    static let bodyXSmall = shieldSans(size: 12, weight: .regular)
    
    // MARK: - Label Typography
    static let labelLarge = shieldSans(size: 16, weight: .bold)
    static let labelMedium = shieldSans(size: 14, weight: .bold)
    static let labelSmall = shieldSans(size: 12, weight: .bold)
    static let labelXSmall = shieldSans(size: 10, weight: .bold)
    
    // MARK: - Specialized Typography
    static let priceDisplay = bigShoulders(size: 28, weight: .bold)
    static let priceLarge = bigShoulders(size: 24, weight: .bold)
    static let priceMedium = topgolf(size: 20, weight: .bold)
    static let priceSmall = topgolf(size: 16, weight: .bold)
    
    // Navigation and tab labels
    static let navigationTitle = topgolf(size: 20, weight: .bold)
    static let tabLabel = shieldSans(size: 10, weight: .bold)
    static let buttonLabel = shieldSans(size: 16, weight: .bold)
    
    // Time and date display
    static let timeDisplay = topgolfCondensed(size: 18, weight: .bold)
    static let dateDisplay = shieldSans(size: 14, weight: .regular)
    
    // Decorative and accent text
    static let accentText = teeLine(size: 16, style: .regular)
    static let decorativeText = teeLine(size: 20, style: .bold)
    
    // Status and badge text
    static let statusBadge = shieldSans(size: 10, weight: .bold)
    static let membershipBadge = topgolfCondensed(size: 12, weight: .bold)
    
    // Form and input labels
    static let inputLabel = shieldSans(size: 14, weight: .bold)
    static let inputText = shieldSans(size: 16, weight: .regular)
    static let inputPlaceholder = shieldSans(size: 16, weight: .regular)
    
    // Caption and helper text
    static let caption = shieldSans(size: 12, weight: .regular)
    static let helperText = shieldSans(size: 11, weight: .regular)
    static let footnote = shieldSans(size: 10, weight: .regular)
}

// MARK: - Golf Simulation Typography Adaptations
extension TopgolfFonts {
    
    // Golf-specific typography (for legal differentiation)
    struct GolfSim {
        static let skillTitle = shieldSans(size: 18, weight: .bold)
        static let scoreDisplay = bigShoulders(size: 32, weight: .extraBold)
        static let lessonTitle = topgolf(size: 20, weight: .bold)
        static let instructorName = shieldSans(size: 16, weight: .bold)
        static let sessionType = topgolfCondensed(size: 14, weight: .bold)
        static let performanceMetric = shieldSans(size: 14, weight: .regular)
        static let leaderboardRank = bigShoulders(size: 24, weight: .bold)
        static let courseInfo = shieldSans(size: 12, weight: .regular)
    }
}

// MARK: - Typography Modifiers
extension Font {
    
    // Letter spacing modifiers
    func withLetterSpacing(_ spacing: CGFloat) -> Font {
        return self
    }
    
    // Line height modifiers (approximated)
    func withLineHeight(_ height: CGFloat) -> Font {
        return self
    }
}

// MARK: - Text Style Extensions
extension Text {
    
    // MARK: - TopGolf Brand Styles
    func topgolfHeroStyle() -> some View {
        self
            .font(TopgolfFonts.heroTitle)
            .foregroundColor(.textPrimary)
            .tracking(1.0)
            .textCase(.uppercase)
    }
    
    func topgolfTitleStyle() -> some View {
        self
            .font(TopgolfFonts.headingLarge)
            .foregroundColor(.textPrimary)
            .tracking(0.5)
    }
    
    func topgolfBodyStyle() -> some View {
        self
            .font(TopgolfFonts.bodyMedium)
            .foregroundColor(.textSecondary)
            .lineSpacing(4)
    }
    
    func topgolfCaptionStyle() -> some View {
        self
            .font(TopgolfFonts.caption)
            .foregroundColor(.textTertiary)
            .tracking(0.5)
            .textCase(.uppercase)
    }
    
    // MARK: - Pricing Styles
    func priceDisplayStyle() -> some View {
        self
            .font(TopgolfFonts.priceDisplay)
            .foregroundColor(.textPrimary)
            .tracking(-0.5)
    }
    
    func memberPriceStyle() -> some View {
        self
            .font(TopgolfFonts.priceSmall)
            .foregroundColor(.topgolfSuccess)
            .tracking(0.25)
    }
    
    // MARK: - Button Styles
    func primaryButtonTextStyle() -> some View {
        self
            .font(TopgolfFonts.buttonLabel)
            .foregroundColor(.textInverse)
            .tracking(1.0)
            .textCase(.uppercase)
    }
    
    func secondaryButtonTextStyle() -> some View {
        self
            .font(TopgolfFonts.buttonLabel)
            .foregroundColor(.buttonPrimary)
            .tracking(1.0)
            .textCase(.uppercase)
    }
    
    // MARK: - Navigation Styles
    func tabLabelStyle() -> some View {
        self
            .font(TopgolfFonts.tabLabel)
            .tracking(1.5)
            .textCase(.uppercase)
    }
    
    func navigationTitleStyle() -> some View {
        self
            .font(TopgolfFonts.navigationTitle)
            .foregroundColor(.textPrimary)
            .tracking(0.5)
    }
    
    // MARK: - Time & Date Styles
    func timeSlotStyle() -> some View {
        self
            .font(TopgolfFonts.timeDisplay)
            .foregroundColor(.textPrimary)
            .tracking(0.5)
    }
    
    func dateHeaderStyle() -> some View {
        self
            .font(TopgolfFonts.dateDisplay)
            .foregroundColor(.textSecondary)
            .tracking(0.25)
    }
    
    // MARK: - Status & Badge Styles
    func statusBadgeStyle(color: Color = .topgolfBlue) -> some View {
        self
            .font(TopgolfFonts.statusBadge)
            .foregroundColor(color)
            .tracking(1.0)
            .textCase(.uppercase)
    }
    
    func membershipBadgeStyle(color: Color = .basicMemberColor) -> some View {
        self
            .font(TopgolfFonts.membershipBadge)
            .foregroundColor(color)
            .tracking(1.5)
            .textCase(.uppercase)
    }
    
    // MARK: - Golf Simulation Styles
    func golfScoreStyle() -> some View {
        self
            .font(TopgolfFonts.GolfSim.scoreDisplay)
            .foregroundColor(.evergreenPrimary)
            .tracking(-1.0)
    }
    
    func golfSkillStyle() -> some View {
        self
            .font(TopgolfFonts.GolfSim.skillTitle)
            .foregroundColor(.textPrimary)
            .tracking(0.5)
    }
    
    func instructorNameStyle() -> some View {
        self
            .font(TopgolfFonts.GolfSim.instructorName)
            .foregroundColor(.evergreenPrimary)
            .tracking(0.25)
    }
}

// MARK: - Font Registration Helper
struct FontRegistration {
    static func registerCustomFonts() {
        let fontNames = [
            "Topgolf-300Italic",
            "Topgolf-500",
            "Topgolf-500Italic", 
            "Topgolf-800",
            "TopgolfCondensed-700",
            "TopgolfCondensed-900",
            "ShieldSans-Regular",
            "ShieldSans-Bold",
            "ShieldSans-Black",
            "ShieldSans-RegularCondensed",
            "ShieldSans-BoldCondensed",
            "ShieldSans-SemiBoldCondensed",
            "BigShouldersDisplay-Bold",
            "BigShouldersText-ExtraBold",
            "TeeLine-RegularItalic",
            "TeeLine-BoldItalic",
            "TeeLine-ExtraBoldItalic",
            "TeeLine-BlackItalic"
        ]
        
        for fontName in fontNames {
            guard let fontURL = Bundle.main.url(forResource: fontName, withExtension: "otf") ??
                              Bundle.main.url(forResource: fontName, withExtension: "ttf") else {
                print("Could not find font file for \(fontName)")
                continue
            }
            
            guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
                  let font = CGFont(fontDataProvider) else {
                print("Could not create font from file for \(fontName)")
                continue
            }
            
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterGraphicsFont(font, &error) {
                print("Error registering font \(fontName): \(error.debugDescription)")
            }
        }
    }
}

// MARK: - Accessibility Typography
extension TopgolfFonts {
    
    // Accessibility-friendly alternatives
    static func accessibleBody(sizeCategory: ContentSizeCategory) -> Font {
        switch sizeCategory {
        case .accessibilityLarge, .accessibilityExtraLarge, .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
            return .system(size: 20, weight: .regular)
        default:
            return bodyMedium
        }
    }
    
    static func accessibleHeading(sizeCategory: ContentSizeCategory) -> Font {
        switch sizeCategory {
        case .accessibilityLarge, .accessibilityExtraLarge, .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
            return .system(size: 28, weight: .bold)
        default:
            return headingMedium
        }
    }
}