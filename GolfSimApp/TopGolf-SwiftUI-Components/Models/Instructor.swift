//
//  Instructor.swift
//  TopGolf-Inspired Golf Sim App
//
//  Golf instructor model for lessons, assessments, and professional guidance
//  Supports the golf simulation differentiation strategy
//

import Foundation
import CoreLocation

// MARK: - Instructor Model
struct Instructor: Identifiable, Codable {
    let id = UUID()
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let bio: String
    let profileImageURL: String?
    let certifications: [GolfCertification]
    let specialties: [SkillArea]
    let languages: [String]
    let experience: InstructorExperience
    let pricing: InstructorPricing
    let availability: InstructorAvailability
    let ratings: InstructorRating
    let venues: [Int] // Venue IDs where instructor teaches
    let status: InstructorStatus
    let joinedDate: Date
    
    // Professional details
    let professionalStatus: ProfessionalStatus
    let playingHistory: PlayingHistory?
    let teachingPhilosophy: String
    let successStories: [SuccessStory]
    
    // Contact and scheduling
    let timezone: String
    let preferredContactMethod: ContactMethod
    let responseTime: ResponseTime
    let cancelationPolicy: CancelationPolicy
    
    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, email, phone, bio, profileImageURL
        case certifications, specialties, languages, experience, pricing
        case availability, ratings, venues, status, joinedDate
        case professionalStatus, playingHistory, teachingPhilosophy, successStories
        case timezone, preferredContactMethod, responseTime, cancelationPolicy
    }
    
    // MARK: - Computed Properties
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var displayName: String {
        if professionalStatus.isProfessional {
            return "\(professionalStatus.title) \(fullName)"
        }
        return fullName
    }
    
    var initials: String {
        let firstInitial = firstName.prefix(1).uppercased()
        let lastInitial = lastName.prefix(1).uppercased()
        return "\(firstInitial)\(lastInitial)"
    }
    
    var yearsOfExperience: Int {
        experience.totalYears
    }
    
    var hourlyRate: Double {
        pricing.standardRate
    }
    
    var isAvailable: Bool {
        status == .active && availability.isCurrentlyAvailable
    }
    
    var averageRating: Double {
        ratings.averageRating
    }
    
    var totalReviews: Int {
        ratings.totalReviews
    }
    
    var ratingStars: String {
        let fullStars = Int(averageRating)
        let hasHalfStar = averageRating - Double(fullStars) >= 0.5
        let emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0)
        
        return String(repeating: "★", count: fullStars) +
               (hasHalfStar ? "½" : "") +
               String(repeating: "☆", count: emptyStars)
    }
    
    var specialtyNames: [String] {
        specialties.map { $0.displayName }
    }
    
    var primarySpecialty: SkillArea? {
        specialties.first
    }
    
    var isPremium: Bool {
        professionalStatus.isProfessional && averageRating >= 4.5
    }
    
    var isNewInstructor: Bool {
        let monthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        return joinedDate > monthsAgo
    }
    
    var experienceLevel: String {
        switch yearsOfExperience {
        case 0..<2: return "New Instructor"
        case 2..<5: return "Experienced"
        case 5..<10: return "Veteran"
        case 10..<20: return "Master Instructor"
        default: return "Legendary"
        }
    }
    
    var priceRange: String {
        let min = pricing.standardRate
        let max = pricing.premiumRate ?? pricing.standardRate
        
        if min == max {
            return String(format: "$%.0f/hour", min)
        } else {
            return String(format: "$%.0f-$%.0f/hour", min, max)
        }
    }
}

// MARK: - Golf Certifications
struct GolfCertification: Identifiable, Codable {
    let id = UUID()
    let name: String
    let organization: CertifyingOrganization
    let level: CertificationLevel
    let dateEarned: Date
    let expirationDate: Date?
    let certificateNumber: String
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, organization, level, dateEarned, expirationDate, certificateNumber, isActive
    }
    
    var isExpired: Bool {
        guard let expiration = expirationDate else { return false }
        return expiration < Date()
    }
    
    var isValid: Bool {
        isActive && !isExpired
    }
    
    var displayName: String {
        "\(organization.abbreviation) \(name)"
    }
}

