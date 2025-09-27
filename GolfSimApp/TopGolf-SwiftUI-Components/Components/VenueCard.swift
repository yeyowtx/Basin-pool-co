//
//  VenueCard.swift
//  TopGolf-Inspired Golf Sim App
//
//  Venue selection and display components with exact TopGolf styling
//  Handles location cards, facility information, and booking navigation
//

import SwiftUI
import MapKit

// MARK: - Venue Card View
struct VenueCard: View {
    let venue: Venue
    let onTap: () -> Void
    let onBookTap: (() -> Void)?
    let showDistance: Bool
    let userLocation: CLLocation?
    
    @Environment(\.topgolfTheme) private var theme
    @State private var showingFullDescription = false
    
    init(venue: Venue,
         onTap: @escaping () -> Void,
         onBookTap: (() -> Void)? = nil,
         showDistance: Bool = true,
         userLocation: CLLocation? = nil) {
        self.venue = venue
        self.onTap = onTap
        self.onBookTap = onBookTap
        self.showDistance = showDistance
        self.userLocation = userLocation
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: TopgolfSpacing.md) {
                // Header with Image and Status
                VenueCardHeader(
                    venue: venue,
                    userLocation: userLocation,
                    showDistance: showDistance
                )
                
                // Venue Information
                VenueCardContent(
                    venue: venue,
                    showingFullDescription: $showingFullDescription
                )
                
                // Action Buttons
                if let onBookTap = onBookTap {
                    VenueCardActions(
                        venue: venue,
                        onBookTap: onBookTap
                    )
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

// MARK: - Venue Card Header
struct VenueCardHeader: View {
    let venue: Venue
    let userLocation: CLLocation?
    let showDistance: Bool
    
    var body: some View {
        ZStack {
            // Background Image
            if let imageURL = venue.primaryImageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.backgroundSecondary)
                        .overlay(
                            Image(systemName: "building.2")
                                .font(.largeTitle)
                                .foregroundColor(.textTertiary)
                        )
                }
                .frame(height: TopgolfSizes.venueCardImageHeight)
                .clipped()
            } else {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                theme.configuration.colors.primary.opacity(0.3),
                                theme.configuration.colors.primary.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: TopgolfSizes.venueCardImageHeight)
                    .overlay(
                        Image(systemName: "building.2")
                            .font(.largeTitle)
                            .foregroundColor(.textSecondary)
                    )
            }
            
            // Overlay Information
            VStack {
                HStack {
                    // Status Badge
                    VenueStatusBadge(status: venue.operatingStatus)
                    
                    Spacer()
                    
                    // Distance Badge
                    if showDistance, let distance = venue.distanceFromUser(userLocation) {
                        DistanceBadge(distance: distance)
                    }
                }
                .padding(TopgolfSpacing.sm)
                
                Spacer()
                
                // Venue Name Overlay
                HStack {
                    VStack(alignment: .leading, spacing: TopgolfSpacing.xxs) {
                        ThemedText(text: venue.name, style: .headingLarge)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.7), radius: 2, x: 1, y: 1)
                        
                        Text(venue.shortAddress)
                            .font(TopgolfFonts.bodyMedium)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.7), radius: 2, x: 1, y: 1)
                    }
                    
                    Spacer()
                }
                .padding(TopgolfSpacing.sm)
            }
        }
        .cornerRadius(TopgolfRadius.card, corners: [.topLeft, .topRight])
    }
}

// MARK: - Venue Status Badge
struct VenueStatusBadge: View {
    let status: OperatingStatus
    
    var body: some View {
        HStack(spacing: TopgolfSpacing.xxs) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(status.displayName.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .tracking(1.0)
        }
        .padding(.horizontal, TopgolfSpacing.xs)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.7))
        .cornerRadius(TopgolfRadius.button)
    }
    
    private var statusColor: Color {
        switch status {
        case .open: return .topgolfSuccess
        case .closed: return .topgolfError
        case .limited: return .topgolfWarning
        }
    }
}

// MARK: - Distance Badge
struct DistanceBadge: View {
    let distance: Double
    
    var body: some View {
        HStack(spacing: TopgolfSpacing.xxs) {
            Image(systemName: "location")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white)
            
            Text(formattedDistance)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, TopgolfSpacing.xs)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.7))
        .cornerRadius(TopgolfRadius.button)
    }
    
    private var formattedDistance: String {
        if distance < 1.0 {
            return String(format: "%.1f mi", distance)
        } else {
            return String(format: "%.0f mi", distance)
        }
    }
}

