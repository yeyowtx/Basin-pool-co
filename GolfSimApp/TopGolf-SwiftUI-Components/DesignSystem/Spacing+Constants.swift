//
//  Spacing+Constants.swift
//  TopGolf-Inspired Golf Sim App
//
//  Spacing, sizing, and layout constants extracted from TopGolf IPA analysis
//  Provides consistent spacing system matching TopGolf's design standards
//

import SwiftUI

// MARK: - Spacing System (TopGolf Standards)
struct TopgolfSpacing {
    
    // MARK: - Base Spacing Scale (8pt grid system)
    static let xxxs: CGFloat = 2    // 0.25x
    static let xxs: CGFloat = 4     // 0.5x
    static let xs: CGFloat = 8      // 1x (base unit)
    static let sm: CGFloat = 12     // 1.5x
    static let md: CGFloat = 16     // 2x
    static let lg: CGFloat = 24     // 3x
    static let xl: CGFloat = 32     // 4x
    static let xxl: CGFloat = 48    // 6x
    static let xxxl: CGFloat = 64   // 8x
    
    // MARK: - Component-Specific Spacing
    
    // Grid and layout spacing
    static let gridSpacing: CGFloat = 12
    static let gridColumnSpacing: CGFloat = 8
    static let sectionSpacing: CGFloat = 24
    static let groupSpacing: CGFloat = 16
    
    // Card and container padding
    static let cardPadding: CGFloat = 16
    static let cardInnerPadding: CGFloat = 12
    static let containerPadding: CGFloat = 16
    static let screenPadding: CGFloat = 16
    
    // Button spacing
    static let buttonPadding: CGFloat = 16
    static let buttonInnerSpacing: CGFloat = 8
    static let buttonGroupSpacing: CGFloat = 12
    
    // List and stack spacing
    static let listItemSpacing: CGFloat = 8
    static let stackSpacing: CGFloat = 16
    static let verticalStackSpacing: CGFloat = 12
    static let horizontalStackSpacing: CGFloat = 8
    
    // Form spacing
    static let formFieldSpacing: CGFloat = 16
    static let formSectionSpacing: CGFloat = 24
    static let labelSpacing: CGFloat = 4
    
    // Navigation spacing
    static let navigationPadding: CGFloat = 16
    static let tabBarPadding: CGFloat = 8
    static let headerSpacing: CGFloat = 12
    
    // Time slot grid specific
    static let timeSlotSpacing: CGFloat = 8
    static let timeSlotPadding: CGFloat = 12
    
    // Pricing card specific
    static let pricingCardPadding: CGFloat = 16
    static let pricingRowSpacing: CGFloat = 8
    
    // Venue card specific
    static let venueCardPadding: CGFloat = 16
    static let venueCardSpacing: CGFloat = 12
}

// MARK: - Size Constants
struct TopgolfSizes {
    
    // MARK: - Component Heights
    static let buttonHeight: CGFloat = 48
    static let buttonHeightSmall: CGFloat = 36
    static let buttonHeightLarge: CGFloat = 56
    
    static let inputHeight: CGFloat = 44
    static let inputHeightSmall: CGFloat = 36
    static let inputHeightLarge: CGFloat = 52
    
    static let cardMinHeight: CGFloat = 120
    static let cardMaxHeight: CGFloat = 200
    
    static let timeSlotCardHeight: CGFloat = 88
    static let pricingCardMinHeight: CGFloat = 80
    static let venueCardHeight: CGFloat = 120
    
    static let tabBarHeight: CGFloat = 83
    static let navigationBarHeight: CGFloat = 56
    static let headerHeight: CGFloat = 80
    
    // MARK: - Component Widths
    static let buttonMinWidth: CGFloat = 120
    static let inputMinWidth: CGFloat = 200
    static let cardMinWidth: CGFloat = 280
    
    // MARK: - Icon Sizes
    static let iconXSmall: CGFloat = 12
    static let iconSmall: CGFloat = 16
    static let iconMedium: CGFloat = 20
    static let iconLarge: CGFloat = 24
    static let iconXLarge: CGFloat = 32
    static let iconXXLarge: CGFloat = 48
    
    // Profile and avatar sizes
    static let avatarSmall: CGFloat = 32
    static let avatarMedium: CGFloat = 48
    static let avatarLarge: CGFloat = 64
    static let avatarXLarge: CGFloat = 80
    
    // Badge and indicator sizes
    static let badgeHeight: CGFloat = 20
    static let indicatorSize: CGFloat = 8
    static let dotIndicator: CGFloat = 6
    
    // MARK: - Layout Constraints
    static let maxContentWidth: CGFloat = 428  // iPhone 14 Pro Max width
    static let minTouchTarget: CGFloat = 44    // iOS accessibility minimum
    static let readableWidth: CGFloat = 375    // Optimal reading width
}

// MARK: - Corner Radius Constants
struct TopgolfRadius {
    
    // Standard radius scale
    static let none: CGFloat = 0
    static let xs: CGFloat = 4
    static let sm: CGFloat = 6
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
    static let xxl: CGFloat = 24
    static let round: CGFloat = 50  // For circular elements
    
    // Component-specific radius
    static let button: CGFloat = 8
    static let buttonRound: CGFloat = 24
    static let card: CGFloat = 12
    static let input: CGFloat = 8
    static let badge: CGFloat = 10
    static let timeSlotCard: CGFloat = 8
    static let pricingCard: CGFloat = 12
    static let venueCard: CGFloat = 12
    static let modal: CGFloat = 16
    static let sheet: CGFloat = 12
}

// MARK: - Shadow Constants
struct TopgolfShadows {
    
