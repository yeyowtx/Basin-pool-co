//
//  PricingCard.swift
//  TopGolf-Inspired Golf Sim App
//
//  Pricing display components with exact TopGolf transparency and styling
//  Shows pricing tiers, member benefits, and promotional offers
//

import SwiftUI

// MARK: - Today's Pricing Card
struct TodaysPricingCard: View {
    let venue: Venue
    let currentTier: PricingTier?
    let allTiers: [PricingTier]
    let showMemberPricing: Bool
    let onViewAllTapped: () -> Void
    
    @Environment(\.topgolfTheme) private var theme
    @State private var selectedTierIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            PricingCardHeader(
                title: "TODAY'S PRICING",
                subtitle: venue.name,
                onViewAllTapped: onViewAllTapped
            )
            
            // Current Active Tier (if available)
            if let currentTier = currentTier {
                CurrentPricingTier(
                    tier: currentTier,
                    showMemberPricing: showMemberPricing
                )
            }
            
            // All Pricing Tiers
            VStack(spacing: TopgolfSpacing.xs) {
                ForEach(Array(allTiers.enumerated()), id: \.element.id) { index, tier in
                    PricingTierRow(
                        tier: tier,
                        isActive: tier.isCurrentlyActive,
                        showMemberPricing: showMemberPricing,
                        isSelected: selectedTierIndex == index
                    )
                    .onTapGesture {
                        withAnimation(TopgolfAnimations.springFast) {
                            selectedTierIndex = index
                        }
                    }
                }
            }
            .padding(.horizontal, TopgolfSpacing.md)
            .padding(.bottom, TopgolfSpacing.md)
        }
        .background(Color.backgroundSecondary)
        .cornerRadius(TopgolfRadius.card)
        .shadow(
            color: TopgolfShadows.card.color,
            radius: TopgolfShadows.card.radius,
            x: TopgolfShadows.card.x,
            y: TopgolfShadows.card.y
        )
    }
}

// MARK: - Pricing Card Header
struct PricingCardHeader: View {
    let title: String
    let subtitle: String?
    let onViewAllTapped: () -> Void
    
    init(title: String, subtitle: String? = nil, onViewAllTapped: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.onViewAllTapped = onViewAllTapped
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                ThemedText(text: title, style: .headingSmall)
                    .foregroundColor(.textPrimary)
                    .tracking(1.0)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(TopgolfFonts.caption)
                        .foregroundColor(.textTertiary)
                }
            }
            
            Spacer()
            
            Button("View All") {
                onViewAllTapped()
            }
            .font(TopgolfFonts.labelSmall)
            .foregroundColor(.topgolfBlue)
            .tracking(0.5)
        }
        .padding(.horizontal, TopgolfSpacing.md)
        .padding(.top, TopgolfSpacing.md)
        .padding(.bottom, TopgolfSpacing.sm)
    }
}

// MARK: - Current Pricing Tier
struct CurrentPricingTier: View {
    let tier: PricingTier
    let showMemberPricing: Bool
    
    var body: some View {
        VStack(spacing: TopgolfSpacing.xs) {
            HStack {
                Circle()
                    .fill(Color.pricingTierColor(for: tier.type.rawValue))
                    .frame(width: 12, height: 12)
                
                ThemedText(text: "CURRENT PRICING", style: .caption)
                    .foregroundColor(.topgolfSuccess)
                    .tracking(1.0)
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tier.name)
                        .font(TopgolfFonts.bodyMedium)
                        .foregroundColor(.textPrimary)
                    
                    Text(tier.timeRange)
                        .font(TopgolfFonts.bodySmall)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("$\(Int(tier.basePrice))")
                        .font(TopgolfFonts.priceLarge)
                        .foregroundColor(.textPrimary)
                    
                    Text("/hr simulator")
                        .font(TopgolfFonts.caption)
                        .foregroundColor(.textSecondary)
                    
                    if showMemberPricing {
                        Text("$\(Int(tier.memberPrice)) member")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.topgolfSuccess)
                    }
                }
            }
        }
        .padding(.horizontal, TopgolfSpacing.md)
        .padding(.vertical, TopgolfSpacing.sm)
        .background(Color.topgolfSuccess.opacity(0.05))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.topgolfSuccess.opacity(0.2)),
            alignment: .bottom
        )
    }
}

