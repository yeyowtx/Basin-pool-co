//
//  TimeSlotGrid.swift
//  TopGolf-Inspired Golf Sim App
//
//  Time slot selection grid component with exact TopGolf styling
//  Handles availability visualization, pricing display, and member benefits
//

import SwiftUI

// MARK: - Time Slot Grid View
struct TimeSlotGridView: View {
    @Binding var selectedTimeSlot: TimeSlot?
    let timeSlots: [TimeSlot]
    let isLoading: Bool
    let onTimeSlotSelected: (TimeSlot) -> Void
    
    @Environment(\.topgolfTheme) private var theme
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: TopgolfSpacing.timeSlotSpacing), count: 4)
    
    var body: some View {
        VStack(spacing: TopgolfSpacing.sectionSpacing) {
            // Date Selector Header
            DateSelectorHeader(
                selectedDate: $selectedDate,
                showingDatePicker: $showingDatePicker
            )
            
            // Availability Legend
            AvailabilityLegendView()
            
            // Loading State
            if isLoading {
                TimeSlotLoadingView()
            } else {
                // Time Slots Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: TopgolfSpacing.timeSlotSpacing) {
                        ForEach(filteredTimeSlots) { timeSlot in
                            TimeSlotCard(
                                timeSlot: timeSlot,
                                isSelected: selectedTimeSlot?.id == timeSlot.id,
                                onTap: {
                                    if timeSlot.isBookable {
                                        selectedTimeSlot = timeSlot
                                        onTimeSlotSelected(timeSlot)
                                        TopgolfHaptics.selection()
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, TopgolfSpacing.md)
                }
            }
            
            // Member Benefits Message
            if hasSelectedSlot {
                MemberBenefitsCard()
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate)
        }
    }
    
    private var filteredTimeSlots: [TimeSlot] {
        let calendar = Calendar.current
        return timeSlots.filter { timeSlot in
            calendar.isDate(timeSlot.date, inSameDayAs: selectedDate)
        }
    }
    
    private var hasSelectedSlot: Bool {
        selectedTimeSlot != nil
    }
}

// MARK: - Date Selector Header
struct DateSelectorHeader: View {
    @Binding var selectedDate: Date
    @Binding var showingDatePicker: Bool
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: TopgolfSpacing.xxs) {
                ThemedText(text: "SELECT DATE", style: .caption)
                    .foregroundColor(.textTertiary)
                
                Button(action: { showingDatePicker = true }) {
                    HStack(spacing: TopgolfSpacing.xs) {
                        ThemedText(text: dateFormatter.string(from: selectedDate), style: .headingMedium)
                            .foregroundColor(.textPrimary)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Quick Date Navigation
            HStack(spacing: TopgolfSpacing.xs) {
                DateQuickButton(
                    title: "Today",
                    isSelected: Calendar.current.isDateInToday(selectedDate)
                ) {
                    selectedDate = Date()
                }
                
                DateQuickButton(
                    title: "Tomorrow",
                    isSelected: Calendar.current.isDateInTomorrow(selectedDate)
                ) {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                }
            }
        }
        .padding(.horizontal, TopgolfSpacing.md)
    }
}

struct DateQuickButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(TopgolfFonts.labelSmall)
                .foregroundColor(isSelected ? .topgolfBlue : .textSecondary)
                .padding(.horizontal, TopgolfSpacing.sm)
                .padding(.vertical, TopgolfSpacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: TopgolfRadius.button)
                        .fill(isSelected ? Color.topgolfBlue.opacity(0.1) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: TopgolfRadius.button)
                                .stroke(isSelected ? Color.topgolfBlue : Color.borderPrimary, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(ScaleButtonStyle(animation: TopgolfAnimations.buttonPress))
    }
}

// MARK: - Availability Legend
struct AvailabilityLegendView: View {
    var body: some View {
        HStack {
            ThemedText(text: "AVAILABILITY", style: .caption)
                .foregroundColor(.textTertiary)
            
            Spacer()
            
            HStack(spacing: TopgolfSpacing.lg) {
                LegendItem(color: .topgolfSuccess, text: "Available")
                LegendItem(color: .topgolfWarning, text: "Limited")
                LegendItem(color: .topgolfError, text: "Full")
            }
        }
        .padding(.horizontal, TopgolfSpacing.md)
    }
}

struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: TopgolfSpacing.xxs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(text)
                .font(TopgolfFonts.caption)
                .foregroundColor(.textTertiary)
        }
    }
}

// MARK: - Time Slot Card
struct TimeSlotCard: View {
    let timeSlot: TimeSlot
    let isSelected: Bool
    let onTap: () -> Void
    
