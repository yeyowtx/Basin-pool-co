//
//  SimpleHardwareView.swift
//  GolfSimApp
//
//  Simple hardware control that compiles cleanly
//

import SwiftUI

struct SimpleHardwareView: View {
    @State private var systemStatus = "Online"
    @State private var connectedDevices = 6
    @State private var activeSessions = 2
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // System Status
                    HStack(spacing: 15) {
                        Circle()
                            .fill(.green)
                            .frame(width: 12, height: 12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("System Status")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("All systems operational")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(Date().formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Connected Devices
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Connected Simulators")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                            HardwareDeviceCard(bayNumber: 1, type: "TrackMan", status: "Ready", ping: "12ms", color: .green)
                            HardwareDeviceCard(bayNumber: 2, type: "TrackMan", status: "Active", ping: "8ms", color: .blue)
                            HardwareDeviceCard(bayNumber: 3, type: "Uneekor", status: "Maintenance", ping: "—", color: .orange)
                            HardwareDeviceCard(bayNumber: 4, type: "Uneekor", status: "Ready", ping: "15ms", color: .green)
                            HardwareDeviceCard(bayNumber: 5, type: "Standard", status: "Ready", ping: "22ms", color: .green)
                            HardwareDeviceCard(bayNumber: 6, type: "Standard", status: "Active", ping: "18ms", color: .blue)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Live Activity Log
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Live Activity Log")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("Real-time")
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(4)
                        }
                        
                        VStack(spacing: 8) {
                            LogRowSimple(time: "3:42 PM", message: "Bay 2 session started - Pebble Beach", level: "info")
                            LogRowSimple(time: "3:38 PM", message: "Bay 6 TrackMan calibration completed", level: "success")
                            LogRowSimple(time: "3:35 PM", message: "Bay 3 maintenance scheduled", level: "warning")
                            LogRowSimple(time: "3:30 PM", message: "System backup completed", level: "info")
                            LogRowSimple(time: "3:28 PM", message: "Bay 1 emergency stop cleared", level: "success")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Control Actions
                    VStack(alignment: .leading, spacing: 15) {
                        Text("System Controls")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                            ControlActionButton(title: "Emergency Stop", icon: "stop.circle.fill", color: .red)
                            ControlActionButton(title: "Calibrate All", icon: "scope", color: .purple)
                            ControlActionButton(title: "Maintenance", icon: "wrench.fill", color: .orange)
                            ControlActionButton(title: "System Logs", icon: "doc.text.fill", color: .blue)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Hardware Control")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        // Refresh status
                    }
                }
            }
        }
    }
}

struct HardwareDeviceCard: View {
    let bayNumber: Int
    let type: String
    let status: String
    let ping: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(type)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(ping)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 4) {
                Text("Bay \(bayNumber)")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(status)
                    .font(.caption)
                    .foregroundColor(color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.1))
                    .cornerRadius(4)
            }
            
            if status == "Active" {
                Text("Pebble Beach")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct LogRowSimple: View {
    let time: String
    let message: String
    let level: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(levelEmoji)
                .font(.caption)
            
            Text(time)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            Text(message)
                .font(.caption)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
    
    private var levelEmoji: String {
        switch level {
        case "info": return "ℹ️"
        case "success": return "✅"
        case "warning": return "⚠️"
        case "error": return "❌"
        default: return "ℹ️"
        }
    }
}

struct ControlActionButton: View {
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
    SimpleHardwareView()
}