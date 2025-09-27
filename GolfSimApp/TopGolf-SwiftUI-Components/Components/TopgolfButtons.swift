//
//  TopgolfButtons.swift
//  TopGolf-Inspired Golf Sim App
//
//  Comprehensive button component library with exact TopGolf styling
//  Provides primary, secondary, destructive, and specialty button variants
//

import SwiftUI

// MARK: - Primary Button
struct TopgolfPrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isEnabled: Bool
    let isLoading: Bool
    let size: ButtonSize
    
    @Environment(\.topgolfTheme) private var theme
    
    init(title: String,
         icon: String? = nil,
         isEnabled: Bool = true,
         isLoading: Bool = false,
         size: ButtonSize = .medium,
         action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: size.iconSpacing) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                }
                
                Text(title)
                    .font(size.font)
                    .fontWeight(.semibold)
                    .tracking(0.5)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
            .background(
                isEnabled ? theme.configuration.colors.primary : Color.textTertiary
            )
            .cornerRadius(size.cornerRadius)
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .disabled(!isEnabled || isLoading)
        .buttonStyle(ScaleButtonStyle(animation: TopgolfAnimations.buttonPress))
    }
}

// MARK: - Secondary Button
struct TopgolfSecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isEnabled: Bool
    let isLoading: Bool
    let size: ButtonSize
    
    @Environment(\.topgolfTheme) private var theme
    
    init(title: String,
         icon: String? = nil,
         isEnabled: Bool = true,
         isLoading: Bool = false,
         size: ButtonSize = .medium,
         action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: size.iconSpacing) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: theme.configuration.colors.primary))
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                }
                
                Text(title)
                    .font(size.font)
                    .fontWeight(.medium)
                    .tracking(0.5)
            }
            .foregroundColor(isEnabled ? theme.configuration.colors.primary : .textTertiary)
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
            .background(
                isEnabled ? theme.configuration.colors.primary.opacity(0.1) : Color.backgroundSecondary
            )
            .cornerRadius(size.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(
                        isEnabled ? theme.configuration.colors.primary : Color.borderSecondary,
                        lineWidth: size.borderWidth
                    )
            )
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .disabled(!isEnabled || isLoading)
        .buttonStyle(ScaleButtonStyle(animation: TopgolfAnimations.buttonPress))
    }
}

// MARK: - Destructive Button
struct TopgolfDestructiveButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isEnabled: Bool
    let isLoading: Bool
    let size: ButtonSize
    
    init(title: String,
         icon: String? = nil,
         isEnabled: Bool = true,
         isLoading: Bool = false,
         size: ButtonSize = .medium,
         action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: size.iconSpacing) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                }
                
                Text(title)
                    .font(size.font)
                    .fontWeight(.semibold)
                    .tracking(0.5)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
            .background(
                isEnabled ? Color.topgolfError : Color.textTertiary
            )
            .cornerRadius(size.cornerRadius)
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .disabled(!isEnabled || isLoading)
        .buttonStyle(ScaleButtonStyle(animation: TopgolfAnimations.buttonPress))
    }
}

// MARK: - Ghost Button
struct TopgolfGhostButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isEnabled: Bool
    let size: ButtonSize
    
    @Environment(\.topgolfTheme) private var theme
    
    init(title: String,
         icon: String? = nil,
         isEnabled: Bool = true,
         size: ButtonSize = .medium,
         action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: size.iconSpacing) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                }
                
                Text(title)
                    .font(size.font)
                    .fontWeight(.medium)
                    .tracking(0.5)
            }
            .foregroundColor(isEnabled ? theme.configuration.colors.primary : .textTertiary)
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
            .background(Color.clear)
            .cornerRadius(size.cornerRadius)
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .disabled(!isEnabled)
        .buttonStyle(ScaleButtonStyle(animation: TopgolfAnimations.buttonPress))
    }
}