// MARK: - Pricing Tier Row
struct PricingTierRow: View {
    let tier: PricingTier
    let isActive: Bool
    let showMemberPricing: Bool
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: TopgolfSpacing.sm) {
            // Tier Indicator
            Circle()
                .fill(Color.pricingTierColor(for: tier.type.rawValue))
                .frame(width: 12, height: 12)
            
            // Tier Information
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(tier.name)
                        .font(TopgolfFonts.bodyMedium)
                        .foregroundColor(isActive ? .textPrimary : .textSecondary)
                    
                    if isActive {
                        Text("CURRENT")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.topgolfSuccess)
                            .tracking(1.0)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.topgolfSuccess.opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                }
                
                Text(tier.timeRange)
                    .font(TopgolfFonts.caption)
                    .foregroundColor(.textTertiary)
            }
            
            Spacer()
            
            // Pricing Information
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(Int(tier.basePrice))")
                    .font(TopgolfFonts.priceMedium)
                    .foregroundColor(isActive ? .textPrimary : .textSecondary)
                
                Text("/hr simulator")
                    .font(TopgolfFonts.caption)
                    .foregroundColor(.textTertiary)
                
                if showMemberPricing {
                    Text("$\(Int(tier.memberPrice)) member")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.topgolfSuccess)
                }
            }
        }
        .padding(.vertical, TopgolfSpacing.sm)
        .background(isSelected ? Color.backgroundPrimary : Color.clear)
        .cornerRadius(TopgolfRadius.sm)
        .opacity(isActive ? 1.0 : 0.7)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(TopgolfAnimations.springFast, value: isSelected)
    }
}

// MARK: - Pricing Breakdown Card
struct PricingBreakdownCard: View {
    let bookingPricing: BookingPricing
    let timeSlot: TimeSlot
    let showMembershipUpsell: Bool
    
