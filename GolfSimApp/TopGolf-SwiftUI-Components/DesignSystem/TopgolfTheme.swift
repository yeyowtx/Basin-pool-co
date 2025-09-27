//
//  TopgolfTheme.swift
//  TopGolf-Inspired Golf Sim App
//
//  Complete design system configuration combining colors, typography, spacing
//  Provides unified theming for TopGolf-style golf simulation app
//

import SwiftUI

// MARK: - Unified Theme Configuration
struct TopgolfTheme {
    
    // MARK: - Theme Variants
    enum Variant {
        case topgolf        // Original TopGolf styling
        case golfSim        // Golf simulation adaptation
        case custom(TopgolfThemeConfiguration)
        
        var configuration: TopgolfThemeConfiguration {
            switch self {
            case .topgolf:
                return .topgolf
            case .golfSim:
                return .golfSim
            case .custom(let config):
                return config
            }
        }
    }
    
    // Current theme variant
    static var current: Variant = .topgolf
    
    // Quick access to current theme configuration
    static var config: TopgolfThemeConfiguration {
        return current.configuration
    }
}

// MARK: - Theme Configuration Structure
struct TopgolfThemeConfiguration {
    
    // MARK: - Color Configuration
    let colors: ColorConfiguration
    
    // MARK: - Typography Configuration
    let typography: TypographyConfiguration
    
    // MARK: - Component Configuration
    let components: ComponentConfiguration
    
    // MARK: - Animation Configuration
    let animations: AnimationConfiguration
    
    // MARK: - Predefined Configurations
    
    /// Original TopGolf theme configuration
    static let topgolf = TopgolfThemeConfiguration(
        colors: .topgolf,
        typography: .topgolf,
        components: .topgolf,
        animations: .topgolf
    )
    
    /// Golf simulation adapted theme
    static let golfSim = TopgolfThemeConfiguration(
        colors: .golfSim,
        typography: .golfSim,
        components: .golfSim,
        animations: .golfSim
    )
}

// MARK: - Color Configuration
struct ColorConfiguration {
    let primary: Color
    let secondary: Color
    let accent: Color
    let background: Color
    let surface: Color
    let onPrimary: Color
    let onSecondary: Color
    let onBackground: Color
    let onSurface: Color
    let success: Color
    let warning: Color
    let error: Color
    let info: Color
    
    // Semantic colors
    let textPrimary: Color
    let textSecondary: Color
    let textTertiary: Color
    let borderPrimary: Color
    let borderSecondary: Color
    let shadowDefault: Color
    
    // Component-specific colors
    let buttonPrimary: Color
    let buttonSecondary: Color
    let buttonDisabled: Color
    let cardBackground: Color
    let inputBackground: Color
    
    static let topgolf = ColorConfiguration(
        primary: .topgolfBlue,
        secondary: .topgolfOrange,
        accent: .topgolfGreen,
        background: .backgroundPrimary,
        surface: .backgroundSecondary,
        onPrimary: .textInverse,
        onSecondary: .textInverse,
        onBackground: .textPrimary,
        onSurface: .textPrimary,
        success: .topgolfSuccess,
        warning: .topgolfWarning,
        error: .topgolfError,
        info: .topgolfInfo,
        textPrimary: .textPrimary,
        textSecondary: .textSecondary,
        textTertiary: .textTertiary,
        borderPrimary: .borderPrimary,
        borderSecondary: .borderSecondary,
        shadowDefault: .shadowDefault,
        buttonPrimary: .buttonPrimary,
        buttonSecondary: .buttonSecondary,
        buttonDisabled: .buttonDisabled,
        cardBackground: .backgroundPrimary,
        inputBackground: .backgroundSecondary
    )
    
    static let golfSim = ColorConfiguration(
        primary: .evergreenPrimary,
        secondary: .evergreenAccent,
        accent: .evergreenLight,
        background: .backgroundPrimary,
        surface: .backgroundSecondary,
        onPrimary: .textInverse,
        onSecondary: .textPrimary,
        onBackground: .textPrimary,
        onSurface: .textPrimary,
        success: .golfSimSuccess,
        warning: .golfSimWarning,
        error: .golfSimError,
        info: .golfSimInfo,
        textPrimary: .textPrimary,
        textSecondary: .textSecondary,
        textTertiary: .textTertiary,
        borderPrimary: .borderPrimary,
        borderSecondary: .borderSecondary,
        shadowDefault: .shadowDefault,
        buttonPrimary: .golfButtonPrimary,
        buttonSecondary: .golfButtonSecondary,
        buttonDisabled: .buttonDisabled,
        cardBackground: .backgroundPrimary,
        inputBackground: .backgroundSecondary
    )
}

