//
//  MembershipCard.swift
//  TopGolf-Inspired Golf Sim App
//
//  Membership display and management components with exact TopGolf styling
//  Handles membership tiers, benefits, and upgrade flows
//

import SwiftUI

// MARK: - Membership Card View
struct MembershipCard: View {
    let membership: Membership
    let onUpgrade: (() -> Void)?
    let onManage: (() -> Void)?
    let showUpgradeButton: Bool
    
    @Environment(\.topgolfTheme) private var theme
    @State private var showingBenefits = false
    
    init(membership: Membership,
         onUpgrade: (() -> Void)? = nil,
         onManage: (() -> Void)? = nil,
         showUpgradeButton: Bool = true) {
        self.membership = membership
        self.onUpgrade = onUpgrade
        self.onManage = onManage
        self.showUpgradeButton = showUpgradeButton
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Membership Header
            MembershipCardHeader(membership: membership)
            
            // Membership Content
            MembershipCardContent(
                membership: membership,
                showingBenefits: $showingBenefits
            )
            
            // Action Buttons
            if showUpgradeButton || onManage != nil {
                MembershipCardActions(
                    membership: membership,
                    onUpgrade: onUpgrade,
                    onManage: onManage,
                    showUpgradeButton: showUpgradeButton
                )
            }
        }
        .background(Color.backgroundPrimary)
        .cornerRadius(TopgolfRadius.card)
        .shadow(
            color: TopgolfShadows.card.color,
            radius: TopgolfShadows.card.radius,
            x: TopgolfShadows.card.x,
            y: TopgolfShadows.card.y
        )
        .overlay(
            RoundedRectangle(cornerRadius: TopgolfRadius.card)
                .stroke(membership.tier.borderColor, lineWidth: 2)
        )
    }
}

// MARK: - Membership Card Header
struct MembershipCardHeader: View {
    let membership: Membership
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: membership.tier.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: TopgolfSpacing.sm) {
                HStack {
                    // Membership Tier Icon
                    Image(systemName: membership.tier.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 40, height: 40)
                        )
                    
                    Spacer()
                    
                    // Status Badge
                    MembershipStatusBadge(status: membership.status)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: TopgolfSpacing.xxs) {
                        ThemedText(text: membership.tier.displayName.uppercased(), style: .headingLarge)
                            .foregroundColor(.white)
                            .tracking(1.5)
                        
                        Text("MEMBER")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .tracking(2.0)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("ID")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(1.0)
                        
                        Text(membership.memberNumber)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .tracking(1.0)
                    }
                }
            }
            .padding(TopgolfSpacing.md)
        }
        .frame(height: 120)
    }
}

// MARK: - Membership Status Badge
struct MembershipStatusBadge: View {
    let status: MembershipStatus
    
    var body: some View {
        HStack(spacing: TopgolfSpacing.xxs) {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            
            Text(status.displayName.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white)
                .tracking(1.0)
        }
        .padding(.horizontal, TopgolfSpacing.xs)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.2))
        .cornerRadius(TopgolfRadius.xs)
    }
    
    private var statusColor: Color {
        switch status {
        case .active: return .topgolfSuccess
        case .expired: return .topgolfError
        case .suspended: return .topgolfWarning
        case .pending: return .topgolfInfo
        }
    }
}

// MARK: - Membership Card Content
struct MembershipCardContent: View {
    let membership: Membership
    @Binding var showingBenefits: Bool
    
    var body: some View {
        VStack(spacing: TopgolfSpacing.md) {
            // Member Information
            MemberInfoSection(membership: membership)
            
            // Current Benefits
            MembershipBenefitsSection(
                membership: membership,
                showingBenefits: $showingBenefits
            )
            
            // Usage Statistics
            if membership.hasUsageData {
                MembershipUsageSection(membership: membership)
            }
            
            // Billing Information
            MembershipBillingSection(membership: membership)
        }
        .padding(TopgolfSpacing.md)
    }
}

// MARK: - Member Info Section
struct MemberInfoSection: View {
    let membership: Membership
    
