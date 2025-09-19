import Foundation
import SwiftUI

// MARK: - Location Model
struct Location: Identifiable, Codable {
    let id: String
    let name: String
    let displayName: String
    let address: String
    let subtitle: String
    let operatingHours: OperatingHours
    let timezone: String
    let phoneNumber: String
    
    // Real-time status calculation
    var isCurrentlyOpen: Bool {
        let now = Date()
        let timeZone = TimeZone(identifier: timezone) ?? TimeZone.current
        let calendar = Calendar.current
        var calendarWithTimezone = calendar
        calendarWithTimezone.timeZone = timeZone
        
        let currentHour = calendarWithTimezone.component(.hour, from: now)
        let currentMinute = calendarWithTimezone.component(.minute, from: now)
        let currentTimeInMinutes = currentHour * 60 + currentMinute
        
        let weekday = calendarWithTimezone.component(.weekday, from: now)
        let isWeekend = weekday == 1 || weekday == 7 // Sunday = 1, Saturday = 7
        
        let todaysHours = isWeekend ? operatingHours.weekend : operatingHours.weekday
        
        return currentTimeInMinutes >= todaysHours.openMinutes && 
               currentTimeInMinutes < todaysHours.closeMinutes
    }
    
    var nextOpenTime: String? {
        if isCurrentlyOpen {
            return nil
        }
        
        let now = Date()
        let timeZone = TimeZone(identifier: timezone) ?? TimeZone.current
        let calendar = Calendar.current
        var calendarWithTimezone = calendar
        calendarWithTimezone.timeZone = timeZone
        
        let weekday = calendarWithTimezone.component(.weekday, from: now)
        let isWeekend = weekday == 1 || weekday == 7
        
        let todaysHours = isWeekend ? operatingHours.weekend : operatingHours.weekday
        let tomorrowsHours = operatingHours.weekday // Assume tomorrow is weekday for simplicity
        
        let currentHour = calendarWithTimezone.component(.hour, from: now)
        let currentMinute = calendarWithTimezone.component(.minute, from: now)
        let currentTimeInMinutes = currentHour * 60 + currentMinute
        
        // Check if we can open today
        if currentTimeInMinutes < todaysHours.openMinutes {
            return formatTime(minutes: todaysHours.openMinutes)
        } else {
            // Open tomorrow
            return formatTime(minutes: tomorrowsHours.openMinutes)
        }
    }
    
    var currentStatus: String {
        if isCurrentlyOpen {
            return "OPEN"
        } else if let nextOpen = nextOpenTime {
            return "CLOSED until \(nextOpen)"
        } else {
            return "CLOSED"
        }
    }
    
    private func formatTime(minutes: Int) -> String {
        let hour = minutes / 60
        let minute = minutes % 60
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        
        if minute == 0 {
            return "\(displayHour):00 \(period)"
        } else {
            return "\(displayHour):\(String(format: "%02d", minute)) \(period)"
        }
    }
    
    // Generate available time slots for today
    func availableTimeSlots() -> [String] {
        guard isCurrentlyOpen else { return [] }
        
        let now = Date()
        let timeZone = TimeZone(identifier: timezone) ?? TimeZone.current
        let calendar = Calendar.current
        var calendarWithTimezone = calendar
        calendarWithTimezone.timeZone = timeZone
        
        let weekday = calendarWithTimezone.component(.weekday, from: now)
        let isWeekend = weekday == 1 || weekday == 7
        let todaysHours = isWeekend ? operatingHours.weekend : operatingHours.weekday
        
        let currentHour = calendarWithTimezone.component(.hour, from: now)
        let currentMinute = calendarWithTimezone.component(.minute, from: now)
        let currentTimeInMinutes = currentHour * 60 + currentMinute
        
        // Round up to next 15-minute interval
        let nextSlotStart = ((currentTimeInMinutes + 14) / 15) * 15
        
        var slots: [String] = []
        var slotTime = nextSlotStart
        
        // Generate slots until closing (leave 1 hour buffer before close)
        while slotTime <= (todaysHours.closeMinutes - 60) && slots.count < 8 {
            slots.append(formatTime(minutes: slotTime))
            slotTime += 15 // 15-minute intervals
        }
        
        return slots
    }
}

