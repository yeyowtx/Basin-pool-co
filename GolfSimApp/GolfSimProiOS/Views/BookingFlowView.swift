import SwiftUI

// TopGolf-style booking flow with USchedule service data and real-time bay status
struct BookingFlowView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject var bayStatusManager: BayStatusManager
    let onContinue: () -> Void
    @State private var selectedPlayers = 2
    @State private var selectedDate = Date()
    @State private var showingTimePicker = false
    
    init(appState: AppStateManager, bayStatusManager: BayStatusManager? = nil, onContinue: @escaping () -> Void) {
        self.appState = appState
        self.bayStatusManager = bayStatusManager ?? BayStatusManager()
        self.onContinue = onContinue
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(.white)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Location header with live bay count
                        VStack(spacing: 8) {
                            Text("WASHINGTON")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(appState.selectedLocation.displayName.uppercased())
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.8))
                            
                            // Real-time bay availability
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 8, height: 8)
                                Text("\(bayStatusManager.getAvailableBaysCount(for: appState.selectedLocation.locationName)) bays available")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Service selection (matching TopGolf's "BOOK 1 BAY + GAME PLAY")
                        VStack(alignment: .leading, spacing: 16) {
                            Text("BOOK 1 BAY + GAME PLAY")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("1-6 PLAYERS")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        
                        // Players section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PLAYERS")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            HStack {
                                Button(action: {
                                    if selectedPlayers > 1 {
                                        selectedPlayers -= 1
                                    }
                                }) {
                                    Image(systemName: "minus")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle().fill(Color(red: 0.1, green: 0.2, blue: 0.8))
                                        )
                                }
                                
                                Spacer()
                                
                                Text("\\(selectedPlayers) PLAYERS")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button(action: {
                                    if selectedPlayers < 6 {
                                        selectedPlayers += 1
                                    }
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle().fill(Color(red: 0.1, green: 0.2, blue: 0.8))
                                        )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.gray.opacity(0.3), lineWidth: 1)
                                    .fill(.white)
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // Date section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DATE")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            HStack {
                                Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.8))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.gray.opacity(0.3), lineWidth: 1)
                                    .fill(.white)
                            )
                            .padding(.horizontal, 20)
                            .onTapGesture {
                                // Show date picker
                            }
                        }
                        
                        // Time section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TIME")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            Button(action: {
                                showingTimePicker = true
                            }) {
                                HStack {
                                    Text("Pick a Time")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.8))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.gray.opacity(0.3), lineWidth: 1)
                                        .fill(.white)
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Info section with USchedule-style details and member pricing
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    if appState.currentUser?.membership != nil {
                                        Text("Includes game play in one bay, starting at the selected time. **25% deposit due at time of booking.** Max capacity of 6 players. **Member pricing applied with 15% discount.**")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    } else {
                                        Text("Includes game play in one bay, starting at the selected time. **25% deposit due at time of booking.** Max capacity of 6 players. Note: game play cannot be extended. Members qualify for discounted rates.")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(appState.currentUser?.membership != nil ? .green.opacity(0.05) : .blue.opacity(0.05))
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 120)
                    }
                }
                
                // Bottom action button
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(.gray.opacity(0.2))
                        .frame(height: 0.5)
                    
                    Button(action: {
                        showingTimePicker = true
                    }) {
                        Text("CHECK AVAILABILITY")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color(red: 0.1, green: 0.2, blue: 0.8))
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(.white)
                }
            }
        }
        .sheet(isPresented: $showingTimePicker) {
            TimeSelectionView(appState: appState, bayStatusManager: bayStatusManager, onContinue: onContinue)
        }
    }
}

#Preview {
    BookingFlowView(appState: AppStateManager()) {
        print("Continue to time selection")
    }
}