    var body: some View {
        VStack(spacing: TopgolfSpacing.sm) {
            HStack {
                ThemedText(text: "MEMBER DETAILS", style: .labelMedium)
                    .foregroundColor(.textTertiary)
                    .tracking(1.0)
                
                Spacer()
            }
            
            VStack(spacing: TopgolfSpacing.xs) {
                MemberInfoRow(
                    label: "Name",
                    value: "\(membership.firstName) \(membership.lastName)"
                )
                
                MemberInfoRow(
                    label: "Email",
                    value: membership.email
                )
                
                MemberInfoRow(
                    label: "Phone",
                    value: membership.formattedPhone
                )
                
                MemberInfoRow(
                    label: "Member Since",
                    value: membership.joinDateFormatted
                )
                
                if let expirationDate = membership.expirationDate {
                    MemberInfoRow(
                        label: membership.tier.isAnnual ? "Renews" : "Expires",
                        value: DateFormatter.membershipDateFormatter.string(from: expirationDate),
                        valueColor: membership.isExpiringSoon ? .topgolfWarning : .textSecondary
                    )
                }
            }
        }
    }
}

struct MemberInfoRow: View {
    let label: String
    let value: String
    let valueColor: Color
    
    init(label: String, value: String, valueColor: Color = .textSecondary) {
        self.label = label
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(TopgolfFonts.bodySmall)
                .foregroundColor(.textTertiary)
            
            Spacer()
            
            Text(value)
                .font(TopgolfFonts.bodySmall)
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - Membership Benefits Section
struct MembershipBenefitsSection: View {
    let membership: Membership
    @Binding var showingBenefits: Bool
    
    var body: some View {
        VStack(spacing: TopgolfSpacing.sm) {
            Button(action: {
                withAnimation(TopgolfAnimations.springFast) {
                    showingBenefits.toggle()
                }
            }) {
                HStack {
                    ThemedText(text: "MEMBER BENEFITS", style: .labelMedium)
                        .foregroundColor(.textTertiary)
                        .tracking(1.0)
                    
                    Spacer()
                    
                    Image(systemName: showingBenefits ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textTertiary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if showingBenefits {
                VStack(spacing: TopgolfSpacing.xs) {
                    ForEach(membership.tier.benefits, id: \.self) { benefit in
                        BenefitRow(benefit: benefit)
                    }
                }
                .transition(.slide.combined(with: .opacity))
            }
        }
    }
}

struct BenefitRow: View {
    let benefit: String
    
    var body: some View {
        HStack(spacing: TopgolfSpacing.xs) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(.topgolfSuccess)
            
            Text(benefit)
                .font(TopgolfFonts.bodySmall)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}

// MARK: - Membership Usage Section
struct MembershipUsageSection: View {
    let membership: Membership
    
    var body: some View {
        VStack(spacing: TopgolfSpacing.sm) {
            HStack {
                ThemedText(text: "THIS MONTH", style: .labelMedium)
                    .foregroundColor(.textTertiary)
                    .tracking(1.0)
                
                Spacer()
            }
            
            HStack(spacing: TopgolfSpacing.lg) {
                UsageStatCard(
                    icon: "clock",
                    title: "Sessions",
                    value: "\(membership.monthlyUsage.sessions)",
                    subtitle: "this month"
                )
                
                UsageStatCard(
                    icon: "dollarsign.circle",
                    title: "Saved",
                    value: "$\(Int(membership.monthlyUsage.totalSavings))",
                    subtitle: "in discounts"
                )
                
                UsageStatCard(
                    icon: "calendar",
                    title: "Hours",
                    value: String(format: "%.1f", membership.monthlyUsage.totalHours),
                    subtitle: "played"
                )
            }
        }
    }
}

struct UsageStatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: TopgolfSpacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.topgolfBlue)
            
            Text(value)
                .font(TopgolfFonts.priceMedium)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.textTertiary)
                
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundColor(.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, TopgolfSpacing.xs)
        .background(Color.backgroundSecondary)
        .cornerRadius(TopgolfRadius.sm)
    }
}

// MARK: - Membership Billing Section
struct MembershipBillingSection: View {
    let membership: Membership
    
    var body: some View {
        VStack(spacing: TopgolfSpacing.sm) {
            HStack {
                ThemedText(text: "BILLING", style: .labelMedium)
                    .foregroundColor(.textTertiary)
                    .tracking(1.0)
                
                Spacer()
            }
            
            VStack(spacing: TopgolfSpacing.xs) {
                BillingInfoRow(
                    label: "Monthly Fee",
                    value: "$\(String(format: "%.2f", membership.monthlyFee))"
                )
                
                if let lastPayment = membership.lastPaymentDate {
                    BillingInfoRow(
                        label: "Last Payment",
                        value: DateFormatter.membershipDateFormatter.string(from: lastPayment)
                    )
                }
                
                if let nextPayment = membership.nextPaymentDate {
                    BillingInfoRow(
                        label: "Next Payment",
                        value: DateFormatter.membershipDateFormatter.string(from: nextPayment),
                        valueColor: membership.hasPaymentIssue ? .topgolfError : .textSecondary
                    )
                }
                
                if let paymentMethod = membership.paymentMethod {
                    BillingInfoRow(
                        label: "Payment Method",
                        value: paymentMethod.displayName
                    )
                }
            }
        }
    }
}

struct BillingInfoRow: View {
    let label: String
    let value: String
    let valueColor: Color
    
    init(label: String, value: String, valueColor: Color = .textSecondary) {
        self.label = label
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(TopgolfFonts.bodySmall)
                .foregroundColor(.textTertiary)
            
            Spacer()
            
            Text(value)
                .font(TopgolfFonts.bodySmall)
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - Membership Card Actions
struct MembershipCardActions: View {
    let membership: Membership
    let onUpgrade: (() -> Void)?
    let onManage: (() -> Void)?
    let showUpgradeButton: Bool
    
    var body: some View {
        VStack(spacing: TopgolfSpacing.sm) {
            Divider()
                .background(Color.borderPrimary)
            
            HStack(spacing: TopgolfSpacing.sm) {
                // Manage Membership Button
                if let onManage = onManage {
                    Button(action: onManage) {
                        HStack(spacing: TopgolfSpacing.xs) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 14, weight: .medium))
                            
                            Text("Manage")
                                .font(TopgolfFonts.labelMedium)
                        }
                        .foregroundColor(.topgolfBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, TopgolfSpacing.sm)
                        .background(Color.topgolfBlue.opacity(0.1))
                        .cornerRadius(TopgolfRadius.button)
                        .overlay(
                            RoundedRectangle(cornerRadius: TopgolfRadius.button)
                                .stroke(Color.topgolfBlue, lineWidth: 1)
                        )
                    }
                }
                
                // Upgrade Button
                if showUpgradeButton, let onUpgrade = onUpgrade, !membership.tier.isHighestTier {
                    Button(action: onUpgrade) {
                        HStack(spacing: TopgolfSpacing.xs) {
                            Image(systemName: "arrow.up.circle")
                                .font(.system(size: 14, weight: .medium))
                            
                            Text("Upgrade")
                                .font(TopgolfFonts.labelMedium)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, TopgolfSpacing.sm)
                        .background(Color.topgolfOrange)
                        .cornerRadius(TopgolfRadius.button)
                    }
                }
            }
        }
        .padding(.horizontal, TopgolfSpacing.md)
        .padding(.bottom, TopgolfSpacing.md)
    }
}

// MARK: - Compact Membership Card
struct CompactMembershipCard: View {
    let membership: Membership
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: TopgolfSpacing.md) {
                // Tier Icon
                Image(systemName: membership.tier.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        LinearGradient(
                            colors: membership.tier.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(TopgolfRadius.sm)
                
                // Membership Info
                VStack(alignment: .leading, spacing: TopgolfSpacing.xxs) {
                    Text(membership.tier.displayName)
                        .font(TopgolfFonts.headingMedium)
                        .foregroundColor(.textPrimary)
                    
                    Text("Member #\(membership.memberNumber)")
                        .font(TopgolfFonts.bodySmall)
                        .foregroundColor(.textSecondary)
                    
                    HStack {
                        Text(membership.status.displayName)
                            .font(TopgolfFonts.caption)
                            .foregroundColor(membership.status == .active ? .topgolfSuccess : .topgolfWarning)
                        
                        if membership.tier.hasMonthlyFee {
                            Text("• $\(String(format: "%.0f", membership.monthlyFee))/month")
                                .font(TopgolfFonts.caption)
                                .foregroundColor(.textTertiary)
                        }
                    }
                }
                
                Spacer()
                
                // Status Indicator
                VStack {
                    Circle()
                        .fill(membership.status == .active ? Color.topgolfSuccess : Color.topgolfWarning)
                        .frame(width: 12, height: 12)
                    
                    Spacer()
                }
            }
            .padding(TopgolfSpacing.md)
            .background(Color.backgroundPrimary)
            .cornerRadius(TopgolfRadius.card)
            .shadow(
                color: TopgolfShadows.card.color,
                radius: TopgolfShadows.card.radius,
                x: TopgolfShadows.card.x,
                y: TopgolfShadows.card.y
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Membership Tier Badge
struct MembershipTierBadge: View {
    let tier: MembershipTier
    let size: BadgeSize
    
    enum BadgeSize {
        case small, medium, large
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 18
            case .large: return 24
            }
        }
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)
            case .medium: return EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)
            case .large: return EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
            }
        }
        
        var font: Font {
            switch self {
            case .small: return .system(size: 10, weight: .bold)
            case .medium: return .system(size: 12, weight: .bold)
            case .large: return .system(size: 14, weight: .bold)
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: tier.icon)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundColor(.white)
            
            Text(tier.displayName.uppercased())
                .font(size.font)
                .foregroundColor(.white)
                .tracking(1.0)
        }
        .padding(size.padding)
        .background(
            LinearGradient(
                colors: tier.gradientColors,
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(TopgolfRadius.xs)
    }
}