enum CertifyingOrganization: String, CaseIterable, Codable {
    case pga = "pga"
    case pgaOfAmerica = "pga_of_america"
    case lpga = "lpga"
    case usgtf = "usgtf"
    case tpi = "tpi"
    case aim = "aim"
    case custom = "custom"
    
    var fullName: String {
        switch self {
        case .pga: return "Professional Golfers' Association"
        case .pgaOfAmerica: return "PGA of America"
        case .lpga: return "Ladies Professional Golf Association"
        case .usgtf: return "United States Golf Teachers Federation"
        case .tpi: return "Titleist Performance Institute"
        case .aim: return "AIM Golf"
        case .custom: return "Other Certification"
        }
    }
    
    var abbreviation: String {
        switch self {
        case .pga: return "PGA"
        case .pgaOfAmerica: return "PGA"
        case .lpga: return "LPGA"
        case .usgtf: return "USGTF"
        case .tpi: return "TPI"
        case .aim: return "AIM"
        case .custom: return "CERT"
        }
    }
    
    var prestige: Int {
        switch self {
        case .pga, .pgaOfAmerica, .lpga: return 5
        case .usgtf, .tpi: return 4
        case .aim: return 3
        case .custom: return 2
        }
    }
}

enum CertificationLevel: String, CaseIterable, Codable {
    case apprentice = "apprentice"
    case associate = "associate"
    case professional = "professional"
    case masterProfessional = "master_professional"
    case specialist = "specialist"
    
    var displayName: String {
        switch self {
        case .apprentice: return "Apprentice"
        case .associate: return "Associate"
        case .professional: return "Professional"
        case .masterProfessional: return "Master Professional"
        case .specialist: return "Specialist"
        }
    }
    
    var level: Int {
        switch self {
        case .apprentice: return 1
        case .associate: return 2
        case .professional: return 3
        case .masterProfessional: return 4
        case .specialist: return 3
        }
    }
}

// MARK: - Instructor Experience
struct InstructorExperience: Codable {
    let totalYears: Int
    let teachingYears: Int
    let competitiveYears: Int?
    let studentsTotal: Int
    let studentsImproved: Int
    let averageImprovement: Double // Handicap improvement
    let specialAchievements: [Achievement]
    let tournamentExperience: [TournamentExperience]
    
    var successRate: Double {
        guard studentsTotal > 0 else { return 0 }
        return Double(studentsImproved) / Double(studentsTotal) * 100
    }
    
    var hasCompetitiveBackground: Bool {
        competitiveYears != nil && competitiveYears! > 0
    }
    
    var hasTournamentExperience: Bool {
        !tournamentExperience.isEmpty
    }
}

struct TournamentExperience: Identifiable, Codable {
    let id = UUID()
    let name: String
    let year: Int
    let result: String
    let level: TournamentLevel
    
    enum CodingKeys: String, CodingKey {
        case name, year, result, level
    }
    
    enum TournamentLevel: String, CaseIterable, Codable {
        case local = "local"
        case regional = "regional"
        case national = "national"
        case professional = "professional"
        case major = "major"
        
        var displayName: String {
            switch self {
            case .local: return "Local"
            case .regional: return "Regional"
            case .national: return "National"
            case .professional: return "Professional"
            case .major: return "Major Championship"
            }
        }
        
        var prestige: Int {
            switch self {
            case .local: return 1
            case .regional: return 2
            case .national: return 3
            case .professional: return 4
            case .major: return 5
            }
        }
    }
}

// MARK: - Instructor Pricing
struct InstructorPricing: Codable {
    let standardRate: Double
    let premiumRate: Double?
    let groupRate: Double
    let packageRates: [LessonPackage]
    let assessmentRate: Double
    let onlineRate: Double?
    let travelFee: Double?
    let cancellationFee: Double?
    
    var hasPackageDeals: Bool {
        !packageRates.isEmpty
    }
    
    var bestPackageValue: LessonPackage? {
        packageRates.max { $0.savingsPercentage < $1.savingsPercentage }
    }
    
    var offersOnlineLessons: Bool {
        onlineRate != nil
    }
}

struct LessonPackage: Identifiable, Codable {
    let id = UUID()
    let name: String
    let lessons: Int
    let totalPrice: Double
    let validityDays: Int
    let description: String
    let features: [String]
    
