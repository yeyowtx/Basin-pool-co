//
//  LaunchScreenView.swift
//  GolfSimApp
//
//  Evergreen Golf Club Launch Screen
//  Based on TopGolf's launch flow with Evergreen branding
//

import SwiftUI

enum EvergreenLocationLaunch: CaseIterable {
    case redmond
    case tacoma
    
    var name: String {
        switch self {
        case .redmond: return "Redmond"
        case .tacoma: return "Tacoma"
        }
    }
    
    var subtitle: String {
        switch self {
        case .redmond: return "Premier Indoor Golf"
        case .tacoma: return "Indoor Golf Club"
        }
    }
    
    var address: String {
        switch self {
        case .redmond: return "14603 NE 87th ST, Redmond, WA 98052"
        case .tacoma: return "2101 Mildred St W, Tacoma, WA 98466"
        }
    }
    
    var hours: String {
        return "8:00 AM - 7:00 PM"
    }
}

struct LaunchScreenView: View {
    @State private var isAnimating = false
    @State private var showWelcome = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    private let evergreenSecondary = Color(red: 28/255, green: 115/255, blue: 48/255)
    private let evergreenLight = Color(red: 76/255, green: 175/255, blue: 80/255)
    
    var body: some View {
        ZStack {
            // Background gradient matching TopGolf's structure but in Evergreen colors
            LinearGradient(
                colors: [evergreenSecondary, evergreenPrimary, evergreenLight.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Scattered tree logos (replacing TopGolf's shield pattern)
            ForEach(0..<15, id: \.self) { index in
                Image(systemName: "tree.fill")
                    .foregroundColor(.white.opacity(0.1))
                    .font(.system(size: CGFloat.random(in: 20...40)))
                    .position(
                        x: CGFloat.random(in: 50...350),
                        y: CGFloat.random(in: 100...800)
                    )
                    .rotationEffect(.degrees(Double.random(in: -15...15)))
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .animation(
                        .easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1),
                        value: isAnimating
                    )
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Main logo area
                VStack(spacing: 20) {
                    // Logo container (replacing TopGolf shield with evergreen theme)
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 120, height: 120)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "tree.fill")
                            .foregroundColor(evergreenPrimary)
                            .font(.system(size: 60))
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    
                    // Brand text
                    VStack(spacing: 8) {
                        Text("EVERGREEN")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(3)
                        
                        Text("GOLF CLUB")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(2)
                    }
                    .opacity(logoOpacity)
                }
                
                Spacer()
                
                // Loading indicator (TopGolf style)
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    
                    Text("Loading your experience...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(logoOpacity)
                
                Spacer()
            }
        }
        .onAppear {
            startLaunchAnimation()
        }
        .fullScreenCover(isPresented: $showWelcome) {
            WelcomeScreenView()
        }
    }
    
    private func startLaunchAnimation() {
        // Start background animation
        withAnimation(.easeInOut(duration: 1.0)) {
            isAnimating = true
        }
        
        // Animate logo entrance
        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Transition to welcome screen after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            showWelcome = true
        }
    }
}

