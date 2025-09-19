import SwiftUI

// MARK: - Jobs UI Polish System
// Apple-level polish for Golf Sim App UI components

struct JobsUIPolish {
    // MARK: - Haptic Feedback
    static let impact = UIImpactFeedbackGenerator(style: .medium)
    static let selection = UISelectionFeedbackGenerator()
    static let notification = UINotificationFeedbackGenerator()
    
    // MARK: - Animation Constants
    struct Animation {
        static let springy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let snappy = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.9)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let bounce = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.3)
    }
    
    // MARK: - Spacing Constants
    struct Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }
    
    // MARK: - Corner Radius Constants
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let round: CGFloat = 50
    }
    
    // MARK: - Shadow Definitions
    struct Shadow {
        static let light = (color: Color.black.opacity(0.05), radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
        static let medium = (color: Color.black.opacity(0.1), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let heavy = (color: Color.black.opacity(0.15), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let card = (color: Color.black.opacity(0.08), radius: CGFloat(6), x: CGFloat(0), y: CGFloat(3))
    }
    
    // MARK: - Glass Effect
    static let glassBackground = Color.white.opacity(0.85)
    static let glassBlur: CGFloat = 20
}

// MARK: - Haptic Extensions
extension View {
    func onTapWithHaptic(perform action: @escaping () -> Void) -> some View {
        onTapGesture {
            JobsUIPolish.impact.impactOccurred()
            action()
        }
    }
    
    func onLongPressWithHaptic(perform action: @escaping () -> Void) -> some View {
        onLongPressGesture {
            JobsUIPolish.notification.notificationOccurred(.success)
            action()
        }
    }
}

// MARK: - Premium Card Styles
struct PremiumCardStyle: ViewModifier {
    let isPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: JobsUIPolish.CornerRadius.lg)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: JobsUIPolish.Shadow.card.color,
                        radius: isPressed ? JobsUIPolish.Shadow.light.radius : JobsUIPolish.Shadow.card.radius,
                        x: JobsUIPolish.Shadow.card.x,
                        y: isPressed ? JobsUIPolish.Shadow.light.y : JobsUIPolish.Shadow.card.y
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(JobsUIPolish.Animation.snappy, value: isPressed)
    }
}

struct GlassCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: JobsUIPolish.CornerRadius.lg)
                    .fill(JobsUIPolish.glassBackground)
                    .background(.ultraThinMaterial)
            )
    }
}

// MARK: - Button Styles
struct PremiumButtonStyle: ButtonStyle {
    let variant: ButtonVariant
    
    enum ButtonVariant {
        case primary, secondary, tertiary, danger
        
        var backgroundColor: Color {
            switch self {
            case .primary: return Color.theme.primary
            case .secondary: return Color(.systemGray6)
            case .tertiary: return Color.clear
            case .danger: return Color.theme.error
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .danger: return .white
            case .secondary: return Color(.label)
            case .tertiary: return Color.theme.primary
            }
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .rounded, weight: .semibold))
            .foregroundColor(variant.foregroundColor)
            .padding(.horizontal, JobsUIPolish.Spacing.lg)
            .padding(.vertical, JobsUIPolish.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: JobsUIPolish.CornerRadius.md)
                    .fill(variant.backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: JobsUIPolish.CornerRadius.md)
                    .stroke(variant == .tertiary ? Color.theme.primary : Color.clear, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(JobsUIPolish.Animation.snappy, value: configuration.isPressed)
    }
}

// MARK: - Typography Extensions
extension Font {
    static let displayLarge = Font.system(size: 34, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .rounded)
    static let displaySmall = Font.system(size: 24, weight: .bold, design: .rounded)
    
    static let headlineLarge = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let headlineMedium = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headlineSmall = Font.system(size: 18, weight: .semibold, design: .rounded)
    
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 16, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 15, weight: .regular, design: .default)
    
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 13, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 12, weight: .medium, design: .default)
    
    static let captionLarge = Font.system(size: 12, weight: .regular, design: .default)
    static let captionSmall = Font.system(size: 11, weight: .regular, design: .default)
}

// MARK: - View Modifiers
extension View {
    func premiumCard(isPressed: Bool = false) -> some View {
        modifier(PremiumCardStyle(isPressed: isPressed))
    }
    
    func glassCard() -> some View {
        modifier(GlassCardStyle())
    }
    
    func premiumButton(_ variant: PremiumButtonStyle.ButtonVariant) -> some View {
        buttonStyle(PremiumButtonStyle(variant: variant))
    }
    
    func addPremiumShadow(_ shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = JobsUIPolish.Shadow.medium) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    func smoothCorners(_ radius: CGFloat = JobsUIPolish.CornerRadius.md) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius))
    }
    
    func premiumPadding(_ edges: Edge.Set = .all, _ length: CGFloat = JobsUIPolish.Spacing.lg) -> some View {
        padding(edges, length)
    }
}

// MARK: - Loading States
struct PremiumProgressView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color.theme.primary))
            .scaleEffect(1.2)
    }
}

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: phase)
                    .clipped()
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 400
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}