// MARK: - Operating Hours
struct OperatingHours: Codable {
    let weekday: DayHours
    let weekend: DayHours
}

struct DayHours: Codable {
    let openMinutes: Int // Minutes from midnight (e.g., 8:00 AM = 480)
    let closeMinutes: Int // Minutes from midnight (e.g., 10:00 PM = 1320)
    
    var displayOpen: String {
        formatTime(minutes: openMinutes)
    }
    
    var displayClose: String {
        formatTime(minutes: closeMinutes)
    }
    
    private func formatTime(minutes: Int) -> String {
        let hour = minutes / 60
        let minute = minutes % 60
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        
        if minute == 0 {
            return "\(displayHour):00 \(period)"
        } else {
            return "\(displayHour):\(String(format: "%02d", minute)) \(period)"
        }
    }
}

// MARK: - Location Manager
class LocationManager: ObservableObject {
    @Published var selectedLocation: Location?
    @Published var isFirstLaunch: Bool = true
    
    private let userDefaults = UserDefaults.standard
    private let selectedLocationKey = "selectedLocationId"
    private let firstLaunchKey = "isFirstLaunch"
    
    // Available locations
    let availableLocations: [Location] = [
        Location(
            id: "redmond",
            name: "Redmond",
            displayName: "REDMOND",
            address: "14603 NE 87th ST, Redmond, WA 98052",
            subtitle: "Premier Indoor Golf",
            operatingHours: OperatingHours(
                weekday: DayHours(openMinutes: 480, closeMinutes: 1320), // 8:00 AM - 10:00 PM
                weekend: DayHours(openMinutes: 540, closeMinutes: 1260)  // 9:00 AM - 9:00 PM
            ),
            timezone: "America/Los_Angeles",
            phoneNumber: "(425) 555-0123"
        ),
        Location(
            id: "tacoma",
            name: "Tacoma",
            displayName: "TACOMA",
            address: "2101 Mildred St W, Tacoma, WA 98466",
            subtitle: "Indoor Golf Club",
            operatingHours: OperatingHours(
                weekday: DayHours(openMinutes: 480, closeMinutes: 1320), // 8:00 AM - 10:00 PM
                weekend: DayHours(openMinutes: 540, closeMinutes: 1260)  // 9:00 AM - 9:00 PM
            ),
            timezone: "America/Los_Angeles",
            phoneNumber: "(253) 555-0124"
        )
    ]
    
    init() {
        loadSelectedLocation()
        loadFirstLaunchStatus()
    }
    
    // MARK: - Public Methods
    func selectLocation(_ location: Location) {
        selectedLocation = location
        saveSelectedLocation()
        
        if isFirstLaunch {
            isFirstLaunch = false
            saveFirstLaunchStatus()
        }
    }
    
    func getLocation(by id: String) -> Location? {
        return availableLocations.first { $0.id == id }
    }
    
    // MARK: - Computed Properties
    var hasSelectedLocation: Bool {
        return selectedLocation != nil
    }
    
    var shouldShowOnboarding: Bool {
        return isFirstLaunch || !hasSelectedLocation
    }
    
    // MARK: - Private Methods
    private func loadSelectedLocation() {
        let savedLocationId = userDefaults.string(forKey: selectedLocationKey)
        if let locationId = savedLocationId {
            selectedLocation = getLocation(by: locationId)
        }
    }
    
    private func saveSelectedLocation() {
        if let location = selectedLocation {
            userDefaults.set(location.id, forKey: selectedLocationKey)
        }
    }
    
    private func loadFirstLaunchStatus() {
        // If key doesn't exist, it means first launch
        isFirstLaunch = !userDefaults.bool(forKey: firstLaunchKey)
    }
    
    private func saveFirstLaunchStatus() {
        userDefaults.set(!isFirstLaunch, forKey: firstLaunchKey)
    }
    
    // MARK: - Reset Methods (for testing)
    func resetToFirstLaunch() {
        isFirstLaunch = true
        selectedLocation = nil
        userDefaults.removeObject(forKey: selectedLocationKey)
        userDefaults.removeObject(forKey: firstLaunchKey)
    }
}