// MARK: - Venue Card Content
struct VenueCardContent: View {
    let venue: Venue
    @Binding var showingFullDescription: Bool
    
    var body: some View {
        VStack(spacing: TopgolfSpacing.sm) {
            // Current Pricing Information
            VenuePricingRow(venue: venue)
            
            // Facility Features
            VenueFeaturesGrid(features: venue.features.prefix(6).map { $0 })
            
            // Description
            VenueDescriptionView(
                description: venue.description,
                showingFull: $showingFullDescription
            )
            
            // Hours and Contact
            VenueInfoRow(venue: venue)
        }
    }
}

// MARK: - Venue Pricing Row
struct VenuePricingRow: View {
    let venue: Venue
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today's Pricing")
                    .font(TopgolfFonts.caption)
                    .foregroundColor(.textTertiary)
                
                if let currentTier = venue.currentPricingTier {
                    Text("$\(Int(currentTier.basePrice))/hr simulator")
                        .font(TopgolfFonts.priceMedium)
                        .foregroundColor(.textPrimary)
                } else {
                    Text("See pricing")
                        .font(TopgolfFonts.bodyMedium)
                        .foregroundColor(.topgolfBlue)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("Available Simulators")
                    .font(TopgolfFonts.caption)
                    .foregroundColor(.textTertiary)
                
                Text("\(venue.availableSimulators)/\(venue.totalSimulators)")
                    .font(TopgolfFonts.bodyMedium)
                    .foregroundColor(venue.availableSimulators > 0 ? .topgolfSuccess : .topgolfError)
            }
        }
        .padding(.vertical, TopgolfSpacing.xs)
        .padding(.horizontal, TopgolfSpacing.sm)
        .background(Color.backgroundSecondary)
        .cornerRadius(TopgolfRadius.sm)
    }
}

// MARK: - Venue Features Grid
struct VenueFeaturesGrid: View {
    let features: [String]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: TopgolfSpacing.xs), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: TopgolfSpacing.xs) {
            ForEach(features, id: \.self) { feature in
                VenueFeatureChip(feature: feature)
            }
        }
    }
}

struct VenueFeatureChip: View {
    let feature: String
    
    var body: some View {
        HStack(spacing: TopgolfSpacing.xxs) {
            Image(systemName: iconForFeature(feature))
                .font(.system(size: 10))
                .foregroundColor(.topgolfBlue)
            
            Text(feature)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.textSecondary)
                .lineLimit(1)
        }
        .padding(.horizontal, TopgolfSpacing.xs)
        .padding(.vertical, 4)
        .background(Color.topgolfBlue.opacity(0.1))
        .cornerRadius(TopgolfRadius.xs)
    }
    
    private func iconForFeature(_ feature: String) -> String {
        let lowerFeature = feature.lowercased()
        
        if lowerFeature.contains("instruction") || lowerFeature.contains("lesson") {
            return "person.2.badge.gearshape"
        } else if lowerFeature.contains("restaurant") || lowerFeature.contains("food") {
            return "fork.knife"
        } else if lowerFeature.contains("bar") || lowerFeature.contains("drink") {
            return "wineglass"
        } else if lowerFeature.contains("parking") {
            return "car"
        } else if lowerFeature.contains("event") || lowerFeature.contains("party") {
            return "party.popper"
        } else if lowerFeature.contains("pro shop") || lowerFeature.contains("retail") {
            return "bag"
        } else if lowerFeature.contains("simulator") || lowerFeature.contains("bay") {
            return "tv"
        } else {
            return "checkmark.circle"
        }
    }
}

// MARK: - Venue Description View
struct VenueDescriptionView: View {
    let description: String
    @Binding var showingFull: Bool
    
    private let characterLimit = 120
    
    var body: some View {
        VStack(alignment: .leading, spacing: TopgolfSpacing.xs) {
            Text(displayText)
                .font(TopgolfFonts.bodySmall)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.leading)
            
            if description.count > characterLimit {
                Button(showingFull ? "Show Less" : "Read More") {
                    withAnimation(TopgolfAnimations.springFast) {
                        showingFull.toggle()
                    }
                }
                .font(TopgolfFonts.caption)
                .foregroundColor(.topgolfBlue)
            }
        }
    }
    
    private var displayText: String {
        if showingFull || description.count <= characterLimit {
            return description
        } else {
            return String(description.prefix(characterLimit)) + "..."
        }
    }
}

