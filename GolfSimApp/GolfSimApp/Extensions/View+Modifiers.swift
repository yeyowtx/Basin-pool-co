import SwiftUI

// MARK: - Premium View Modifiers
// Comprehensive collection of reusable view modifiers

extension View {
    // MARK: - Layout Modifiers
    func centerHorizontally() -> some View {
        frame(maxWidth: .infinity, alignment: .center)
    }
    
    func centerVertically() -> some View {
        frame(maxHeight: .infinity, alignment: .center)
    }
    
    func fillWidth(alignment: Alignment = .center) -> some View {
        frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func fillHeight(alignment: Alignment = .center) -> some View {
        frame(maxHeight: .infinity, alignment: alignment)
    }
    
    func fillContainer(alignment: Alignment = .center) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
    
    // MARK: - Conditional Modifiers
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func ifLet<Content: View, T>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
    
    // MARK: - Appearance Modifiers
    func roundedBorder(
        color: Color = Color(.systemGray4),
        lineWidth: CGFloat = 1,
        cornerRadius: CGFloat = JobsUIPolish.CornerRadius.md
    ) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(color, lineWidth: lineWidth)
        )
    }
    
    func backgroundCard(
        color: Color = Color(.systemBackground),
        cornerRadius: CGFloat = JobsUIPolish.CornerRadius.lg,
        shadow: Bool = true
    ) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color)
                .if(shadow) { shape in
                    shape.addPremiumShadow()
                }
        )
    }
    
    func glassBackground(
        cornerRadius: CGFloat = JobsUIPolish.CornerRadius.lg
    ) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Interactive Modifiers
    func pressableScale(scale: CGFloat = 0.96) -> some View {
        scaleEffect(scale)
        .animation(JobsUIPolish.Animation.snappy, value: scale)
    }
    
    func bounceOnTap() -> some View {
        modifier(BounceModifier())
    }
    
    func pulseOnAppear() -> some View {
        modifier(PulseModifier())
    }
    
    // MARK: - Loading States
    func loading(_ isLoading: Bool) -> some View {
        overlay(
            Group {
                if isLoading {
                    RoundedRectangle(cornerRadius: JobsUIPolish.CornerRadius.md)
                        .fill(Color(.systemBackground).opacity(0.8))
                        .overlay(
                            PremiumProgressView()
                        )
                }
            }
        )
        .disabled(isLoading)
    }
    
    func skeletonLoader(_ isLoading: Bool) -> some View {
        if isLoading {
            self
                .redacted(reason: .placeholder)
                .shimmer()
        } else {
            self
        }
    }
    
    // MARK: - Empty States
    func emptyState<EmptyContent: View>(
        isEmpty: Bool,
        @ViewBuilder emptyContent: () -> EmptyContent
    ) -> some View {
        if isEmpty {
            emptyContent()
        } else {
            self
        }
    }
    
    // MARK: - Accessibility
    func accessibilityAction(
        _ actionKind: AccessibilityActionKind = .default,
        _ handler: @escaping () -> Void
    ) -> some View {
        accessibilityAction(actionKind, handler)
    }
    
    func accessibilityGroup() -> some View {
        accessibilityElement(children: .combine)
    }
    
    // MARK: - Keyboard
    func hideKeyboardOnTap() -> some View {
        onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
    
    // MARK: - Navigation
    func navigationBarTitleDisplayMode(_ displayMode: NavigationBarItem.TitleDisplayMode) -> some View {
        navigationBarTitleDisplayMode(displayMode)
    }
    
    // MARK: - Safe Area
    func ignoreSafeArea(_ regions: SafeAreaRegions = .all, edges: Edge.Set = .all) -> some View {
        ignoresSafeArea(regions, edges: edges)
    }
    
    // MARK: - Device Specific
    func phoneOnly<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            content()
        } else {
            self
        }
    }
    
    func padOnly<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            content()
        } else {
            self
        }
    }
    
    // MARK: - Alerts and Sheets
    func errorAlert(
        isPresented: Binding<Bool>,
        error: Error?
    ) -> some View {
        alert(
            "Error",
            isPresented: isPresented,
            presenting: error
        ) { _ in
            Button("OK") {
                isPresented.wrappedValue = false
            }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}

// MARK: - Custom Modifiers
struct BounceModifier: ViewModifier {
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onTapGesture {
                withAnimation(JobsUIPolish.Animation.bounce) {
                    scale = 0.9
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(JobsUIPolish.Animation.bounce) {
                        scale = 1.0
                    }
                }
            }
    }
}

struct PulseModifier: ViewModifier {
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = 1.05
                }
            }
    }
}

struct SlideInModifier: ViewModifier {
    let direction: SlideDirection
    @State private var offset: CGFloat = 100
    
    enum SlideDirection {
        case left, right, top, bottom
    }
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: direction == .left ? -offset : direction == .right ? offset : 0,
                y: direction == .top ? -offset : direction == .bottom ? offset : 0
            )
            .onAppear {
                withAnimation(JobsUIPolish.Animation.smooth) {
                    offset = 0
                }
            }
    }
}

extension View {
    func slideIn(from direction: SlideInModifier.SlideDirection) -> some View {
        modifier(SlideInModifier(direction: direction))
    }
}

// MARK: - Conditional Styling
struct ConditionalStyle<TrueContent: View, FalseContent: View>: ViewModifier {
    let condition: Bool
    let trueStyle: () -> TrueContent
    let falseStyle: () -> FalseContent
    
    func body(content: Content) -> some View {
        if condition {
            content.overlay(trueStyle())
        } else {
            content.overlay(falseStyle())
        }
    }
}

extension View {
    func conditionalStyle<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        @ViewBuilder trueStyle: @escaping () -> TrueContent,
        @ViewBuilder falseStyle: @escaping () -> FalseContent
    ) -> some View {
        modifier(ConditionalStyle(
            condition: condition,
            trueStyle: trueStyle,
            falseStyle: falseStyle
        ))
    }
}

// MARK: - Responsive Design
extension View {
    func responsiveFont(
        phone: Font = .bodyMedium,
        pad: Font = .headlineSmall
    ) -> some View {
        font(UIDevice.current.userInterfaceIdiom == .pad ? pad : phone)
    }
    
    func responsivePadding(
        phone: CGFloat = JobsUIPolish.Spacing.md,
        pad: CGFloat = JobsUIPolish.Spacing.xl
    ) -> some View {
        padding(UIDevice.current.userInterfaceIdiom == .pad ? pad : phone)
    }
    
    func responsiveSpacing(
        phone: CGFloat = JobsUIPolish.Spacing.md,
        pad: CGFloat = JobsUIPolish.Spacing.lg
    ) -> some View {
        if let stack = self as? VStack<AnyView> {
            return AnyView(
                VStack(spacing: UIDevice.current.userInterfaceIdiom == .pad ? pad : phone) {
                    stack
                }
            )
        } else if let stack = self as? HStack<AnyView> {
            return AnyView(
                HStack(spacing: UIDevice.current.userInterfaceIdiom == .pad ? pad : phone) {
                    stack
                }
            )
        } else {
            return AnyView(self)
        }
    }
}