// MARK: - Typography Configuration
struct TypographyConfiguration {
    let heroTitle: Font
    let displayLarge: Font
    let headingLarge: Font
    let headingMedium: Font
    let headingSmall: Font
    let bodyLarge: Font
    let bodyMedium: Font
    let bodySmall: Font
    let labelLarge: Font
    let labelMedium: Font
    let labelSmall: Font
    let buttonLabel: Font
    let caption: Font
    let priceDisplay: Font
    
    static let topgolf = TypographyConfiguration(
        heroTitle: TopgolfFonts.heroTitle,
        displayLarge: TopgolfFonts.displayLarge,
        headingLarge: TopgolfFonts.headingLarge,
        headingMedium: TopgolfFonts.headingMedium,
        headingSmall: TopgolfFonts.headingSmall,
        bodyLarge: TopgolfFonts.bodyLarge,
        bodyMedium: TopgolfFonts.bodyMedium,
        bodySmall: TopgolfFonts.bodySmall,
        labelLarge: TopgolfFonts.labelLarge,
        labelMedium: TopgolfFonts.labelMedium,
        labelSmall: TopgolfFonts.labelSmall,
        buttonLabel: TopgolfFonts.buttonLabel,
        caption: TopgolfFonts.caption,
        priceDisplay: TopgolfFonts.priceDisplay
    )
    
    static let golfSim = TypographyConfiguration(
        heroTitle: TopgolfFonts.GolfSim.scoreDisplay,
        displayLarge: TopgolfFonts.displayLarge,
        headingLarge: TopgolfFonts.GolfSim.lessonTitle,
        headingMedium: TopgolfFonts.GolfSim.skillTitle,
        headingSmall: TopgolfFonts.headingSmall,
        bodyLarge: TopgolfFonts.bodyLarge,
        bodyMedium: TopgolfFonts.bodyMedium,
        bodySmall: TopgolfFonts.bodySmall,
        labelLarge: TopgolfFonts.labelLarge,
        labelMedium: TopgolfFonts.labelMedium,
        labelSmall: TopgolfFonts.labelSmall,
        buttonLabel: TopgolfFonts.buttonLabel,
        caption: TopgolfFonts.caption,
        priceDisplay: TopgolfFonts.priceDisplay
    )
}

// MARK: - Component Configuration
struct ComponentConfiguration {
    let buttonHeight: CGFloat
    let cardPadding: CGFloat
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let shadowRadius: CGFloat
    let gridSpacing: CGFloat
    
    static let topgolf = ComponentConfiguration(
        buttonHeight: TopgolfSizes.buttonHeight,
        cardPadding: TopgolfSpacing.cardPadding,
        cornerRadius: TopgolfRadius.card,
        borderWidth: 1.0,
        shadowRadius: TopgolfShadows.card.radius,
        gridSpacing: TopgolfSpacing.gridSpacing
    )
    
    static let golfSim = ComponentConfiguration(
        buttonHeight: TopgolfSizes.buttonHeight,
        cardPadding: TopgolfSpacing.cardPadding,
        cornerRadius: TopgolfRadius.card,
        borderWidth: 1.0,
        shadowRadius: TopgolfShadows.card.radius,
        gridSpacing: TopgolfSpacing.gridSpacing
    )
}

// MARK: - Animation Configuration
struct AnimationConfiguration {
    let fast: Animation
    let normal: Animation
    let slow: Animation
    let spring: Animation
    let buttonPress: Animation
    
    static let topgolf = AnimationConfiguration(
        fast: TopgolfAnimations.easeOut,
        normal: TopgolfAnimations.easeInOut,
        slow: TopgolfAnimations.springSlow,
        spring: TopgolfAnimations.springNormal,
        buttonPress: TopgolfAnimations.buttonPress
    )
    
    static let golfSim = AnimationConfiguration(
        fast: TopgolfAnimations.easeOut,
        normal: TopgolfAnimations.easeInOut,
        slow: TopgolfAnimations.springSlow,
        spring: TopgolfAnimations.springNormal,
        buttonPress: TopgolfAnimations.buttonPress
    )
}

// MARK: - Theme Environment
struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue = TopgolfTheme.Variant.topgolf
}

