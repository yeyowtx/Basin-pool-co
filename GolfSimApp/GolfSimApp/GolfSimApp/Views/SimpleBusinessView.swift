//
//  SimpleBusinessView.swift
//  GolfSimApp
//
//  Simple business dashboard that compiles cleanly
//

import SwiftUI

struct SimpleBusinessView: View {
    @State private var dailyRevenue = "$2,847"
    @State private var totalBookings = "47"
    @State private var utilization = "78%"
    @State private var baysAvailable = "4/6"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Revenue Stats
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Today's Performance")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                            SimpleStatCard(title: "Revenue", value: dailyRevenue, change: "+12.5%", color: .green)
                            SimpleStatCard(title: "Bookings", value: totalBookings, change: "+8.2%", color: .blue)
                            SimpleStatCard(title: "Utilization", value: utilization, change: "+5.1%", color: .orange)
                            SimpleStatCard(title: "Bays Available", value: baysAvailable, change: "Live", color: .purple)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Live Bay Status
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Bay Status - Real Time")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                            BayStatusCardSimple(bayNumber: 1, status: "Available", type: "TrackMan", color: .green)
                            BayStatusCardSimple(bayNumber: 2, status: "In Use", type: "TrackMan", color: .red)
                            BayStatusCardSimple(bayNumber: 3, status: "Maintenance", type: "Uneekor", color: .orange)
                            BayStatusCardSimple(bayNumber: 4, status: "Available", type: "Uneekor", color: .green)
                            BayStatusCardSimple(bayNumber: 5, status: "Available", type: "Standard", color: .green)
                            BayStatusCardSimple(bayNumber: 6, status: "Reserved", type: "Standard", color: .blue)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Revenue Chart
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Revenue Trend - Live")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack {
                            Text("📈 Revenue Trending Up")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Text("$2,847 today (+12.5%)")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            HStack {
                                ForEach(0..<24, id: \.self) { hour in
                                    Rectangle()
                                        .fill(.blue.opacity(Double.random(in: 0.3...1.0)))
                                        .frame(width: 8, height: CGFloat.random(in: 20...80))
                                }
                            }
                            .frame(height: 100)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Active Sessions
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Active Sessions")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 10) {
                            ActiveSessionRow(bay: "TrackMan Bay 2", players: "4 players", time: "Started 2:15 PM", revenue: "$55")
                            ActiveSessionRow(bay: "Standard Bay 6", players: "2 players", time: "Started 3:00 PM", revenue: "$45")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Quick Actions")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                            QuickActionButtonSimple(title: "New Booking", icon: "plus.circle.fill", color: .blue)
                            QuickActionButtonSimple(title: "Walk-in", icon: "person.badge.plus", color: .green)
                            QuickActionButtonSimple(title: "Reports", icon: "chart.bar.fill", color: .purple)
                            QuickActionButtonSimple(title: "Settings", icon: "gear.fill", color: .orange)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Business Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        // Refresh data
                    }
                }
            }
        }
    }
}

struct SimpleStatCard: View {
    let title: String
    let value: String
    let change: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(change)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(change.hasPrefix("+") ? .green : .blue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .gray.opacity(0.1), radius: 2)
    }
}

struct BayStatusCardSimple: View {
    let bayNumber: Int
    let status: String
    let type: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(type)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
            }
            
            VStack(spacing: 4) {
                Text("Bay \(bayNumber)")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(status)
                    .font(.caption2)
                    .foregroundColor(color)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ActiveSessionRow: View {
    let bay: String
    let players: String
    let time: String
    let revenue: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(bay)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(players)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(revenue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct QuickActionButtonSimple: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
        }
    }
}

#Preview {
    SimpleBusinessView()
}