    enum CodingKeys: String, CodingKey {
        case name, lessons, totalPrice, validityDays, description, features
    }
    
    var pricePerLesson: Double {
        totalPrice / Double(lessons)
    }
    
    var savingsPercentage: Double {
        // Assuming standard rate for comparison
        // In real implementation, this would compare to instructor's standard rate
        let standardTotal = Double(lessons) * 100.0 // Example standard rate
        return ((standardTotal - totalPrice) / standardTotal) * 100
    }
    
    var displaySavings: String {
        String(format: "Save %.0f%%", savingsPercentage)
    }
}

// MARK: - Instructor Availability
struct InstructorAvailability: Codable {
    let weeklySchedule: [DayAvailability]
    let timeZone: String
    let advanceBookingDays: Int
    let minNoticeHours: Int
    let blockoutDates: [Date]
    let specialAvailability: [SpecialAvailability]
    
    var isCurrentlyAvailable: Bool {
        let now = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now)
        let hour = calendar.component(.hour, from: now)
        
        guard let today = weeklySchedule.first(where: { $0.dayOfWeek == weekday }) else {
            return false
        }
        
        return today.isAvailable && today.timeSlots.contains { timeSlot in
            hour >= timeSlot.startHour && hour < timeSlot.endHour
        }
    }
    
    var nextAvailableSlot: Date? {
        // Implementation would find next available time slot
        // This is a simplified version
        return Calendar.current.date(byAdding: .hour, value: 2, to: Date())
    }
}

struct DayAvailability: Codable {
    let dayOfWeek: Int // 1 = Sunday, 2 = Monday, etc.
    let isAvailable: Bool
    let timeSlots: [TimeSlot]
    
    var dayName: String {
        let formatter = DateFormatter()
        return formatter.weekdaySymbols[dayOfWeek - 1]
    }
    
    struct TimeSlot: Codable {
        let startHour: Int
        let endHour: Int
        let lessonType: LessonType?
        
        var timeRange: String {
            let startTime = startHour < 13 ? "\(startHour):00 AM" : "\(startHour - 12):00 PM"
            let endTime = endHour < 13 ? "\(endHour):00 AM" : "\(endHour - 12):00 PM"
            return "\(startTime) - \(endTime)"
        }
        
        enum LessonType: String, CaseIterable, Codable {
            case individual = "individual"
            case group = "group"
            case assessment = "assessment"
            case online = "online"
            
            var displayName: String {
                switch self {
                case .individual: return "Individual"
                case .group: return "Group"
                case .assessment: return "Assessment"
                case .online: return "Online"
                }
            }
        }
    }
}

struct SpecialAvailability: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let isAvailable: Bool
    let note: String?
    let specialRate: Double?
    
    enum CodingKeys: String, CodingKey {
        case date, isAvailable, note, specialRate
    }
}

// MARK: - Instructor Rating
struct InstructorRating: Codable {
    let averageRating: Double
    let totalReviews: Int
    let ratingDistribution: [Int] // [5-star count, 4-star count, 3-star count, 2-star count, 1-star count]
    let recentReviews: [Review]
    let responseRate: Double
    let onTimeRate: Double
    let qualityScore: Double
    
    var hasGoodRating: Bool {
        averageRating >= 4.0
    }
    
    var hasExcellentRating: Bool {
        averageRating >= 4.5
    }
    
    var isProfessionallyRated: Bool {
        totalReviews >= 10 && averageRating >= 4.0
    }
}

struct Review: Identifiable, Codable {
    let id = UUID()
    let studentName: String
    let rating: Int
    let comment: String
    let date: Date
    let lessonType: String
    let isVerified: Bool
    let helpfulVotes: Int
    
    enum CodingKeys: String, CodingKey {
        case studentName, rating, comment, date, lessonType, isVerified, helpfulVotes
    }
    