// MARK: - Venue Info Row
struct VenueInfoRow: View {
    let venue: Venue
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hours Today")
                    .font(TopgolfFonts.caption)
                    .foregroundColor(.textTertiary)
                
                Text(venue.todaysHours)
                    .font(TopgolfFonts.bodySmall)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("Contact")
                    .font(TopgolfFonts.caption)
                    .foregroundColor(.textTertiary)
                
                Text(venue.formattedPhone)
                    .font(TopgolfFonts.bodySmall)
                    .foregroundColor(.topgolfBlue)
            }
        }
    }
}

// MARK: - Venue Card Actions
struct VenueCardActions: View {
    let venue: Venue
    let onBookTap: () -> Void
    
    var body: some View {
        HStack(spacing: TopgolfSpacing.sm) {
            // Call Button
            Button(action: {
                if let phoneURL = URL(string: "tel:\(venue.phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "-", with: ""))") {
                    UIApplication.shared.open(phoneURL)
                }
            }) {
                HStack(spacing: TopgolfSpacing.xs) {
                    Image(systemName: "phone")
                        .font(.system(size: 14, weight: .medium))
                    
                    Text("Call")
                        .font(TopgolfFonts.labelMedium)
                }
                .foregroundColor(.topgolfBlue)
                .padding(.horizontal, TopgolfSpacing.md)
                .padding(.vertical, TopgolfSpacing.sm)
                .background(Color.topgolfBlue.opacity(0.1))
                .cornerRadius(TopgolfRadius.button)
                .overlay(
                    RoundedRectangle(cornerRadius: TopgolfRadius.button)
                        .stroke(Color.topgolfBlue, lineWidth: 1)
                )
            }
            
            // Directions Button
            Button(action: {
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: venue.coordinate))
                mapItem.name = venue.name
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            }) {
                HStack(spacing: TopgolfSpacing.xs) {
                    Image(systemName: "location")
                        .font(.system(size: 14, weight: .medium))
                    
                    Text("Directions")
                        .font(TopgolfFonts.labelMedium)
                }
                .foregroundColor(.topgolfBlue)
                .padding(.horizontal, TopgolfSpacing.md)
                .padding(.vertical, TopgolfSpacing.sm)
                .background(Color.topgolfBlue.opacity(0.1))
                .cornerRadius(TopgolfRadius.button)
                .overlay(
                    RoundedRectangle(cornerRadius: TopgolfRadius.button)
                        .stroke(Color.topgolfBlue, lineWidth: 1)
                )
            }
            
            // Book Now Button
            Button(action: onBookTap) {
                HStack(spacing: TopgolfSpacing.xs) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 14, weight: .medium))
                    
                    Text("Book Now")
                        .font(TopgolfFonts.labelMedium)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, TopgolfSpacing.md)
                .padding(.vertical, TopgolfSpacing.sm)
                .background(
                    venue.availableSimulators > 0 ? theme.configuration.colors.primary : Color.textTertiary
                )
                .cornerRadius(TopgolfRadius.button)
            }
            .disabled(venue.availableSimulators == 0)
        }
    }
}

// MARK: - Compact Venue Card
struct CompactVenueCard: View {
    let venue: Venue
    let onTap: () -> Void
    let userLocation: CLLocation?
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: TopgolfSpacing.md) {
                // Venue Image
                if let imageURL = venue.primaryImageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.backgroundSecondary)
                            .overlay(
                                Image(systemName: "building.2")
                                    .foregroundColor(.textTertiary)
                            )
                    }
                    .frame(width: 80, height: 80)
                    .cornerRadius(TopgolfRadius.sm)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(Color.backgroundSecondary)
                        .frame(width: 80, height: 80)
                        .cornerRadius(TopgolfRadius.sm)
                        .overlay(
                            Image(systemName: "building.2")
                                .foregroundColor(.textTertiary)
                        )
                }
                
                // Venue Information
                VStack(alignment: .leading, spacing: TopgolfSpacing.xs) {
                    HStack {
                        Text(venue.name)
                            .font(TopgolfFonts.headingMedium)
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        VenueStatusBadge(status: venue.operatingStatus)
                    }
                    
                    Text(venue.shortAddress)
                        .font(TopgolfFonts.bodySmall)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                    
                    HStack {
                        if let distance = venue.distanceFromUser(userLocation) {
                            Text(String(format: "%.1f mi", distance))
                                .font(TopgolfFonts.caption)
                                .foregroundColor(.textTertiary)
                        }
                        
                        Spacer()
                        
                        Text("\(venue.availableSimulators) available")
                            .font(TopgolfFonts.caption)
                            .foregroundColor(venue.availableSimulators > 0 ? .topgolfSuccess : .topgolfError)
                    }
                }
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textTertiary)
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