    var body: some View {
        VStack(spacing: TopgolfSpacing.md) {
            // Header
            HStack {
                ThemedText(text: "PRICING BREAKDOWN", style: .headingSmall)
                    .foregroundColor(.textPrimary)
                    .tracking(1.0)
                
                Spacer()
                
                if bookingPricing.hasDiscount {
                    Text("SAVINGS APPLIED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.topgolfSuccess)
                        .tracking(1.0)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.topgolfSuccess.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            // Pricing Lines
            VStack(spacing: TopgolfSpacing.sm) {
                PricingLine(
                    label: "Simulator Time (\(timeSlot.durationText))",
                    amount: bookingPricing.baseAmount,
                    isSubtotal: false
                )
                
                if bookingPricing.memberDiscount > 0 {
                    PricingLine(
                        label: "Member Discount",
                        amount: -bookingPricing.memberDiscount,
                        isDiscount: true
                    )
                }
                
                if bookingPricing.promoDiscount > 0 {
                    PricingLine(
                        label: "Promotional Discount",
                        amount: -bookingPricing.promoDiscount,
                        isDiscount: true
                    )
                }
                
                Divider()
                    .background(Color.borderPrimary)
                
                PricingLine(
                    label: "Subtotal",
                    amount: bookingPricing.subtotal,
                    isSubtotal: true
                )
                
                if bookingPricing.taxes > 0 {
                    PricingLine(
                        label: "Tax",
                        amount: bookingPricing.taxes,
                        isSubtotal: false
                    )
                }
                
                if bookingPricing.fees > 0 {
                    PricingLine(
                        label: "Processing Fee",
                        amount: bookingPricing.fees,
                        isSubtotal: false
                    )
                }
                
                Divider()
                    .background(Color.borderPrimary)
                
                PricingLine(
                    label: "Total",
                    amount: bookingPricing.totalAmount,
                    isTotal: true
                )
            }
            
            // Deposit Information
            if let depositRequired = bookingPricing.depositRequired {
                DepositInformationView(
                    depositRequired: depositRequired,
                    depositPaid: bookingPricing.depositPaid,
                    remainingBalance: bookingPricing.remainingBalance
                )
            }
            
            // Membership Upsell
            if showMembershipUpsell && bookingPricing.memberDiscount == 0 {
                MembershipUpsellView(potentialSavings: bookingPricing.baseAmount * 0.15)
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
}

// MARK: - Pricing Line Item
struct PricingLine: View {
    let label: String
    let amount: Double
    let isSubtotal: Bool
    let isTotal: Bool
    let isDiscount: Bool
    
    init(label: String, amount: Double, isSubtotal: Bool = false, isTotal: Bool = false, isDiscount: Bool = false) {
        self.label = label
        self.amount = amount
        self.isSubtotal = isSubtotal
        self.isTotal = isTotal
        self.isDiscount = isDiscount
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(isTotal ? TopgolfFonts.labelMedium : TopgolfFonts.bodyMedium)
                .foregroundColor(isTotal ? .textPrimary : .textSecondary)
            
            Spacer()
            
            Text(formattedAmount)
                .font(isTotal ? TopgolfFonts.priceMedium : TopgolfFonts.bodyMedium)
                .foregroundColor(amountColor)
                .fontWeight(isTotal || isSubtotal ? .bold : .regular)
        }
    }
    
    private var formattedAmount: String {
        let absAmount = abs(amount)
        if isDiscount {
            return "-$\(String(format: "%.2f", absAmount))"
        } else {
            return "$\(String(format: "%.2f", absAmount))"
        }
    }
    
    private var amountColor: Color {
        if isDiscount {
            return .topgolfSuccess
        } else if isTotal {
            return .textPrimary
        } else {
            return .textSecondary
        }
    }
}

// MARK: - Deposit Information View
struct DepositInformationView: View {
    let depositRequired: Double
    let depositPaid: Double?
    let remainingBalance: Double
    
    var body: some View {
        VStack(spacing: TopgolfSpacing.sm) {
            HStack {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundColor(.topgolfInfo)
                
                Text("DEPOSIT INFORMATION")
                    .font(TopgolfFonts.labelSmall)
                    .foregroundColor(.textPrimary)
                    .tracking(1.0)
                
                Spacer()
            }
            
            VStack(spacing: TopgolfSpacing.xs) {
                HStack {
                    Text("Required Deposit")
                        .font(TopgolfFonts.bodySmall)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", depositRequired))")
                        .font(TopgolfFonts.bodySmall)
                        .foregroundColor(.textPrimary)
                }
                
                if let paid = depositPaid, paid > 0 {
                    HStack {
                        Text("Deposit Paid")
                            .font(TopgolfFonts.bodySmall)
                            .foregroundColor(.textSecondary)
                        
                        Spacer()
                        
                        Text("$\(String(format: "%.2f", paid))")
                            .font(TopgolfFonts.bodySmall)
                            .foregroundColor(.topgolfSuccess)
                    }
                }
                
                HStack {
                    Text("Due at Location")
                        .font(TopgolfFonts.bodySmall)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", remainingBalance))")
                        .font(TopgolfFonts.bodyMedium)
                        .foregroundColor(.textPrimary)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(TopgolfSpacing.sm)
        .background(Color.backgroundSecondary)
        .cornerRadius(TopgolfRadius.sm)
    }
}

// MARK: - Membership Upsell View
struct MembershipUpsellView: View {
    let potentialSavings: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.topgolfOrange)
                    
                    Text("BECOME A MEMBER")
                        .font(TopgolfFonts.labelSmall)
                        .foregroundColor(.textPrimary)
                        .tracking(1.0)
                }
                
                Text("Save $\(String(format: "%.0f", potentialSavings)) on this booking")
                    .font(TopgolfFonts.bodySmall)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Button("Learn More") {
                // Handle membership info
            }
            .font(TopgolfFonts.labelSmall)
            .foregroundColor(.topgolfBlue)
            .tracking(0.5)
        }
        .padding(TopgolfSpacing.sm)
        .background(Color.topgolfOrange.opacity(0.05))
        .cornerRadius(TopgolfRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: TopgolfRadius.sm)
                .stroke(Color.topgolfOrange.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Promotional Pricing Card
struct PromotionalPricingCard: View {
    let title: String
    let description: String
    let originalPrice: Double
    let discountedPrice: Double
    let validUntil: Date?
    let terms: String?
    
    private var savings: Double {
        originalPrice - discountedPrice
    }
    
    private var savingsPercentage: Double {
        (savings / originalPrice) * 100
    }
    
    var body: some View {
        VStack(spacing: TopgolfSpacing.md) {
            // Promotional Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(TopgolfFonts.headingMedium)
                        .foregroundColor(.topgolfOrange)
                        .fontWeight(.bold)
                    
                    Text(description)
                        .font(TopgolfFonts.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                // Savings Badge
                VStack {
                    Text("SAVE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(1.0)
                    
                    Text("\(Int(savingsPercentage))%")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.vertical, TopgolfSpacing.xs)
                .padding(.horizontal, TopgolfSpacing.sm)
                .background(Color.topgolfOrange)
                .cornerRadius(TopgolfRadius.sm)
            }
            
            // Pricing Comparison
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Regular Price")
                        .font(TopgolfFonts.caption)
                        .foregroundColor(.textTertiary)
                    
                    Text("$\(String(format: "%.0f", originalPrice))")
                        .font(TopgolfFonts.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .strikethrough()
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Promotional Price")
                        .font(TopgolfFonts.caption)
                        .foregroundColor(.textTertiary)
                    
                    Text("$\(String(format: "%.0f", discountedPrice))")
                        .font(TopgolfFonts.priceMedium)
                        .foregroundColor(.topgolfOrange)
                        .fontWeight(.bold)
                }
            }
            
            // Validity Information
            if let validUntil = validUntil {
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(.topgolfWarning)
                    
                    Text("Valid until \(validUntil, style: .date)")
                        .font(TopgolfFonts.caption)
                        .foregroundColor(.topgolfWarning)
                    
                    Spacer()
                }
            }
            
            // Terms
            if let terms = terms {
                Text(terms)
                    .font(TopgolfFonts.caption)
                    .foregroundColor(.textTertiary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(TopgolfSpacing.md)
        .background(
            LinearGradient(
                colors: [
                    Color.topgolfOrange.opacity(0.1),
                    Color.topgolfOrange.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(TopgolfRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: TopgolfRadius.card)
                .stroke(Color.topgolfOrange.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Preview
#if DEBUG
struct PricingCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: TopgolfSpacing.lg) {
                TodaysPricingCard(
                    venue: Venue.sampleVenues.first!,
                    currentTier: PricingTier(type: .afternoon, basePrice: 48),
                    allTiers: [
                        PricingTier(type: .morning, basePrice: 36),
                        PricingTier(type: .afternoon, basePrice: 48),
                        PricingTier(type: .evening, basePrice: 60),
                        PricingTier(type: .night, basePrice: 30)
                    ],
                    showMemberPricing: true,
                    onViewAllTapped: {}
                )
                
                PricingBreakdownCard(
                    bookingPricing: BookingPricing(
                        baseAmount: 120.0,
                        memberDiscount: 18.0,
                        promoDiscount: 0.0,
                        taxes: 10.20,
                        fees: 3.50,
                        totalAmount: 115.70,
                        depositRequired: 30.0,
                        depositPaid: nil
                    ),
                    timeSlot: TimeSlot.sampleTimeSlots.first!,
                    showMembershipUpsell: true
                )
                
                PromotionalPricingCard(
                    title: "Weekend Special",
                    description: "50% off Saturday & Sunday sessions",
                    originalPrice: 60.0,
                    discountedPrice: 30.0,
                    validUntil: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
                    terms: "Valid for new bookings only. Cannot be combined with other offers."
                )
            }
            .padding(TopgolfSpacing.md)
        }
        .background(Color.backgroundTertiary)
        .topgolfTheme(.topgolf)
    }
}
#endif