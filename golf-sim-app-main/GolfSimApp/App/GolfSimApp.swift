import SwiftUI

@main
struct GolfSimApp: App {
    @StateObject private var bookingManager = BookingManager()
    @StateObject private var tabManager = TabManager()
    @StateObject private var paymentManager = PaymentManager()
    @StateObject private var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bookingManager)
                .environmentObject(tabManager)
                .environmentObject(paymentManager)
                .environmentObject(locationManager)
        }
    }
}