// MARK: - Link Button
struct TopgolfLinkButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isEnabled: Bool
    let size: LinkButtonSize
    
    @Environment(\.topgolfTheme) private var theme
    
    init(title: String,
         icon: String? = nil,
         isEnabled: Bool = true,
         size: LinkButtonSize = .medium,
         action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: size.iconSpacing) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                }
                
                Text(title)
                    .font(size.font)
                    .fontWeight(.medium)
                    .tracking(0.3)
                    .underline()
            }
            .foregroundColor(isEnabled ? theme.configuration.colors.primary : .textTertiary)
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .disabled(!isEnabled)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Icon Button
struct TopgolfIconButton: View {
    let icon: String
    let action: () -> Void
    let style: IconButtonStyle
    let size: IconButtonSize
    let isEnabled: Bool
    
    @Environment(\.topgolfTheme) private var theme
    
    init(icon: String,
         style: IconButtonStyle = .primary,
         size: IconButtonSize = .medium,
         isEnabled: Bool = true,
         action: @escaping () -> Void) {
        self.icon = icon
        self.style = style
        self.size = size
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundColor(foregroundColor)
                .frame(width: size.dimension, height: size.dimension)
                .background(backgroundColor)
                .cornerRadius(size.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .opacity(isEnabled ? 1.0 : 0.6)
        }
        .disabled(!isEnabled)
        .buttonStyle(ScaleButtonStyle(animation: TopgolfAnimations.buttonPress))
    }
    
    private var foregroundColor: Color {
        guard isEnabled else { return .textTertiary }
        
        switch style {
        case .primary: return .white
        case .secondary: return theme.configuration.colors.primary
        case .ghost: return theme.configuration.colors.primary
        case .destructive: return .white
        }
    }
    
    private var backgroundColor: Color {
        guard isEnabled else { return .backgroundSecondary }
        
        switch style {
        case .primary: return theme.configuration.colors.primary
        case .secondary: return theme.configuration.colors.primary.opacity(0.1)
        case .ghost: return .clear
        case .destructive: return .topgolfError
        }
    }
    
    private var borderColor: Color {
        guard isEnabled else { return .borderSecondary }
        
        switch style {
        case .primary, .destructive: return .clear
        case .secondary: return theme.configuration.colors.primary
        case .ghost: return .clear
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .primary, .ghost, .destructive: return 0
        case .secondary: return 1
        }
    }
}

// MARK: - Floating Action Button
struct TopgolfFloatingButton: View {
    let icon: String
    let action: () -> Void
    let isEnabled: Bool
    
    @Environment(\.topgolfTheme) private var theme
    
    init(icon: String,
         isEnabled: Bool = true,
         action: @escaping () -> Void) {
        self.icon = icon
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    isEnabled ? theme.configuration.colors.primary : Color.textTertiary
                )
                .cornerRadius(28)
                .shadow(
                    color: TopgolfShadows.floating.color,
                    radius: TopgolfShadows.floating.radius,
                    x: TopgolfShadows.floating.x,
                    y: TopgolfShadows.floating.y
                )
                .opacity(isEnabled ? 1.0 : 0.6)
        }
        .disabled(!isEnabled)
        .buttonStyle(ScaleButtonStyle(animation: TopgolfAnimations.buttonPress))
    }
}

// MARK: - Segmented Button
struct TopgolfSegmentedButton: View {
    let options: [String]
    @Binding var selectedIndex: Int
    let size: ButtonSize
    
    @Environment(\.topgolfTheme) private var theme
    
    init(options: [String],
         selectedIndex: Binding<Int>,
         size: ButtonSize = .medium) {
        self.options = options
        self._selectedIndex = selectedIndex
        self.size = size
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                Button(action: {
                    withAnimation(TopgolfAnimations.springFast) {
                        selectedIndex = index
                    }
                }) {
                    Text(options[index])
                        .font(size.font)
                        .fontWeight(.medium)
                        .tracking(0.3)
                        .foregroundColor(
                            selectedIndex == index ? .white : theme.configuration.colors.primary
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: size.height)
                        .background(
                            selectedIndex == index ? theme.configuration.colors.primary : Color.clear
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color.backgroundSecondary)
        .cornerRadius(size.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .stroke(Color.borderPrimary, lineWidth: 1)
        )
    }
}

// MARK: - Button Sizes and Styles
enum ButtonSize {
    case small, medium, large, extraLarge
    
