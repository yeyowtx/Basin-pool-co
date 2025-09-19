//
//  MembershipManager.swift
//  GolfSimApp
//
//  Membership system for Evergreen Golf Club
//

import Foundation
import SwiftUI

class MembershipManager: ObservableObject {
    @Published var currentMembership: MembershipPlan = .guest
    @Published var membershipExpiry: Date?
    @Published var memberSince: Date?
    @Published var totalSessions: Int = 0
    @Published var monthlyHours: Int = 0
    @Published var loyaltyPoints: Int = 0
    
    // Member benefits
    var discountRate: Double {
        switch currentMembership {
        case .guest:
            return 0.0
        case .basic:
            return 0.15  // 15% discount
        case .pro:
            return 0.25  // 25% discount
        case .vip:
            return 0.35  // 35% discount
        }
    }
    
    var priorityBooking: Bool {
        currentMembership != .guest
    }
    
    var monthlyHourLimit: Int? {
        switch currentMembership {
        case .guest:
            return nil
        case .basic:
            return 4
        case .pro:
            return nil  // Unlimited
        case .vip:
            return nil  // Unlimited
        }
    }
    
    var includesInstruction: Bool {
        currentMembership == .pro || currentMembership == .vip
    }
    
    var vipPerks: Bool {
        currentMembership == .vip
    }
    
    func upgradeMembership(to plan: MembershipPlan) {
        currentMembership = plan
        memberSince = Date()
        
        // Set expiry to one year from now
        let calendar = Calendar.current
        membershipExpiry = calendar.date(byAdding: .year, value: 1, to: Date())
    }
    
    func calculateMemberPrice(basePrice: Double) -> Double {
        return basePrice * (1.0 - discountRate)
    }
    
    func addSession() {
        totalSessions += 1
        loyaltyPoints += currentMembership == .guest ? 10 : 25
    }
    
    func addPlayTime(minutes: Int) {
        monthlyHours += minutes
    }
}

enum MembershipPlan: String, CaseIterable {
    case guest = "Guest"
    case basic = "Basic Training"
    case pro = "Pro Training"
    case vip = "VIP Training"
    
    var displayName: String {
        return rawValue
    }
    
    var monthlyPrice: Double {
        switch self {
        case .guest:
            return 0
        case .basic:
            return 89
        case .pro:
            return 199
        case .vip:
            return 399
        }
    }
    
    var features: [String] {
        switch self {
        case .guest:
            return ["Pay per session", "Standard equipment", "Basic analytics"]
        case .basic:
            return ["4 hours per month", "15% discount on sessions", "Basic analytics", "Equipment included"]
        case .pro:
            return ["Unlimited hours", "25% discount on sessions", "Advanced analytics", "Pro instruction", "Priority booking"]
        case .vip:
            return ["Unlimited hours", "35% discount on sessions", "Advanced analytics", "Personal pro instructor", "Priority booking", "VIP lounge access", "Complimentary refreshments"]
        }
    }
    
    var color: Color {
        switch self {
        case .guest:
            return Color.gray
        case .basic:
            return Color(red: 36/255, green: 138/255, blue: 61/255)
        case .pro:
            return Color(red: 28/255, green: 115/255, blue: 48/255)
        case .vip:
            return Color(red: 255/255, green: 215/255, blue: 0/255) // Gold
        }
    }
}

struct MembershipCard: View {
    let plan: MembershipPlan
    let isCurrentPlan: Bool
    let onUpgrade: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.displayName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if isCurrentPlan {
                        Text("CURRENT PLAN")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(plan.color)
                            .cornerRadius(8)
                    } else {
                        Text("Upgrade Available")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if plan.monthlyPrice > 0 {
                        Text("$\(Int(plan.monthlyPrice))")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(plan.color)
                        
                        Text("/month")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    } else {
                        Text("Pay Per Use")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(plan.color)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(plan.features, id: \.self) { feature in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(plan.color)
                            .font(.system(size: 14))
                        
                        Text(feature)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                }
            }
            
            if !isCurrentPlan && plan != .guest {
                Button(action: onUpgrade) {
                    Text("Upgrade to \(plan.displayName)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(plan.color)
                        .cornerRadius(22)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCurrentPlan ? plan.color : Color.gray.opacity(0.2), lineWidth: isCurrentPlan ? 2 : 1)
        )
    }
}

#Preview {
    VStack {
        MembershipCard(plan: .basic, isCurrentPlan: true, onUpgrade: {})
        MembershipCard(plan: .pro, isCurrentPlan: false, onUpgrade: {})
    }
    .padding()
}