extension EnvironmentValues {
    var topgolfTheme: TopgolfTheme.Variant {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

// MARK: - Theme Modifier
struct TopgolfThemeModifier: ViewModifier {
    let variant: TopgolfTheme.Variant
    
    func body(content: Content) -> some View {
        content
            .environment(\.topgolfTheme, variant)
            .onAppear {
                TopgolfTheme.current = variant
            }
    }
}

extension View {
    func topgolfTheme(_ variant: TopgolfTheme.Variant) -> some View {
        modifier(TopgolfThemeModifier(variant: variant))
    }
}

// MARK: - Theme-Aware Components
struct ThemedText: View {
    let text: String
    let style: TextStyle
    @Environment(\.topgolfTheme) private var theme
    
    enum TextStyle {
        case heroTitle, displayLarge, headingLarge, headingMedium, headingSmall
        case bodyLarge, bodyMedium, bodySmall
        case labelLarge, labelMedium, labelSmall
        case buttonLabel, caption, priceDisplay
        
        func font(for config: TypographyConfiguration) -> Font {
            switch self {
            case .heroTitle: return config.heroTitle
            case .displayLarge: return config.displayLarge
            case .headingLarge: return config.headingLarge
            case .headingMedium: return config.headingMedium
            case .headingSmall: return config.headingSmall
            case .bodyLarge: return config.bodyLarge
            case .bodyMedium: return config.bodyMedium
            case .bodySmall: return config.bodySmall
            case .labelLarge: return config.labelLarge
            case .labelMedium: return config.labelMedium
            case .labelSmall: return config.labelSmall
            case .buttonLabel: return config.buttonLabel
            case .caption: return config.caption
            case .priceDisplay: return config.priceDisplay
            }
        }
        
        func color(for config: ColorConfiguration) -> Color {
            switch self {
            case .heroTitle, .displayLarge, .headingLarge, .headingMedium, .headingSmall:
                return config.textPrimary
            case .bodyLarge, .bodyMedium, .bodySmall:
                return config.textSecondary
            case .labelLarge, .labelMedium, .labelSmall:
                return config.textPrimary
            case .buttonLabel:
                return config.onPrimary
            case .caption:
                return config.textTertiary
            case .priceDisplay:
                return config.textPrimary
            }
        }
    }
    
    var body: some View {
        let config = theme.configuration
        
        Text(text)
            .font(style.font(for: config.typography))
            .foregroundColor(style.color(for: config.colors))
    }
}

struct ThemedButton: View {
    let title: String
    let style: ButtonStyle
    let action: () -> Void
    @Environment(\.topgolfTheme) private var theme
    
    enum ButtonStyle {
        case primary, secondary, tertiary, destructive
        
        func backgroundColor(for config: ColorConfiguration) -> Color {
            switch self {
            case .primary: return config.buttonPrimary
            case .secondary: return config.buttonSecondary
            case .tertiary: return Color.clear
            case .destructive: return config.error
            }
        }
        
        func foregroundColor(for config: ColorConfiguration) -> Color {
            switch self {
            case .primary: return config.onPrimary
            case .secondary: return config.onSecondary
            case .tertiary: return config.primary
            case .destructive: return config.onPrimary
            }
        }
        
        func borderColor(for config: ColorConfiguration) -> Color {
            switch self {
            case .primary, .secondary, .destructive: return Color.clear
            case .tertiary: return config.primary
            }
        }
    }
    
    var body: some View {
        let config = theme.configuration
        
        Button(action: action) {
            Text(title)
                .font(config.typography.buttonLabel)
                .foregroundColor(style.foregroundColor(for: config.colors))
                .tracking(1.0)
                .textCase(.uppercase)
                .frame(height: config.components.buttonHeight)
                .frame(maxWidth: .infinity)
                .background(style.backgroundColor(for: config.colors))
                .cornerRadius(config.components.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: config.components.cornerRadius)
                        .stroke(style.borderColor(for: config.colors), lineWidth: config.components.borderWidth)
                )
        }
        .buttonStyle(ScaleButtonStyle(animation: config.animations.buttonPress))
    }
}

// MARK: - Custom Button Style
struct ScaleButtonStyle: ButtonStyle {
    let animation: Animation
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(animation, value: configuration.isPressed)
    }
}

// MARK: - Theme Preview Helpers
struct TopgolfThemePreview: View {
    var body: some View {
        VStack(spacing: TopgolfSpacing.lg) {
            ThemedText(text: "TopGolf Theme", style: .heroTitle)
            ThemedText(text: "Golf Simulation App", style: .headingMedium)
            ThemedText(text: "This is body text in the current theme", style: .bodyMedium)
            
            HStack(spacing: TopgolfSpacing.md) {
                ThemedButton(title: "Primary", style: .primary) {}
                ThemedButton(title: "Secondary", style: .secondary) {}
            }
            
            ThemedText(text: "$48/hr", style: .priceDisplay)
            ThemedText(text: "Member pricing available", style: .caption)
        }
        .padding(TopgolfSpacing.lg)
        .background(TopgolfTheme.config.colors.background)
    }
}

#if DEBUG
struct TopgolfTheme_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TopgolfThemePreview()
                .topgolfTheme(.topgolf)
                .previewDisplayName("TopGolf Theme")
            
            TopgolfThemePreview()
                .topgolfTheme(.golfSim)
                .previewDisplayName("Golf Sim Theme")
        }
    }
}
#endif