    var height: CGFloat {
        switch self {
        case .small: return 32
        case .medium: return 44
        case .large: return 52
        case .extraLarge: return 60
        }
    }
    
    var font: Font {
        switch self {
        case .small: return TopgolfFonts.labelSmall
        case .medium: return TopgolfFonts.labelMedium
        case .large: return TopgolfFonts.labelLarge
        case .extraLarge: return TopgolfFonts.headingMedium
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return TopgolfRadius.xs
        case .medium: return TopgolfRadius.button
        case .large: return TopgolfRadius.button
        case .extraLarge: return TopgolfRadius.card
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 14
        case .large: return 16
        case .extraLarge: return 18
        }
    }
    
    var iconSpacing: CGFloat {
        switch self {
        case .small: return TopgolfSpacing.xxs
        case .medium: return TopgolfSpacing.xs
        case .large: return TopgolfSpacing.xs
        case .extraLarge: return TopgolfSpacing.sm
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .small: return 1
        case .medium: return 1.5
        case .large: return 2
        case .extraLarge: return 2
        }
    }
}

enum LinkButtonSize {
    case small, medium, large
    
    var font: Font {
        switch self {
        case .small: return TopgolfFonts.caption
        case .medium: return TopgolfFonts.bodyMedium
        case .large: return TopgolfFonts.bodyLarge
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .small: return 10
        case .medium: return 12
        case .large: return 14
        }
    }
    
    var iconSpacing: CGFloat {
        TopgolfSpacing.xxs
    }
}

enum IconButtonStyle {
    case primary, secondary, ghost, destructive
}

enum IconButtonSize {
    case small, medium, large
    
    var dimension: CGFloat {
        switch self {
        case .small: return 32
        case .medium: return 40
        case .large: return 48
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return TopgolfRadius.xs
        case .medium: return TopgolfRadius.button
        case .large: return TopgolfRadius.button
        }
    }
}

// MARK: - Button Styles
struct ScaleButtonStyle: ButtonStyle {
    let animation: Animation
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(animation, value: configuration.isPressed)
    }
}

// MARK: - Specialized Buttons
struct TopgolfBookingButton: View {
    let title: String
    let price: String?
    let isAvailable: Bool
    let action: () -> Void
    
    @Environment(\.topgolfTheme) private var theme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: TopgolfSpacing.xxs) {
                Text(title)
                    .font(TopgolfFonts.labelMedium)
                    .fontWeight(.semibold)
                    .tracking(0.5)
                
                if let price = price {
                    Text(price)
                        .font(TopgolfFonts.bodySmall)
                        .opacity(0.9)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                isAvailable ? theme.configuration.colors.primary : Color.textTertiary
            )
            .cornerRadius(TopgolfRadius.button)
            .overlay(
                !isAvailable ? 
                Text("FULL")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .tracking(2.0)
                    .opacity(0.8)
                : nil
            )
        }
        .disabled(!isAvailable)
        .buttonStyle(ScaleButtonStyle(animation: TopgolfAnimations.buttonPress))
    }
}

