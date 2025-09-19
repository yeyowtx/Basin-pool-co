import SwiftUI

// MARK: - Typography System
// Apple Human Interface Guidelines compliant typography

extension Text {
    // MARK: - Display Typography
    func displayLarge() -> some View {
        self.font(.displayLarge)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
    }
    
    func displayMedium() -> some View {
        self.font(.displayMedium)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
    }
    
    func displaySmall() -> some View {
        self.font(.displaySmall)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
    }
    
    // MARK: - Headline Typography
    func headlineLarge() -> some View {
        self.font(.headlineLarge)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
    
    func headlineMedium() -> some View {
        self.font(.headlineMedium)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
    
    func headlineSmall() -> some View {
        self.font(.headlineSmall)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
    
    // MARK: - Body Typography
    func bodyLarge() -> some View {
        self.font(.bodyLarge)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
    }
    
    func bodyMedium() -> some View {
        self.font(.bodyMedium)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
    }
    
    func bodySmall() -> some View {
        self.font(.bodySmall)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
    }
    
    // MARK: - Label Typography
    func labelLarge() -> some View {
        self.font(.labelLarge)
            .lineLimit(1)
    }
    
    func labelMedium() -> some View {
        self.font(.labelMedium)
            .lineLimit(1)
    }
    
    func labelSmall() -> some View {
        self.font(.labelSmall)
            .lineLimit(1)
    }
    
    // MARK: - Caption Typography
    func captionLarge() -> some View {
        self.font(.captionLarge)
            .foregroundColor(.secondary)
            .lineLimit(2)
    }
    
    func captionSmall() -> some View {
        self.font(.captionSmall)
            .foregroundColor(.secondary)
            .lineLimit(2)
    }
    
    // MARK: - Semantic Styles
    func primaryText() -> some View {
        self.foregroundColor(.primary)
    }
    
    func secondaryText() -> some View {
        self.foregroundColor(.secondary)
    }
    
    func accentText() -> some View {
        self.foregroundColor(Color.theme.primary)
    }
    
    func warningText() -> some View {
        self.foregroundColor(Color.theme.warning)
    }
    
    func errorText() -> some View {
        self.foregroundColor(Color.theme.error)
    }
    
    func successText() -> some View {
        self.foregroundColor(Color.theme.available)
    }
    
    // MARK: - Weight Modifiers
    func medium() -> some View {
        self.fontWeight(.medium)
    }
    
    func semibold() -> some View {
        self.fontWeight(.semibold)
    }
    
    func bold() -> some View {
        self.fontWeight(.bold)
    }
    
    // MARK: - Special Text Styles
    func monospaced() -> some View {
        self.font(.system(.body, design: .monospaced))
    }
    
    func rounded() -> some View {
        self.font(.system(.body, design: .rounded))
    }
    
    func serif() -> some View {
        self.font(.system(.body, design: .serif))
    }
}

// MARK: - Text Field Styles
struct PremiumTextFieldStyle: TextFieldStyle {
    let variant: TextFieldVariant
    
    enum TextFieldVariant {
        case standard, outlined, filled
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.bodyMedium)
            .padding(.horizontal, JobsUIPolish.Spacing.md)
            .padding(.vertical, JobsUIPolish.Spacing.sm)
            .background(
                Group {
                    switch variant {
                    case .standard:
                        Rectangle()
                            .fill(Color.clear)
                    case .outlined:
                        RoundedRectangle(cornerRadius: JobsUIPolish.CornerRadius.sm)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    case .filled:
                        RoundedRectangle(cornerRadius: JobsUIPolish.CornerRadius.sm)
                            .fill(Color(.systemGray6))
                    }
                }
            )
    }
}

// MARK: - Rich Text Components
struct RichText: View {
    let title: String
    let subtitle: String?
    let caption: String?
    let alignment: HorizontalAlignment
    
    init(
        _ title: String,
        subtitle: String? = nil,
        caption: String? = nil,
        alignment: HorizontalAlignment = .leading
    ) {
        self.title = title
        self.subtitle = subtitle
        self.caption = caption
        self.alignment = alignment
    }
    
    var body: some View {
        VStack(alignment: alignment, spacing: JobsUIPolish.Spacing.xs) {
            Text(title)
                .headlineSmall()
                .multilineTextAlignment(textAlignment)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .bodyMedium()
                    .secondaryText()
                    .multilineTextAlignment(textAlignment)
            }
            
            if let caption = caption {
                Text(caption)
                    .captionLarge()
                    .multilineTextAlignment(textAlignment)
            }
        }
    }
    
    private var textAlignment: TextAlignment {
        switch alignment {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        default: return .leading
        }
    }
}

// MARK: - Animated Text
struct AnimatedText: View {
    let text: String
    let font: Font
    @State private var animatedText = ""
    @State private var currentIndex = 0
    
    init(_ text: String, font: Font = .bodyMedium) {
        self.text = text
        self.font = font
    }
    
    var body: some View {
        Text(animatedText)
            .font(font)
            .onAppear {
                animateText()
            }
    }
    
    private func animateText() {
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if currentIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: currentIndex)
                animatedText = String(text[...index])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

// MARK: - Text Helpers
extension String {
    func highlighted(searchText: String) -> AttributedString {
        var attributedString = AttributedString(self)
        
        if !searchText.isEmpty,
           let range = self.range(of: searchText, options: .caseInsensitive) {
            let nsRange = NSRange(range, in: self)
            if let attributedRange = Range(nsRange, in: attributedString) {
                attributedString[attributedRange].backgroundColor = Color.theme.primary.opacity(0.3)
                attributedString[attributedRange].foregroundColor = Color.theme.primary
            }
        }
        
        return attributedString
    }
    
    func truncated(to length: Int) -> String {
        if self.count <= length {
            return self
        } else {
            return String(self.prefix(length)) + "..."
        }
    }
}