    // Shadow scale
    static let none = Shadow(color: .clear, radius: 0, x: 0, y: 0)
    static let xs = Shadow(color: .shadowDefault, radius: 2, x: 0, y: 1)
    static let sm = Shadow(color: .shadowDefault, radius: 4, x: 0, y: 2)
    static let md = Shadow(color: .shadowDefault, radius: 8, x: 0, y: 4)
    static let lg = Shadow(color: .shadowElevated, radius: 12, x: 0, y: 6)
    static let xl = Shadow(color: .shadowElevated, radius: 16, x: 0, y: 8)
    static let xxl = Shadow(color: .shadowPressed, radius: 24, x: 0, y: 12)
    
    // Component-specific shadows
    static let card = Shadow(color: .shadowDefault, radius: 8, x: 0, y: 4)
    static let button = Shadow(color: .shadowDefault, radius: 4, x: 0, y: 2)
    static let modal = Shadow(color: .shadowElevated, radius: 16, x: 0, y: 8)
    static let floating = Shadow(color: .shadowElevated, radius: 12, x: 0, y: 6)
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Animation Constants
struct TopgolfAnimations {
    
    // Animation durations
    static let instant: Double = 0.0
    static let fast: Double = 0.15
    static let normal: Double = 0.25
    static let slow: Double = 0.35
    static let slower: Double = 0.5
    
    // Spring animations
    static let springFast = Animation.spring(response: 0.3, dampingFraction: 0.8)
    static let springNormal = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let springSlow = Animation.spring(response: 0.7, dampingFraction: 0.8)
    
    // Easing animations
    static let easeOut = Animation.easeOut(duration: normal)
    static let easeIn = Animation.easeIn(duration: normal)
    static let easeInOut = Animation.easeInOut(duration: normal)
    
    // Component-specific animations
    static let buttonPress = Animation.easeOut(duration: fast)
    static let cardAppear = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let modalPresent = Animation.spring(response: 0.5, dampingFraction: 0.9)
    static let tabTransition = Animation.easeInOut(duration: normal)
}

// MARK: - Breakpoint Constants
struct TopgolfBreakpoints {
    
    // Device breakpoints
    static let compact: CGFloat = 320   // iPhone SE
    static let regular: CGFloat = 375   // iPhone 14
    static let large: CGFloat = 414     // iPhone 14 Plus
    static let extraLarge: CGFloat = 428 // iPhone 14 Pro Max
    
    // iPad breakpoints
    static let tabletPortrait: CGFloat = 768
    static let tabletLandscape: CGFloat = 1024
    
    // Content breakpoints
    static let singleColumn: CGFloat = 480
    static let twoColumn: CGFloat = 768
    static let threeColumn: CGFloat = 1024
}

// MARK: - Grid System
struct TopgolfGrid {
    
    // Column counts for different screen sizes
    static func columns(for width: CGFloat) -> Int {
        switch width {
        case 0..<TopgolfBreakpoints.regular:
            return 1
        case TopgolfBreakpoints.regular..<TopgolfBreakpoints.tabletPortrait:
            return 2
        case TopgolfBreakpoints.tabletPortrait..<TopgolfBreakpoints.tabletLandscape:
            return 3
        default:
            return 4
        }
    }
    
    // Time slot grid specific
    static let timeSlotColumns = 4
    static let timeSlotColumnSpacing: CGFloat = 8
    static let timeSlotRowSpacing: CGFloat = 8
    
    // Venue grid specific
    static let venueGridColumns = 1 // Single column for venue cards
    static let venueGridSpacing: CGFloat = 12
    
    // Quick actions grid
    static let quickActionColumns = 2
    static let quickActionSpacing: CGFloat = 12
}

// MARK: - Z-Index Constants
struct TopgolfZIndex {
    static let background: Double = 0
    static let content: Double = 1
    static let overlay: Double = 10
    static let modal: Double = 100
    static let alert: Double = 200
    static let tooltip: Double = 300
    static let dropdown: Double = 400
    static let toast: Double = 500
}

// MARK: - Haptic Feedback
struct TopgolfHaptics {
    
    static func light() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    static func medium() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    static func heavy() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    static func success() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    static func warning() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    static func error() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
    
    static func selection() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
}

// MARK: - Layout Helpers
extension View {
    
    // Apply standard spacing
    func topgolfSpacing(_ spacing: TopgolfSpacing.Type = TopgolfSpacing.self) -> some View {
        self.padding(.horizontal, spacing.screenPadding)
    }
    
    // Apply card styling
    func topgolfCard() -> some View {
        self
            .padding(TopgolfSpacing.cardPadding)
            .background(Color.backgroundPrimary)
            .cornerRadius(TopgolfRadius.card)
            .shadow(
                color: TopgolfShadows.card.color,
                radius: TopgolfShadows.card.radius,
                x: TopgolfShadows.card.x,
                y: TopgolfShadows.card.y
            )
    }
    
    // Apply button sizing
    func topgolfButton(size: ButtonSize = .medium) -> some View {
        self
            .frame(height: size.height)
            .frame(minWidth: size.minWidth)
            .cornerRadius(TopgolfRadius.button)
    }
    
    enum ButtonSize {
        case small, medium, large
        
        var height: CGFloat {
            switch self {
            case .small: return TopgolfSizes.buttonHeightSmall
            case .medium: return TopgolfSizes.buttonHeight
            case .large: return TopgolfSizes.buttonHeightLarge
            }
        }
        
        var minWidth: CGFloat {
            switch self {
            case .small: return 80
            case .medium: return TopgolfSizes.buttonMinWidth
            case .large: return 160
            }
        }
    }
}