    @Environment(\.topgolfTheme) private var theme
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: TopgolfSpacing.xs) {
                // Time Display
                Text(timeSlot.startTimeText)
                    .font(TopgolfFonts.timeDisplay)
                    .foregroundColor(timeSlot.isBookable ? .textPrimary : .textTertiary)
                    .tracking(0.5)
                
                // Availability Status
                if timeSlot.isBookable {
                    VStack(spacing: 2) {
                        // Price Display
                        Text("$\(Int(timeSlot.price))")
                            .font(TopgolfFonts.priceMedium)
                            .foregroundColor(.textPrimary)
                        
                        // Member Price
                        if let memberPrice = timeSlot.memberPrice {
                            Text("$\(Int(memberPrice)) member")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.topgolfSuccess)
                        }
                        
                        // Promotional Pricing
                        if timeSlot.hasPromotion {
                            Text(timeSlot.promotionDescription ?? "Special Rate")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.topgolfOrange)
                                .textCase(.uppercase)
                        }
                    }
                } else {
                    VStack(spacing: 2) {
                        Text("FULL")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.textTertiary)
                            .tracking(1.0)
                        
                        if timeSlot.isPast {
                            Text("Past")
                                .font(.system(size: 10))
                                .foregroundColor(.textTertiary)
                        }
                    }
                }
                
                // Simulator Count
                if timeSlot.isBookable && timeSlot.simulatorCount > 0 {
                    Text(timeSlot.simulatorCountText)
                        .font(.system(size: 10))
                        .foregroundColor(.textSecondary)
                }
                
                // Pricing Tier Indicator
                if timeSlot.isBookable {
                    Circle()
                        .fill(Color.pricingTierColor(for: timeSlot.tier.type.rawValue))
                        .frame(width: 6, height: 6)
                }
            }
            .frame(height: TopgolfSizes.timeSlotCardHeight)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(TopgolfRadius.timeSlotCard)
            .overlay(
                RoundedRectangle(cornerRadius: TopgolfRadius.timeSlotCard)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(TopgolfAnimations.springFast, value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!timeSlot.isBookable)
    }
    
    private var backgroundColor: Color {
        if !timeSlot.isBookable {
            return Color.backgroundSecondary
        } else if isSelected {
            return theme.configuration.colors.primary.opacity(0.1)
        } else if timeSlot.hasPromotion {
            return Color.topgolfOrange.opacity(0.05)
        } else {
            return Color.backgroundPrimary
        }
    }
    
    private var borderColor: Color {
        if !timeSlot.isBookable {
            return Color.borderSecondary
        } else if isSelected {
            return theme.configuration.colors.primary
        } else if timeSlot.hasPromotion {
            return Color.topgolfOrange.opacity(0.5)
        } else {
            return Color.borderPrimary
        }
    }
    
    private var borderWidth: CGFloat {
        isSelected ? 2 : 1
    }
}

// MARK: - Loading State
struct TimeSlotLoadingView: View {
    @State private var isAnimating = false
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: TopgolfSpacing.timeSlotSpacing), count: 4)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: TopgolfSpacing.timeSlotSpacing) {
            ForEach(0..<12, id: \.self) { _ in
                RoundedRectangle(cornerRadius: TopgolfRadius.timeSlotCard)
                    .fill(Color.backgroundSecondary)
                    .frame(height: TopgolfSizes.timeSlotCardHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: TopgolfRadius.timeSlotCard)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        Color.white.opacity(0.4),
                                        Color.clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .offset(x: isAnimating ? 100 : -100)
                    )
                    .clipped()
            }
        }
        .padding(.horizontal, TopgolfSpacing.md)
        .onAppear {
            withAnimation(
                .linear(duration: 1.5)
                .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Member Benefits Card
struct MemberBenefitsCard: View {
    var body: some View {
        VStack(spacing: TopgolfSpacing.sm) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.topgolfOrange)
                    .font(.system(size: 16))
                
                ThemedText(text: "MEMBER BENEFITS", style: .labelMedium)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: TopgolfSpacing.xs) {
                BenefitRow(icon: "percent", text: "15% off all simulator sessions")
                BenefitRow(icon: "clock", text: "Priority booking access")
                BenefitRow(icon: "person.2", text: "Bring guests at member rates")
            }
            
            HStack {
                Spacer()
                
                Button("Become a Member") {
                    // Handle membership signup
                }
                .buttonStyle(.plain)
                .font(TopgolfFonts.labelMedium)
                .foregroundColor(.topgolfBlue)
                .tracking(0.5)
            }
        }
        .padding(TopgolfSpacing.md)
        .background(Color.backgroundSecondary)
        .cornerRadius(TopgolfRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: TopgolfRadius.card)
                .stroke(Color.topgolfOrange.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, TopgolfSpacing.md)
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: TopgolfSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.topgolfOrange)
                .frame(width: 16)
            
            Text(text)
                .font(TopgolfFonts.bodySmall)
                .foregroundColor(.textSecondary)
            
            Spacer()
        }
    }
}

// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    private var dateRange: ClosedRange<Date> {
        let today = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: 30, to: today) ?? today
        return today...futureDate
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: TopgolfSpacing.lg) {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: dateRange,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding(TopgolfSpacing.md)
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Done") {
                    dismiss()
                }
                .foregroundColor(.topgolfBlue)
                .font(TopgolfFonts.labelMedium)
            )
        }
    }
}

// MARK: - Preview
#if DEBUG
struct TimeSlotGridView_Previews: PreviewProvider {
    static var previews: some View {
        TimeSlotGridView(
            selectedTimeSlot: .constant(nil),
            timeSlots: TimeSlot.sampleTimeSlots,
            isLoading: false,
            onTimeSlotSelected: { _ in }
        )
        .topgolfTheme(.topgolf)
        .previewDisplayName("TopGolf Theme")
        
        TimeSlotGridView(
            selectedTimeSlot: .constant(TimeSlot.sampleTimeSlots.first),
            timeSlots: TimeSlot.sampleTimeSlots,
            isLoading: false,
            onTimeSlotSelected: { _ in }
        )
        .topgolfTheme(.golfSim)
        .previewDisplayName("Golf Sim Theme")
        
        TimeSlotGridView(
            selectedTimeSlot: .constant(nil),
            timeSlots: [],
            isLoading: true,
            onTimeSlotSelected: { _ in }
        )
        .topgolfTheme(.topgolf)
        .previewDisplayName("Loading State")
    }
}
#endif