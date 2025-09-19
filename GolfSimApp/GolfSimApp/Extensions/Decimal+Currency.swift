import Foundation

extension Decimal {
    func formattedAsCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US") // USD
        return formatter.string(from: self as NSNumber) ?? "$0.00"
    }
    
    func formattedAsPercentage() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.string(from: self as NSNumber) ?? "0%"
    }
}

extension Double {
    func formattedAsCurrency() -> String {
        return Decimal(self).formattedAsCurrency()
    }
}

extension Int {
    func formattedAsCurrency() -> String {
        return Decimal(self).formattedAsCurrency()
    }
}

extension TimeInterval {
    func formattedDuration() -> String {
        let hours = Int(self) / 3600
        let minutes = Int(self) % 3600 / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours) hour\(hours > 1 ? "s" : "")"
        } else {
            return "\(minutes) minute\(minutes > 1 ? "s" : "")"
        }
    }
}