// MARK: - Extensions
extension DateFormatter {
    static let membershipDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

extension MembershipTier {
    var gradientColors: [Color] {
        switch self {
        case .basic: return [.topgolfBlue, .topgolfBlue.opacity(0.8)]
        case .premium: return [.topgolfOrange, .topgolfOrange.opacity(0.8)]
        case .elite: return [.purple, .purple.opacity(0.8)]
        case .corporate: return [.topgolfSuccess, .topgolfSuccess.opacity(0.8)]
        }
    }
    
    var borderColor: Color {
        switch self {
        case .basic: return .topgolfBlue.opacity(0.3)
        case .premium: return .topgolfOrange.opacity(0.3)
        case .elite: return .purple.opacity(0.3)
        case .corporate: return .topgolfSuccess.opacity(0.3)
        }
    }
    
    var icon: String {
        switch self {
        case .basic: return "person.circle"
        case .premium: return "star.circle"
        case .elite: return "crown"
        case .corporate: return "building.2.crop.circle"
        }
    }
}

// MARK: - Preview
#if DEBUG
struct MembershipCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: TopgolfSpacing.lg) {
                MembershipCard(
                    membership: Membership.sampleMemberships.first!,
                    onUpgrade: {},
                    onManage: {},
                    showUpgradeButton: true
                )
                
                CompactMembershipCard(
                    membership: Membership.sampleMemberships.first!,
                    onTap: {}
                )
                
                HStack {
                    MembershipTierBadge(tier: .basic, size: .small)
                    MembershipTierBadge(tier: .premium, size: .medium)
                    MembershipTierBadge(tier: .elite, size: .large)
                }
            }
            .padding(TopgolfSpacing.md)
        }
        .background(Color.backgroundTertiary)
        .topgolfTheme(.topgolf)
    }
}
#endif