    var ratingStars: String {
        String(repeating: "★", count: rating) + String(repeating: "☆", count: 5 - rating)
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Supporting Enums and Structs
enum InstructorStatus: String, CaseIterable, Codable {
    case active = "active"
    case inactive = "inactive"
    case vacation = "vacation"
    case suspended = "suspended"
    case pending = "pending"
    
    var displayName: String {
        switch self {
        case .active: return "Active"
        case .inactive: return "Inactive"
        case .vacation: return "On Vacation"
        case .suspended: return "Suspended"
        case .pending: return "Pending Approval"
        }
    }
    
    var isAvailable: Bool {
        self == .active
    }
}

enum ProfessionalStatus: String, CaseIterable, Codable {
    case instructor = "instructor"
    case pgaProfessional = "pga_professional"
    case lpgaProfessional = "lpga_professional"
    case masterProfessional = "master_professional"
    case headProfessional = "head_professional"
    case directorOfInstruction = "director_of_instruction"
    
    var displayName: String {
        switch self {
        case .instructor: return "Golf Instructor"
        case .pgaProfessional: return "PGA Professional"
        case .lpgaProfessional: return "LPGA Professional"
        case .masterProfessional: return "Master Professional"
        case .headProfessional: return "Head Professional"
        case .directorOfInstruction: return "Director of Instruction"
        }
    }
    
    var title: String {
        switch self {
        case .instructor: return ""
        case .pgaProfessional: return "PGA Pro"
        case .lpgaProfessional: return "LPGA Pro"
        case .masterProfessional: return "Master Pro"
        case .headProfessional: return "Head Pro"
        case .directorOfInstruction: return "Director"
        }
    }
    
    var isProfessional: Bool {
        self != .instructor
    }
    
    var prestige: Int {
        switch self {
        case .instructor: return 1
        case .pgaProfessional, .lpgaProfessional: return 3
        case .masterProfessional: return 4
        case .headProfessional: return 4
        case .directorOfInstruction: return 5
        }
    }
}

struct PlayingHistory: Codable {
    let handicap: Double?
    let lowestHandicap: Double?
    let tournamentWins: Int
    let professionalStatus: String?
    let collegeGolf: String?
    let notableAchievements: [String]
    
    var displayHandicap: String {
        guard let handicap = handicap else { return "N/A" }
        return String(format: "%.1f", handicap)
    }
    
    var hasCompetitiveBackground: Bool {
        tournamentWins > 0 || professionalStatus != nil || collegeGolf != nil
    }
}

struct SuccessStory: Identifiable, Codable {
    let id = UUID()
    let studentName: String
    let beforeHandicap: Double
    let afterHandicap: Double
    let timeframe: String
    let description: String
    let beforePhoto: String?
    let afterPhoto: String?
    
    enum CodingKeys: String, CodingKey {
        case studentName, beforeHandicap, afterHandicap, timeframe, description, beforePhoto, afterPhoto
    }
    
    var improvement: Double {
        beforeHandicap - afterHandicap
    }
    
    var improvementText: String {
        String(format: "Improved %.1f strokes", improvement)
    }
    
    var hasPhotos: Bool {
        beforePhoto != nil || afterPhoto != nil
    }
}

enum ContactMethod: String, CaseIterable, Codable {
    case email = "email"
    case phone = "phone"
    case text = "text"
    case app = "app"
    
    var displayName: String {
        switch self {
        case .email: return "Email"
        case .phone: return "Phone"
        case .text: return "Text Message"
        case .app: return "In-App Message"
        }
    }
    
    var icon: String {
        switch self {
        case .email: return "envelope"
        case .phone: return "phone"
        case .text: return "message"
        case .app: return "bubble.left.and.bubble.right"
        }
    }
}

enum ResponseTime: String, CaseIterable, Codable {
    case immediate = "immediate"
    case within1Hour = "within_1_hour"
    case within4Hours = "within_4_hours"
    case within24Hours = "within_24_hours"
    case within48Hours = "within_48_hours"
    
    var displayName: String {
        switch self {
        case .immediate: return "Usually responds immediately"
        case .within1Hour: return "Usually responds within 1 hour"
        case .within4Hours: return "Usually responds within 4 hours"
        case .within24Hours: return "Usually responds within 24 hours"
        case .within48Hours: return "Usually responds within 48 hours"
        }
    }
    
    var hours: Int {
        switch self {
        case .immediate: return 0
        case .within1Hour: return 1
        case .within4Hours: return 4
        case .within24Hours: return 24
        case .within48Hours: return 48
        }
    }
}

struct CancelationPolicy: Codable {
    let hoursRequired: Int
    let feePercentage: Double
    let freeReschedules: Int
    let description: String
    
    var displayPolicy: String {
        if hoursRequired == 0 {
            return "Cancel anytime without fee"
        } else if feePercentage == 0 {
            return "Cancel \(hoursRequired) hours before - no fee"
        } else {
            return "Cancel \(hoursRequired) hours before or pay \(Int(feePercentage * 100))% fee"
        }
    }
    
    var isFlexible: Bool {
        hoursRequired <= 4 && feePercentage <= 0.25
    }
}

// MARK: - Sample Data
extension Instructor {
    static let sampleInstructors: [Instructor] = [
        Instructor(
            firstName: "Michael",
            lastName: "Johnson",
            email: "mjohnson@golfsim.com",
            phone: "(425) 555-0101",
            bio: "PGA Professional with 15 years of teaching experience. Specializes in swing mechanics and short game improvement. Former college golf coach with proven track record of student success.",
            profileImageURL: nil,
            certifications: [
                GolfCertification(
                    name: "Class A Professional",
                    organization: .pgaOfAmerica,
                    level: .professional,
                    dateEarned: Calendar.current.date(byAdding: .year, value: -10, to: Date()) ?? Date(),
                    expirationDate: nil,
                    certificateNumber: "PGA123456",
                    isActive: true
                )
            ],
            specialties: [.fullSwing, .shortGame, .courseManagement],
            languages: ["English", "Spanish"],
            experience: InstructorExperience(
                totalYears: 15,
                teachingYears: 12,
                competitiveYears: 8,
                studentsTotal: 250,
                studentsImproved: 220,
                averageImprovement: 4.2,
                specialAchievements: [],
                tournamentExperience: []
            ),
            pricing: InstructorPricing(
                standardRate: 85.0,
                premiumRate: 110.0,
                groupRate: 60.0,
                packageRates: [
                    LessonPackage(
                        name: "Beginner Package",
                        lessons: 4,
                        totalPrice: 300.0,
                        validityDays: 60,
                        description: "Perfect for new golfers",
                        features: ["Fundamentals", "Equipment fitting", "Course introduction"]
                    )
                ],
                assessmentRate: 125.0,
                onlineRate: 65.0,
                travelFee: 25.0,
                cancellationFee: 42.50
            ),
            availability: InstructorAvailability(
                weeklySchedule: [
                    DayAvailability(dayOfWeek: 2, isAvailable: true, timeSlots: [
                        DayAvailability.TimeSlot(startHour: 9, endHour: 17, lessonType: .individual)
                    ]),
                    DayAvailability(dayOfWeek: 3, isAvailable: true, timeSlots: [
                        DayAvailability.TimeSlot(startHour: 9, endHour: 17, lessonType: .individual)
                    ])
                ],
                timeZone: "America/Los_Angeles",
                advanceBookingDays: 30,
                minNoticeHours: 24,
                blockoutDates: [],
                specialAvailability: []
            ),
            ratings: InstructorRating(
                averageRating: 4.8,
                totalReviews: 127,
                ratingDistribution: [89, 28, 8, 2, 0],
                recentReviews: [],
                responseRate: 0.98,
                onTimeRate: 0.99,
                qualityScore: 4.9
            ),
            venues: [1, 2],
            status: .active,
            joinedDate: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date(),
            professionalStatus: .pgaProfessional,
            playingHistory: PlayingHistory(
                handicap: 2.1,
                lowestHandicap: 0.8,
                tournamentWins: 12,
                professionalStatus: "Mini Tour Player",
                collegeGolf: "Stanford University",
                notableAchievements: ["State Amateur Champion", "Club Championship Winner"]
            ),
            teachingPhilosophy: "Every golfer is unique. My goal is to help you find your natural swing while building fundamentals that will serve you for life.",
            successStories: [],
            timezone: "America/Los_Angeles",
            preferredContactMethod: .email,
            responseTime: .within4Hours,
            cancelationPolicy: CancelationPolicy(
                hoursRequired: 24,
                feePercentage: 0.5,
                freeReschedules: 2,
                description: "24-hour cancellation policy with up to 2 free reschedules per month."
            )
        )
    ]
}