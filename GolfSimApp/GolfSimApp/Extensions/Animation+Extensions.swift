import SwiftUI

// MARK: - Animation Extensions
// Comprehensive animation system for smooth, Apple-quality transitions

extension Animation {
    // MARK: - Predefined Animations
    static let ultraSmooth = Animation.timingCurve(0.2, 0.8, 0.2, 1.0, duration: 0.4)
    static let quickSnap = Animation.timingCurve(0.4, 0.0, 0.2, 1.0, duration: 0.3)
    static let gentleBounce = Animation.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.3)
    static let energeticBounce = Animation.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.2)
    static let smoothEase = Animation.easeInOut(duration: 0.35)
    static let quickFade = Animation.easeOut(duration: 0.2)
    
    // MARK: - Contextual Animations
    static let cardFlip = Animation.timingCurve(0.25, 0.46, 0.45, 0.94, duration: 0.5)
    static let modalPresent = Animation.timingCurve(0.17, 0.84, 0.44, 1.0, duration: 0.4)
    static let modalDismiss = Animation.timingCurve(0.36, 0.0, 0.66, -0.56, duration: 0.3)
    static let listItemAppear = Animation.timingCurve(0.25, 0.46, 0.45, 0.94, duration: 0.6)
    static let buttonPress = Animation.timingCurve(0.4, 0.0, 0.6, 1.0, duration: 0.15)
    static let statusChange = Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.25)
    
    // MARK: - Loading Animations
    static let shimmerGlow = Animation.linear(duration: 1.5).repeatForever(autoreverses: false)
    static let pulseHeartbeat = Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
    static let spinContinuous = Animation.linear(duration: 1.0).repeatForever(autoreverses: false)
    
    // MARK: - Gesture Animations
    static let dragResponse = Animation.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.1)
    static let swipeGesture = Animation.timingCurve(0.25, 0.1, 0.25, 1.0, duration: 0.4)
    static let longPressResponse = Animation.spring(response: 0.2, dampingFraction: 0.9, blendDuration: 0.1)
    
    // MARK: - Page Transitions
    static let pageSlide = Animation.timingCurve(0.23, 1.0, 0.32, 1.0, duration: 0.5)
    static let pageFade = Animation.timingCurve(0.25, 0.46, 0.45, 0.94, duration: 0.4)
    static let pageZoom = Animation.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3)
    
    // MARK: - Notification Animations
    static let notificationSlideIn = Animation.timingCurve(0.17, 0.67, 0.83, 0.67, duration: 0.4)
    static let notificationSlideOut = Animation.timingCurve(0.17, 0.67, 0.83, 0.67, duration: 0.3)
    static let alertBounce = Animation.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.2)
    
    // MARK: - Value Change Animations
    static let counterIncrement = Animation.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.1)
    static let progressUpdate = Animation.timingCurve(0.25, 0.1, 0.25, 1.0, duration: 0.6)
    static let chartUpdate = Animation.timingCurve(0.4, 0.0, 0.2, 1.0, duration: 0.8)
}

// MARK: - View Animation Extensions
extension View {
    // MARK: - Entrance Animations
    func slideInFromLeading(delay: Double = 0) -> some View {
        modifier(SlideInAnimation(direction: .leading, delay: delay))
    }
    
    func slideInFromTrailing(delay: Double = 0) -> some View {
        modifier(SlideInAnimation(direction: .trailing, delay: delay))
    }
    
    func slideInFromTop(delay: Double = 0) -> some View {
        modifier(SlideInAnimation(direction: .top, delay: delay))
    }
    
    func slideInFromBottom(delay: Double = 0) -> some View {
        modifier(SlideInAnimation(direction: .bottom, delay: delay))
    }
    
    func fadeIn(delay: Double = 0, duration: Double = 0.4) -> some View {
        modifier(FadeInAnimation(delay: delay, duration: duration))
    }
    
    func scaleIn(delay: Double = 0, scale: CGFloat = 0.8) -> some View {
        modifier(ScaleInAnimation(delay: delay, initialScale: scale))
    }
    
    // MARK: - Interactive Animations
    func pressAnimation(scale: CGFloat = 0.95) -> some View {
        modifier(PressAnimationModifier(pressedScale: scale))
    }
    
    func hoverAnimation(scale: CGFloat = 1.05) -> some View {
        modifier(HoverAnimationModifier(hoverScale: scale))
    }
    
    func wiggle(isActive: Bool = false) -> some View {
        modifier(WiggleAnimation(isActive: isActive))
    }
    
    // MARK: - Loading Animations
    func skeletonLoading(isActive: Bool) -> some View {
        modifier(SkeletonAnimation(isActive: isActive))
    }
    
    func breathingEffect(isActive: Bool = true) -> some View {
        modifier(BreathingAnimation(isActive: isActive))
    }
    
