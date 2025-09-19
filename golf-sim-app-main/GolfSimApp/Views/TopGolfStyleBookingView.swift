import SwiftUI

struct TopGolfStyleBookingView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var selectedTimeSlot: String? = nil
    @State private var isWaitlistShown = false
    
    private let evergreenPrimary = Color(red: 0.14, green: 0.54, blue: 0.24) // #248A3D
    private let evergreenSecondary = Color(red: 0.18, green: 0.31, blue: 0.09) // #2d5016
    
    // Computed properties for dynamic location data
    private var currentLocation: Location? {
        locationManager.selectedLocation
    }
    
    private var isLocationClosed: Bool {
        currentLocation?.isCurrentlyOpen == false
    }
    
    private var nextOpenTime: String {
        currentLocation?.nextOpenTime ?? "Unknown"
    }
    
    private var timeSlots: [String] {
        currentLocation?.availableTimeSlots() ?? []
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header Section - TopGolf Style
                headerSection
                
                // Location Status Card
                locationStatusCard
                
                // Plan Your Visit Section
                planYourVisitSection
                
                // Action Buttons
                actionButtonsSection
                
                // Closed Status Message
                if currentLocation != nil && isLocationClosed {
                    closedStatusSection
                }
                
                Spacer(minLength: 100)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isWaitlistShown) {
            WaitlistSheet()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("WELCOME, GUEST")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Evergreen Golf Club")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Profile/Settings button
                Button(action: {}) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [evergreenPrimary, evergreenSecondary]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    // MARK: - Location Status Card
    private var locationStatusCard: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(currentLocation?.displayName ?? "SELECT LOCATION")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if isLocationClosed {
                            Text("CLOSED")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(currentLocation?.currentStatus ?? "No location selected")
                        .font(.subheadline)
                        .foregroundColor(isLocationClosed ? .secondary : evergreenPrimary)
                }
                
                Spacer()
                
                // Location indicator or change button
                Button(action: {}) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
    
    // MARK: - Plan Your Visit Section
    private var planYourVisitSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PLAN YOUR VISIT")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            // Time slots scroll view
            if currentLocation != nil && !timeSlots.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(timeSlots, id: \.self) { timeSlot in
                            TimeSlotPill(
                                timeSlot: timeSlot,
                                isSelected: selectedTimeSlot == timeSlot,
                                isDisabled: isLocationClosed
                            ) {
                                if !isLocationClosed {
                                    selectedTimeSlot = timeSlot
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            } else {
                Text(currentLocation == nil ? "Select a location to view available times" : "No available time slots")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
            }
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Book a Bay Button
            Button(action: {
                if currentLocation == nil {
                    // Navigate to location selection
                    return
                } else if isLocationClosed {
                    isWaitlistShown = true
                } else {
                    // Handle booking - this IS the primary booking interface
                    // No navigation to another booking page
                }
            }) {
                HStack {
                    Image(systemName: "calendar.circle.fill")
                        .font(.system(size: 20))
                    Text("BOOK A BAY")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Group {
                        if currentLocation == nil || isLocationClosed {
                            Color.gray
                        } else {
                            LinearGradient(
                                gradient: Gradient(colors: [evergreenPrimary, evergreenSecondary]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                    }
                )
                .cornerRadius(28)
            }
            .disabled(currentLocation == nil || isLocationClosed)
            
            // Plan a Party Button
            Button(action: {}) {
                HStack {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 20))
                    Text("PLAN A PARTY")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundColor(evergreenPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(evergreenPrimary, lineWidth: 2)
                )
                .cornerRadius(28)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
    
    // MARK: - Closed Status Section
    private var closedStatusSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Image(systemName: "clock.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.orange)
                
                Text("We're currently closed")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(currentLocation?.nextOpenTime != nil ? "Opens at \(nextOpenTime)" : "Opening times unavailable")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            
            // Join Waitlist Button
            Button(action: {
                isWaitlistShown = true
            }) {
                Text("JOIN THE WAITLIST")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange)
                    .cornerRadius(25)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
}

// MARK: - Time Slot Pill Component
struct TimeSlotPill: View {
    let timeSlot: String
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    private let evergreenPrimary = Color(red: 0.14, green: 0.54, blue: 0.24)
    
    var body: some View {
        Button(action: action) {
            Text(timeSlot)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(backgroundColor)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(borderColor, lineWidth: 1)
                )
        }
        .disabled(isDisabled)
    }
    
    private var textColor: Color {
        if isDisabled {
            return .gray
        } else if isSelected {
            return .white
        } else {
            return evergreenPrimary
        }
    }
    
    private var backgroundColor: Color {
        if isDisabled {
            return Color.gray.opacity(0.1)
        } else if isSelected {
            return evergreenPrimary
        } else {
            return Color(.systemBackground)
        }
    }
    
    private var borderColor: Color {
        if isDisabled {
            return .gray.opacity(0.3)
        } else {
            return evergreenPrimary
        }
    }
}

// MARK: - Waitlist Sheet
struct WaitlistSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var partySize = "2"
    
    private let evergreenPrimary = Color(red: 0.14, green: 0.54, blue: 0.24)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "list.clipboard.fill")
                        .font(.system(size: 40))
                        .foregroundColor(evergreenPrimary)
                    
                    Text("Join the Waitlist")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("We'll notify you when a bay becomes available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.headline)
                            .fontWeight(.medium)
                        TextField("Enter your name", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                            .fontWeight(.medium)
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phone")
                            .font(.headline)
                            .fontWeight(.medium)
                        TextField("Enter your phone number", text: $phone)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.phonePad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Party Size")
                            .font(.headline)
                            .fontWeight(.medium)
                        Picker("Party Size", selection: $partySize) {
                            ForEach(1...8, id: \.self) { size in
                                Text("\(size) \(size == 1 ? "person" : "people")")
                                    .tag("\(size)")
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: {
                        // Handle waitlist submission
                        dismiss()
                    }) {
                        Text("JOIN WAITLIST")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(evergreenPrimary)
                            .cornerRadius(25)
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        TopGolfStyleBookingView()
            .navigationTitle("Book")
    }
}