struct TopgolfCTAButton: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let action: () -> Void
    let isEnabled: Bool
    
    @Environment(\.topgolfTheme) private var theme
    
    init(title: String,
         subtitle: String? = nil,
         icon: String? = nil,
         isEnabled: Bool = true,
         action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: TopgolfSpacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(TopgolfFonts.headingMedium)
                        .fontWeight(.bold)
                        .tracking(0.5)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(TopgolfFonts.bodySmall)
                            .opacity(0.9)
                    }
                }
                
                Spacer()
                
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                }
            }
            .foregroundColor(.white)
            .padding(TopgolfSpacing.md)
            .background(
                LinearGradient(
                    colors: [
                        theme.configuration.colors.primary,
                        theme.configuration.colors.primary.opacity(0.8)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(TopgolfRadius.card)
            .shadow(
                color: TopgolfShadows.card.color,
                radius: TopgolfShadows.card.radius,
                x: TopgolfShadows.card.x,
                y: TopgolfShadows.card.y
            )
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .disabled(!isEnabled)
        .buttonStyle(ScaleButtonStyle(animation: TopgolfAnimations.buttonPress))
    }
}

// MARK: - Social Login Buttons
struct TopgolfSocialButton: View {
    let provider: SocialProvider
    let action: () -> Void
    let isEnabled: Bool
    
    init(provider: SocialProvider,
         isEnabled: Bool = true,
         action: @escaping () -> Void) {
        self.provider = provider
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: TopgolfSpacing.sm) {
                Image(systemName: provider.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(provider.iconColor)
                
                Text("Continue with \(provider.name)")
                    .font(TopgolfFonts.labelMedium)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal, TopgolfSpacing.md)
            .background(Color.backgroundPrimary)
            .cornerRadius(TopgolfRadius.button)
            .overlay(
                RoundedRectangle(cornerRadius: TopgolfRadius.button)
                    .stroke(Color.borderPrimary, lineWidth: 1)
            )
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .disabled(!isEnabled)
        .buttonStyle(ScaleButtonStyle(animation: TopgolfAnimations.buttonPress))
    }
}

enum SocialProvider {
    case apple, google, facebook
    
    var name: String {
        switch self {
        case .apple: return "Apple"
        case .google: return "Google"
        case .facebook: return "Facebook"
        }
    }
    
    var icon: String {
        switch self {
        case .apple: return "applelogo"
        case .google: return "g.circle"
        case .facebook: return "f.circle"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .apple: return .primary
        case .google: return .red
        case .facebook: return .blue
        }
    }
}

// MARK: - Preview
#if DEBUG
struct TopgolfButtons_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: TopgolfSpacing.lg) {
                VStack(spacing: TopgolfSpacing.md) {
                    Text("Primary Buttons")
                        .font(TopgolfFonts.headingMedium)
                        .foregroundColor(.textPrimary)
                    
                    TopgolfPrimaryButton(title: "Book Now", icon: "calendar") {}
                    TopgolfPrimaryButton(title: "Loading", isLoading: true) {}
                    TopgolfPrimaryButton(title: "Disabled", isEnabled: false) {}
                }
                
                VStack(spacing: TopgolfSpacing.md) {
                    Text("Secondary Buttons")
                        .font(TopgolfFonts.headingMedium)
                        .foregroundColor(.textPrimary)
                    
                    TopgolfSecondaryButton(title: "Cancel", icon: "xmark") {}
                    TopgolfDestructiveButton(title: "Delete", icon: "trash") {}
                    TopgolfGhostButton(title: "Skip") {}
                }
                
                VStack(spacing: TopgolfSpacing.md) {
                    Text("Icon Buttons")
                        .font(TopgolfFonts.headingMedium)
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: TopgolfSpacing.md) {
                        TopgolfIconButton(icon: "heart", style: .primary) {}
                        TopgolfIconButton(icon: "share", style: .secondary) {}
                        TopgolfIconButton(icon: "ellipsis", style: .ghost) {}
                    }
                }
                
                VStack(spacing: TopgolfSpacing.md) {
                    Text("Specialized Buttons")
                        .font(TopgolfFonts.headingMedium)
                        .foregroundColor(.textPrimary)
                    
                    TopgolfBookingButton(
                        title: "Book Simulator",
                        price: "$60/hour",
                        isAvailable: true
                    ) {}
                    
                    TopgolfCTAButton(
                        title: "Become a Member",
                        subtitle: "Save 15% on all sessions",
                        icon: "star.fill"
                    ) {}
                }
                
                VStack(spacing: TopgolfSpacing.md) {
                    Text("Social Login")
                        .font(TopgolfFonts.headingMedium)
                        .foregroundColor(.textPrimary)
                    
                    TopgolfSocialButton(provider: .apple) {}
                    TopgolfSocialButton(provider: .google) {}
                }
            }
            .padding(TopgolfSpacing.md)
        }
        .background(Color.backgroundTertiary)
        .topgolfTheme(.topgolf)
    }
}
#endif