struct WelcomeScreenView: View {
    @State private var showLocationSetup = false
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    private let evergreenSecondary = Color(red: 28/255, green: 115/255, blue: 48/255)
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.white, evergreenPrimary.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Welcome content
                VStack(spacing: 24) {
                    // Logo
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [evergreenPrimary, evergreenSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "tree.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 50))
                    }
                    
                    // Welcome text
                    VStack(spacing: 12) {
                        Text("Welcome to")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(.gray)
                        
                        Text("Evergreen Golf Club")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(evergreenPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("Premium golf simulation experience")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
                
                // Get Started button
                Button(action: {
                    showLocationSetup = true
                }) {
                    HStack {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [evergreenPrimary, evergreenSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(28)
                    .shadow(color: evergreenPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $showLocationSetup) {
            LocationSetupView()
        }
    }
}

struct LocationSetupView: View {
    @State private var showMainApp = false
    @State private var selectedLocation: EvergreenLocationLaunch? = nil
    @State private var showConfirmation = false
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    private let evergreenSecondary = Color(red: 28/255, green: 115/255, blue: 48/255)
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.white, evergreenPrimary.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button("Skip") {
                        showMainApp = true
                    }
                    .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("Choose Location")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(evergreenPrimary)
                    
                    Spacer()
                    
                    Text("Skip")
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Title
                VStack(spacing: 8) {
                    Text("Select Your")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.gray)
                    
                    Text("Evergreen Golf Club")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(evergreenPrimary)
                }
                .padding(.top, 20)
                
                // Location cards
                VStack(spacing: 16) {
                    // Redmond Location
                    LocationCard(
                        location: .redmond,
                        isSelected: selectedLocation == .redmond,
                        onTap: { selectedLocation = .redmond }
                    )
                    
                    // Tacoma Location
                    LocationCard(
                        location: .tacoma,
                        isSelected: selectedLocation == .tacoma,
                        onTap: { selectedLocation = .tacoma }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Continue button
                Button(action: {
                    showConfirmation = true
                }) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(selectedLocation != nil ? evergreenPrimary : .gray)
                        .cornerRadius(28)
                        .opacity(selectedLocation != nil ? 1.0 : 0.6)
                }
                .disabled(selectedLocation == nil)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $showMainApp) {
            EvergreenMainDashboard(selectedLocation: selectedLocation ?? .redmond)
        }
        .overlay(
            // Location confirmation modal
            Group {
                if showConfirmation {
                    LocationConfirmationModal(
                        location: selectedLocation ?? .redmond,
                        onConfirm: { showMainApp = true },
                        onBack: { showConfirmation = false }
                    )
                    .zIndex(1)
                }
            }
        )
    }
}

struct LocationCard: View {
    let location: EvergreenLocationLaunch
    let isSelected: Bool
    let onTap: () -> Void
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Location icon
                ZStack {
                    Circle()
                        .fill(isSelected ? evergreenPrimary : Color.gray.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "location.fill")
                        .foregroundColor(isSelected ? .white : .gray)
                        .font(.system(size: 20))
                }
                
                // Location details
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(location.subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text(location.address)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Distance/Hours
                VStack(alignment: .trailing, spacing: 2) {
                    Text(location.hours)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(evergreenPrimary)
                    
                    Text("Open")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: isSelected ? evergreenPrimary.opacity(0.3) : .gray.opacity(0.1), radius: 8, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? evergreenPrimary : .clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct LocationConfirmationModal: View {
    let location: EvergreenLocationLaunch
    let onConfirm: () -> Void
    let onBack: () -> Void
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    
    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Modal content
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Welcome to Evergreen!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("We'll show you \(location.name)'s info to help you plan your golf simulation session.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                VStack(spacing: 12) {
                    // Confirm button
                    Button(action: onConfirm) {
                        Text("CONFIRM")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(evergreenPrimary)
                            .cornerRadius(25)
                    }
                    
                    // Back button
                    Button(action: onBack) {
                        Text("BACK")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(evergreenPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(evergreenPrimary, lineWidth: 2)
                            )
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 40)
        }
    }
}

struct EvergreenMainDashboard: View {
    let selectedLocation: EvergreenLocationLaunch
    @State private var selectedTab = 0
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    private let evergreenSecondary = Color(red: 28/255, green: 115/255, blue: 48/255)
    private let evergreenLight = Color(red: 76/255, green: 175/255, blue: 80/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content based on selected tab
            switch selectedTab {
            case 0:
                DashboardBookingView(selectedLocation: selectedLocation)
            case 1:
                ActivityView()
            case 2:
                AccountView()
            default:
                DashboardBookingView(selectedLocation: selectedLocation)
            }
            
            // Custom 3-tab navigation
            HStack(spacing: 0) {
                TabButton(
                    title: "BOOK",
                    icon: "calendar",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 }
                )
                
                TabButton(
                    title: "ACTIVITY",
                    icon: "clock",
                    isSelected: selectedTab == 1,
                    action: { selectedTab = 1 }
                )
                
                TabButton(
                    title: "ACCOUNT",
                    icon: "person.fill",
                    isSelected: selectedTab == 2,
                    action: { selectedTab = 2 }
                )
            }
            .padding(.top, 8)
            .padding(.bottom, 34)
            .background(Color.white)
            .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: -2)
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct DashboardBookingView: View {
    let selectedLocation: EvergreenLocationLaunch
    @State private var showBooking = false
    @State private var showEventBooking = false
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    private let evergreenSecondary = Color(red: 28/255, green: 115/255, blue: 48/255)
    private let evergreenLight = Color(red: 76/255, green: 175/255, blue: 80/255)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // LEGAL DIFFERENTIATION: Moved welcome section below location header
                // Location status card (reorganized layout - different from TopGolf)
                VStack(spacing: 16) {
                    // Location header with distinctive Evergreen layout
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "tree.fill")
                                    .foregroundColor(evergreenPrimary)
                                    .font(.system(size: 16))
                                
                                Text("EVERGREEN GOLF CLUB")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(evergreenPrimary)
                                    .tracking(1)
                            }
                            
                            Text("\(selectedLocation.name.uppercased()) LOCATION")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            HStack {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 8, height: 8)
                                
                                Text("Open until 7:00 PM")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        // DIFFERENT: User profile section (not in TopGolf)
                        VStack(spacing: 4) {
                            Button(action: {}) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [evergreenSecondary, evergreenPrimary],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 44, height: 44)
                                    
                                    Text("G")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Text("GUEST")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Unique simulator status bar (different layout)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("4 SIMULATORS")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(evergreenPrimary)
                            
                            Text("Available Now")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Distinctive progress indicator
                        HStack(spacing: 8) {
                            ForEach(0..<4, id: \.self) { index in
                                Circle()
                                    .fill(evergreenLight)
                                    .frame(width: 12, height: 12)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("NO WAIT")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(evergreenPrimary)
                            
                            Text("Walk-ins OK")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(evergreenLight.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }
                
                // LEGAL DIFFERENTIATION: Horizontal booking actions (not vertical like TopGolf)
                HStack(spacing: 16) {
                    Button(action: { showBooking = true }) {
                        VStack(spacing: 8) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            
                            Text("BOOK\nSIMULATOR")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 90)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [evergreenPrimary, evergreenSecondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: evergreenPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    Button(action: { showEventBooking = true }) {
                        VStack(spacing: 8) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 24))
                                .foregroundColor(evergreenPrimary)
                            
                            Text("PLAN\nEVENT")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(evergreenPrimary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 90)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(evergreenPrimary, lineWidth: 2)
                                )
                        )
                        .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 20)
                
                // UNIQUE FEATURE: Golf Tips Section (not in TopGolf)
                VStack(spacing: 16) {
                    HStack {
                        Text("Today's Golf Tip")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button("View All") {
                            // Golf tips feature
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(evergreenPrimary)
                    }
                    
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(evergreenLight)
                            .font(.system(size: 20))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Perfect Your Stance")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Keep your feet shoulder-width apart for better balance and power.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                // LEGAL DIFFERENTIATION: Grid layout for quick actions (different from TopGolf's card layout)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    QuickActionCard(
                        icon: "chart.bar.fill",
                        title: "Session Stats",
                        subtitle: "View your progress",
                        color: evergreenLight
                    )
                    
                    QuickActionCard(
                        icon: "trophy.fill", 
                        title: "Leaderboard",
                        subtitle: "See rankings",
                        color: evergreenPrimary
                    )
                    
                    QuickActionCard(
                        icon: "giftcard.fill",
                        title: "Gift Cards",
                        subtitle: "Perfect presents",
                        color: evergreenSecondary
                    )
                    
                    QuickActionCard(
                        icon: "phone.fill",
                        title: "Contact Us",
                        subtitle: "Get assistance",
                        color: evergreenLight
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 100)
            }
        }
        .background(Color(.systemGroupedBackground))
        .fullScreenCover(isPresented: $showBooking) {
            EnhancedBookingView()
        }
        .fullScreenCover(isPresented: $showEventBooking) {
            EventBookingView()
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EventBookingView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Event Booking")
                    .font(.title)
                    .padding()
                
                Text("Plan your corporate events and parties")
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct ActivityView: View {
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    private let evergreenSecondary = Color(red: 28/255, green: 115/255, blue: 48/255)
    private let evergreenLight = Color(red: 76/255, green: 175/255, blue: 80/255)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section (LEGAL MODIFICATION: Different from TopGolf's header layout)
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("YOUR GOLF JOURNEY")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(evergreenPrimary)
                                .tracking(1)
                            
                            Text("Session History & Progress")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(evergreenPrimary)
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Progress Overview (UNIQUE: Golf-specific progress tracking)
                    HStack(spacing: 16) {
                        ProgressCard(
                            title: "Sessions",
                            value: "12",
                            subtitle: "This month",
                            color: evergreenPrimary
                        )
                        
                        ProgressCard(
                            title: "Avg Score",
                            value: "85",
                            subtitle: "Improving",
                            color: evergreenLight
                        )
                        
                        ProgressCard(
                            title: "Best Round",
                            value: "78",
                            subtitle: "Personal best",
                            color: evergreenSecondary
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                // Recent Sessions (LEGAL MODIFICATION: Different layout from TopGolf's history)
                VStack(spacing: 16) {
                    HStack {
                        Text("Recent Sessions")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button("View All") {}
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(evergreenPrimary)
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        SessionCard(
                            date: "Aug 15, 2025",
                            duration: "1h 30m",
                            score: "82",
                            improvement: "+3",
                            simulator: "Bay 2"
                        )
                        
                        SessionCard(
                            date: "Aug 12, 2025",
                            duration: "1h 15m",
                            score: "85",
                            improvement: "-2",
                            simulator: "Bay 1"
                        )
                        
                        SessionCard(
                            date: "Aug 10, 2025",
                            duration: "2h 00m",
                            score: "87",
                            improvement: "+1",
                            simulator: "Bay 3"
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                // Golf Achievements (UNIQUE: Golf-specific gamification)
                VStack(spacing: 16) {
                    HStack {
                        Text("Achievements")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        AchievementCard(
                            icon: "target",
                            title: "Eagle Eye",
                            description: "Hit 10 targets in a row",
                            completed: true
                        )
                        
                        AchievementCard(
                            icon: "flame.fill",
                            title: "Hot Streak",
                            description: "5 sessions this week",
                            completed: true
                        )
                        
                        AchievementCard(
                            icon: "crown.fill",
                            title: "Par Master",
                            description: "Average under 90",
                            completed: false
                        )
                        
                        AchievementCard(
                            icon: "star.fill",
                            title: "Perfect Form",
                            description: "Complete swing analysis",
                            completed: false
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 100)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct ProgressCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct SessionCard: View {
    let date: String
    let duration: String
    let score: String
    let improvement: String
    let simulator: String
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    
    var body: some View {
        HStack(spacing: 16) {
            // Session icon
            ZStack {
                Circle()
                    .fill(evergreenPrimary.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "figure.golf")
                    .foregroundColor(evergreenPrimary)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(date)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("Score: \(score)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(evergreenPrimary)
                }
                
                HStack {
                    Text("\(duration) • \(simulator)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(improvement)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(improvement.hasPrefix("+") ? .green : .red)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct AchievementCard: View {
    let icon: String
    let title: String
    let description: String
    let completed: Bool
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(completed ? evergreenPrimary : .gray)
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(description)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(completed ? evergreenPrimary.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
        )
        .opacity(completed ? 1.0 : 0.7)
    }
}

struct AccountView: View {
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    private let evergreenSecondary = Color(red: 28/255, green: 115/255, blue: 48/255)
    private let evergreenLight = Color(red: 76/255, green: 175/255, blue: 80/255)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header (LEGAL MODIFICATION: Different layout from TopGolf profile)
                VStack(spacing: 20) {
                    // Profile Avatar and Info
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [evergreenSecondary, evergreenPrimary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Text("G")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 4) {
                            Text("Golf Guest")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Member since Aug 2025")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        // Golf Skill Level (UNIQUE: Golf-specific profile element)
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(evergreenLight)
                            
                            Text("Intermediate Golfer")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(evergreenPrimary)
                            
                            Image(systemName: "star.fill")
                                .foregroundColor(evergreenLight)
                        }
                    }
                    .padding(.top, 20)
                }
                
                // Golf Membership Section (LEGAL MODIFICATION: Golf training vs entertainment membership)
                VStack(spacing: 16) {
                    HStack {
                        Text("Golf Training Membership")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 16) {
                        MembershipCard(
                            plan: .basic,
                            isCurrentPlan: true,
                            onUpgrade: {}
                        )
                        
                        MembershipCard(
                            plan: .pro,
                            isCurrentPlan: false,
                            onUpgrade: {}
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                // Account Settings (LEGAL MODIFICATION: Golf-specific settings vs entertainment settings)
                VStack(spacing: 16) {
                    HStack {
                        Text("Golf Preferences")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        SettingsRow(
                            icon: "figure.golf",
                            title: "Swing Analysis",
                            subtitle: "Advanced tracking enabled",
                            hasChevron: true
                        )
                        
                        SettingsRow(
                            icon: "target",
                            title: "Game Preferences",
                            subtitle: "Closest to pin, Long drive",
                            hasChevron: true
                        )
                        
                        SettingsRow(
                            icon: "bell.fill",
                            title: "Training Reminders",
                            subtitle: "Weekly practice notifications",
                            hasChevron: true
                        )
                        
                        SettingsRow(
                            icon: "person.2.fill",
                            title: "Instructor Matching",
                            subtitle: "Find PGA professionals",
                            hasChevron: true
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                // Support & Legal (LEGAL MODIFICATION: Different organization from TopGolf)
                VStack(spacing: 16) {
                    HStack {
                        Text("Support & Information")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        SettingsRow(
                            icon: "questionmark.circle.fill",
                            title: "Help & FAQ",
                            subtitle: "Golf simulation guides",
                            hasChevron: true
                        )
                        
                        SettingsRow(
                            icon: "phone.fill",
                            title: "Contact Support",
                            subtitle: "Get assistance",
                            hasChevron: true
                        )
                        
                        SettingsRow(
                            icon: "doc.text.fill",
                            title: "Terms & Privacy",
                            subtitle: "Legal information",
                            hasChevron: true
                        )
                        
                        SettingsRow(
                            icon: "arrow.right.square.fill",
                            title: "Sign Out",
                            subtitle: "Logout from account",
                            hasChevron: false
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 100)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}


struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let hasChevron: Bool
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(evergreenPrimary)
                    .font(.system(size: 18))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if hasChevron {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    private let evergreenPrimary = Color(red: 36/255, green: 138/255, blue: 61/255)
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? evergreenPrimary : .gray)
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? evergreenPrimary : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LaunchScreenView()
}