// MARK: - Venue List Card
struct VenueListCard: View {
    let venue: Venue
    let onTap: () -> Void
    let userLocation: CLLocation?
    let showBookButton: Bool
    let onBookTap: (() -> Void)?
    
    init(venue: Venue,
         onTap: @escaping () -> Void,
         userLocation: CLLocation? = nil,
         showBookButton: Bool = false,
         onBookTap: (() -> Void)? = nil) {
        self.venue = venue
        self.onTap = onTap
        self.userLocation = userLocation
        self.showBookButton = showBookButton
        self.onBookTap = onBookTap
    }
    
    var body: some View {
        VStack(spacing: TopgolfSpacing.sm) {
            Button(action: onTap) {
                HStack(spacing: TopgolfSpacing.md) {
                    // Venue Image
                    if let imageURL = venue.primaryImageURL {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.backgroundSecondary)
                                .overlay(
                                    Image(systemName: "building.2")
                                        .foregroundColor(.textTertiary)
                                )
                        }
                        .frame(width: 60, height: 60)
                        .cornerRadius(TopgolfRadius.sm)
                        .clipped()
                    }
                    
                    // Venue Information
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(venue.name)
                                .font(TopgolfFonts.bodyMedium)
                                .foregroundColor(.textPrimary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if let distance = venue.distanceFromUser(userLocation) {
                                Text(String(format: "%.1f mi", distance))
                                    .font(TopgolfFonts.caption)
                                    .foregroundColor(.textTertiary)
                            }
                        }
                        
                        Text(venue.shortAddress)
                            .font(TopgolfFonts.bodySmall)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                        
                        HStack {
                            Text("\(venue.availableSimulators) available")
                                .font(TopgolfFonts.caption)
                                .foregroundColor(venue.availableSimulators > 0 ? .topgolfSuccess : .topgolfError)
                            
                            Spacer()
                            
                            if let currentTier = venue.currentPricingTier {
                                Text("$\(Int(currentTier.basePrice))/hr")
                                    .font(TopgolfFonts.caption)
                                    .foregroundColor(.textTertiary)
                            }
                        }
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textTertiary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if showBookButton, let onBookTap = onBookTap {
                Button(action: onBookTap) {
                    Text("Book Simulator")
                        .font(TopgolfFonts.labelMedium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, TopgolfSpacing.sm)
                        .background(venue.availableSimulators > 0 ? Color.topgolfBlue : Color.textTertiary)
                        .cornerRadius(TopgolfRadius.button)
                }
                .disabled(venue.availableSimulators == 0)
            }
        }
        .padding(.horizontal, TopgolfSpacing.md)
        .padding(.vertical, TopgolfSpacing.sm)
    }
}

// MARK: - Extensions for Rounded Corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
#if DEBUG
struct VenueCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: TopgolfSpacing.lg) {
                VenueCard(
                    venue: Venue.sampleVenues.first!,
                    onTap: {},
                    onBookTap: {},
                    showDistance: true,
                    userLocation: CLLocation(latitude: 47.6062, longitude: -122.3321)
                )
                
                CompactVenueCard(
                    venue: Venue.sampleVenues.first!,
                    onTap: {},
                    userLocation: CLLocation(latitude: 47.6062, longitude: -122.3321)
                )
                
                VenueListCard(
                    venue: Venue.sampleVenues.first!,
                    onTap: {},
                    userLocation: CLLocation(latitude: 47.6062, longitude: -122.3321),
                    showBookButton: true,
                    onBookTap: {}
                )
            }
            .padding(TopgolfSpacing.md)
        }
        .background(Color.backgroundTertiary)
        .topgolfTheme(.topgolf)
    }
}
#endif