    // MARK: - Rotation Animations
    func rotateOnAppear(duration: Double = 1.0, clockwise: Bool = true) -> some View {
        modifier(RotationAnimation(duration: duration, clockwise: clockwise))
    }
    
    // MARK: - Path Animations
    func drawPath(isActive: Bool) -> some View {
        modifier(PathDrawAnimation(isActive: isActive))
    }
}

// MARK: - Animation Modifiers

struct SlideInAnimation: ViewModifier {
    enum Direction {
        case leading, trailing, top, bottom
    }
    
    let direction: Direction
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: isVisible ? 0 : offsetX,
                y: isVisible ? 0 : offsetY
            )
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.ultraSmooth.delay(delay)) {
                    isVisible = true
                }
            }
    }
    
    private var offsetX: CGFloat {
        switch direction {
        case .leading: return -50
        case .trailing: return 50
        default: return 0
        }
    }
    
    private var offsetY: CGFloat {
        switch direction {
        case .top: return -50
        case .bottom: return 50
        default: return 0
        }
    }
}

struct FadeInAnimation: ViewModifier {
    let delay: Double
    let duration: Double
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: duration).delay(delay)) {
                    opacity = 1
                }
            }
    }
}

struct ScaleInAnimation: ViewModifier {
    let delay: Double
    let initialScale: CGFloat
    @State private var scale: CGFloat
    
    init(delay: Double, initialScale: CGFloat) {
        self.delay = delay
        self.initialScale = initialScale
        self._scale = State(initialValue: initialScale)
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(scale == initialScale ? 0 : 1)
            .onAppear {
                withAnimation(.gentleBounce.delay(delay)) {
                    scale = 1.0
                }
            }
    }
}

struct PressAnimationModifier: ViewModifier {
    let pressedScale: CGFloat
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? pressedScale : 1.0)
            .onLongPressGesture(
                minimumDuration: 0,
                maximumDistance: .infinity,
                pressing: { pressing in
                    withAnimation(.buttonPress) {
                        isPressed = pressing
                    }
                },
                perform: {}
            )
    }
}

struct HoverAnimationModifier: ViewModifier {
    let hoverScale: CGFloat
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? hoverScale : 1.0)
            .onHover { hovering in
                withAnimation(.quickSnap) {
                    isHovered = hovering
                }
            }
    }
}

struct WiggleAnimation: ViewModifier {
    let isActive: Bool
    @State private var rotation: Double = 0
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .onChange(of: isActive) { active in
                if active {
                    withAnimation(.easeInOut(duration: 0.1).repeatCount(6, autoreverses: true)) {
                        rotation = 5
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.2)) {
                        rotation = 0
                    }
                }
            }
    }
}

struct SkeletonAnimation: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isActive {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        Color.white.opacity(0.4),
                                        Color.clear
                                    ],
                                    startPoint: UnitPoint(x: phase - 0.3, y: 0.5),
                                    endPoint: UnitPoint(x: phase + 0.3, y: 0.5)
                                )
                            )
                    }
                }
            )
            .mask(content)
            .onAppear {
                if isActive {
                    withAnimation(.shimmerGlow) {
                        phase = 1.3
                    }
                }
            }
    }
}

struct BreathingAnimation: ViewModifier {
    let isActive: Bool
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                if isActive {
                    withAnimation(.pulseHeartbeat) {
                        scale = 1.05
                    }
                }
            }
    }
}

struct RotationAnimation: ViewModifier {
    let duration: Double
    let clockwise: Bool
    @State private var rotation: Double = 0
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    rotation = clockwise ? 360 : -360
                }
            }
    }
}

struct PathDrawAnimation: ViewModifier {
    let isActive: Bool
    @State private var progress: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .modifier(AnimatableModifier(progress: progress))
            .onAppear {
                if isActive {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        progress = 1.0
                    }
                }
            }
    }
}

struct AnimatableModifier: ViewModifier, Animatable {
    var progress: CGFloat
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(
                Rectangle()
                    .size(
                        width: UIScreen.main.bounds.width * progress,
                        height: UIScreen.main.bounds.height
                    )
            )
    }
}

// MARK: - Transition Extensions
extension AnyTransition {
    static let slideFromLeading = AnyTransition.asymmetric(
        insertion: .move(edge: .leading).combined(with: .opacity),
        removal: .move(edge: .trailing).combined(with: .opacity)
    )
    
    static let slideFromTrailing = AnyTransition.asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal: .move(edge: .leading).combined(with: .opacity)
    )
    
    static let scaleAndFade = AnyTransition.scale.combined(with: .opacity)
    
    static let flipCard = AnyTransition.asymmetric(
        insertion: .scale(scale: 0.1, anchor: .center).combined(with: .opacity),
        removal: .scale(scale: 2.0, anchor: .center).combined(with: .opacity)
    )
}