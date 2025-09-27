//
//  GolfSimSession.swift
//  TopGolf-Inspired Golf Sim App
//
//  Golf simulation specific models for training and skill development
//  Differentiates from entertainment-focused TopGolf model
//

import Foundation

// MARK: - Golf Simulation Session Model
struct GolfSimSession: Identifiable, Codable {
    let id = UUID()
    let type: SessionType
    let timeSlot: TimeSlot
    let venue: Venue
    let instructor: Instructor?
    let skillFocus: [SkillArea]
    let participants: [GolfSimParticipant]
    let equipment: SessionEquipment
    let goals: [TrainingGoal]
    let status: SessionStatus
    let createdAt: Date
    let updatedAt: Date
    
    // Session progress tracking
    let startedAt: Date?
    let completedAt: Date?
    let pausedDuration: TimeInterval
    let actualDuration: TimeInterval?
    
    // Performance data
    let shots: [ShotData]
    let metrics: SessionMetrics?
    let achievements: [Achievement]
    let feedback: SessionFeedback?
    
    // Session configuration
    let difficulty: DifficultyLevel
    let course: VirtualCourse?
    let gameMode: GameMode
    let scoringMethod: ScoringMethod
    
    enum CodingKeys: String, CodingKey {
        case id, type, timeSlot, venue, instructor, skillFocus, participants
        case equipment, goals, status, createdAt, updatedAt
        case startedAt, completedAt, pausedDuration, actualDuration
        case shots, metrics, achievements, feedback
        case difficulty, course, gameMode, scoringMethod
    }
    
    // MARK: - Computed Properties
    
    var duration: TimeInterval {
        timeSlot.duration
    }
    
    var isActive: Bool {
        status == .inProgress
    }
    
    var isCompleted: Bool {
        status == .completed
    }
    
    var hasInstructor: Bool {
        instructor != nil
    }
    
    var participantCount: Int {
        participants.count
    }
    
    var averageScore: Double? {
        guard !shots.isEmpty else { return nil }
        let totalScore = shots.compactMap { $0.score }.reduce(0, +)
        return Double(totalScore) / Double(shots.count)
    }
    
    var improvementScore: Double? {
        guard shots.count >= 10 else { return nil }
        let firstHalf = shots.prefix(shots.count / 2)
        let secondHalf = shots.suffix(shots.count / 2)
        
        let firstAverage = firstHalf.compactMap { $0.score }.reduce(0, +) / firstHalf.count
        let secondAverage = secondHalf.compactMap { $0.score }.reduce(0, +) / secondHalf.count
        
        return Double(secondAverage - firstAverage)
    }
    
    var totalCost: Double {
        var cost = timeSlot.price
        
        if let instructor = instructor {
            cost += instructor.hourlyRate * (duration / 3600)
        }
        
        cost += equipment.totalCost
        return cost
    }
}

// MARK: - Session Type
enum SessionType: String, CaseIterable, Codable {
    case practice = "practice"
    case lesson = "lesson"
    case assessment = "assessment"
    case tournament = "tournament"
    case corporate = "corporate"
    case fitting = "fitting"
    case challenge = "challenge"
    
    var displayName: String {
        switch self {
        case .practice: return "Practice Session"
        case .lesson: return "Golf Lesson"
        case .assessment: return "Skill Assessment"
        case .tournament: return "Tournament Play"
        case .corporate: return "Corporate Event"
        case .fitting: return "Club Fitting"
        case .challenge: return "Skills Challenge"
        }
    }
    
    var description: String {
        switch self {
        case .practice: return "Open practice with performance tracking"
        case .lesson: return "Guided instruction with certified golf professional"
        case .assessment: return "Comprehensive skill evaluation and recommendations"
        case .tournament: return "Competitive play against other golfers"
        case .corporate: return "Team building and corporate entertainment"
        case .fitting: return "Professional club fitting session"
        case .challenge: return "Skill-based challenges and mini-games"
        }
    }
    
    var icon: String {
        switch self {
        case .practice: return "figure.golf"
        case .lesson: return "person.2.badge.gearshape"
        case .assessment: return "chart.bar.doc.horizontal"
        case .tournament: return "trophy"
        case .corporate: return "building.2"
        case .fitting: return "ruler"
        case .challenge: return "target"
        }
    }
    
    var requiresInstructor: Bool {
        switch self {
        case .lesson, .assessment, .fitting: return true
        default: return false
        }
    }
    
    var maxParticipants: Int {
        switch self {
        case .lesson: return 4
        case .assessment, .fitting: return 1
        case .corporate: return 12
        default: return 6
        }
    }
}

// MARK: - Skill Areas
enum SkillArea: String, CaseIterable, Codable {
    case driving = "driving"
    case putting = "putting"
    case shortGame = "short_game"
    case fullSwing = "full_swing"
    case bunkerPlay = "bunker_play"
    case courseManagement = "course_management"
    case mentalGame = "mental_game"
    case fitness = "fitness"
    
    var displayName: String {
        switch self {
        case .driving: return "Driving"
        case .putting: return "Putting"
        case .shortGame: return "Short Game"
        case .fullSwing: return "Full Swing"
        case .bunkerPlay: return "Bunker Play"
        case .courseManagement: return "Course Management"
        case .mentalGame: return "Mental Game"
        case .fitness: return "Golf Fitness"
        }
    }
    
    var description: String {
        switch self {
        case .driving: return "Distance and accuracy with driver"
        case .putting: return "Green reading and putting technique"
        case .shortGame: return "Chipping, pitching, and wedge play"
        case .fullSwing: return "Iron and fairway wood technique"
        case .bunkerPlay: return "Sand shots and recovery"
        case .courseManagement: return "Strategy and decision making"
        case .mentalGame: return "Focus, confidence, and pressure management"
        case .fitness: return "Golf-specific strength and flexibility"
        }
    }
    
    var icon: String {
        switch self {
        case .driving: return "arrow.up.right"
        case .putting: return "circle.and.line.horizontal"
        case .shortGame: return "arc.counterclockwise"
        case .fullSwing: return "figure.golf"
        case .bunkerPlay: return "mountain.2"
        case .courseManagement: return "map"
        case .mentalGame: return "brain.head.profile"
        case .fitness: return "figure.strengthtraining.traditional"
        }
    }
    
    var color: String {
        switch self {
        case .driving: return "red"
        case .putting: return "green"
        case .shortGame: return "orange"
        case .fullSwing: return "blue"
        case .bunkerPlay: return "brown"
        case .courseManagement: return "purple"
        case .mentalGame: return "indigo"
        case .fitness: return "pink"
        }
    }
}

// MARK: - Golf Sim Participant
struct GolfSimParticipant: Identifiable, Codable {
    let id = UUID()
    let name: String
    let handicap: Double?
    let skillLevel: SkillLevel
    let dominantHand: Hand
    let experienceLevel: ExperienceLevel
    let goals: [PersonalGoal]
    let medicalConsiderations: [String]
    let preferredEquipment: [String]
    let previousSessions: Int
    
    enum Hand: String, CaseIterable, Codable {
        case right = "right"
        case left = "left"
        
        var displayName: String {
            switch self {
            case .right: return "Right-handed"
            case .left: return "Left-handed"
            }
        }
    }
    
    enum ExperienceLevel: String, CaseIterable, Codable {
        case never = "never"
        case beginner = "beginner"
        case casual = "casual"
        case regular = "regular"
        case competitive = "competitive"
        case professional = "professional"
        
        var displayName: String {
            switch self {
            case .never: return "Never Played"
            case .beginner: return "Beginner"
            case .casual: return "Casual Player"
            case .regular: return "Regular Player"
            case .competitive: return "Competitive Player"
            case .professional: return "Professional"
            }
        }
        
        var numericValue: Int {
            switch self {
            case .never: return 0
            case .beginner: return 1
            case .casual: return 2
            case .regular: return 3
            case .competitive: return 4
            case .professional: return 5
            }
        }
    }
    
    var displayHandicap: String {
        guard let handicap = handicap else { return "N/A" }
        return String(format: "%.1f", handicap)
    }
    
    var isExperienced: Bool {
        experienceLevel.numericValue >= 3
    }
}

// MARK: - Session Equipment
struct SessionEquipment: Codable {
    let clubs: [ClubSelection]
    let balls: BallType
    let accessories: [AccessoryItem]
    let totalCost: Double
    
    var clubCount: Int {
        clubs.count
    }
    
    var hasDrivers: Bool {
        clubs.contains { $0.type == .driver }
    }
    
    var hasIrons: Bool {
        clubs.contains { $0.type == .iron }
    }
    
    var hasPutter: Bool {
        clubs.contains { $0.type == .putter }
    }
}

struct ClubSelection: Identifiable, Codable {
    let id = UUID()
    let type: ClubType
    let brand: String
    let model: String
    let loft: Double?
    let shaft: ShaftType
    let grip: GripType
    let isLeftHanded: Bool
    let rentalCost: Double
    
    enum CodingKeys: String, CodingKey {
        case type, brand, model, loft, shaft, grip, isLeftHanded, rentalCost
    }
    
    enum ClubType: String, CaseIterable, Codable {
        case driver = "driver"
        case fairwayWood = "fairway_wood"
        case hybrid = "hybrid"
        case iron = "iron"
        case wedge = "wedge"
        case putter = "putter"
        
        var displayName: String {
            switch self {
            case .driver: return "Driver"
            case .fairwayWood: return "Fairway Wood"
            case .hybrid: return "Hybrid"
            case .iron: return "Iron"
            case .wedge: return "Wedge"
            case .putter: return "Putter"
            }
        }
    }
    
    enum ShaftType: String, CaseIterable, Codable {
        case regular = "regular"
        case stiff = "stiff"
        case extraStiff = "extra_stiff"
        case senior = "senior"
        case ladies = "ladies"
        
        var displayName: String {
            switch self {
            case .regular: return "Regular"
            case .stiff: return "Stiff"
            case .extraStiff: return "Extra Stiff"
            case .senior: return "Senior"
            case .ladies: return "Ladies"
            }
        }
    }
    
    enum GripType: String, CaseIterable, Codable {
        case standard = "standard"
        case midsize = "midsize"
        case jumbo = "jumbo"
        case corded = "corded"
        
        var displayName: String {
            switch self {
            case .standard: return "Standard"
            case .midsize: return "Midsize"
            case .jumbo: return "Jumbo"
            case .corded: return "Corded"
            }
        }
    }
    
    var fullName: String {
        "\(brand) \(model)"
    }
}

enum BallType: String, CaseIterable, Codable {
    case standard = "standard"
    case premium = "premium"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .premium: return "Premium"
        case .custom: return "Custom"
        }
    }
    
    var cost: Double {
        switch self {
        case .standard: return 0.0
        case .premium: return 10.0
        case .custom: return 25.0
        }
    }
}

struct AccessoryItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let category: AccessoryCategory
    let cost: Double
    let isRequired: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, category, cost, isRequired
    }
    
    enum AccessoryCategory: String, CaseIterable, Codable {
        case safety = "safety"
        case comfort = "comfort"
        case performance = "performance"
        case recording = "recording"
        
        var displayName: String {
            switch self {
            case .safety: return "Safety"
            case .comfort: return "Comfort"
            case .performance: return "Performance"
            case .recording: return "Recording"
            }
        }
    }
}

// MARK: - Training Goals and Personal Goals
struct TrainingGoal: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let targetMetric: String
    let targetValue: Double
    let currentValue: Double?
    let isAchieved: Bool
    let deadline: Date?
    
    var progress: Double {
        guard let current = currentValue, targetValue > 0 else { return 0 }
        return min(current / targetValue, 1.0) * 100
    }
    
    var progressText: String {
        String(format: "%.1f%%", progress)
    }
}

struct PersonalGoal: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let category: GoalCategory
    let priority: Priority
    let timeframe: Timeframe
    
    enum GoalCategory: String, CaseIterable, Codable {
        case technical = "technical"
        case mental = "mental"
        case physical = "physical"
        case competitive = "competitive"
        
        var displayName: String {
            switch self {
            case .technical: return "Technical"
            case .mental: return "Mental"
            case .physical: return "Physical"
            case .competitive: return "Competitive"
            }
        }
    }
    
    enum Priority: String, CaseIterable, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        
        var displayName: String {
            switch self {
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
            }
        }
        
        var color: String {
            switch self {
            case .low: return "green"
            case .medium: return "orange"
            case .high: return "red"
            }
        }
    }
    
    enum Timeframe: String, CaseIterable, Codable {
        case session = "session"
        case week = "week"
        case month = "month"
        case quarter = "quarter"
        case year = "year"
        
        var displayName: String {
            switch self {
            case .session: return "This Session"
            case .week: return "This Week"
            case .month: return "This Month"
            case .quarter: return "This Quarter"
            case .year: return "This Year"
            }
        }
    }
}

// MARK: - Session Status
enum SessionStatus: String, CaseIterable, Codable {
    case scheduled = "scheduled"
    case inProgress = "in_progress"
    case paused = "paused"
    case completed = "completed"
    case cancelled = "cancelled"
    case noShow = "no_show"
    
    var displayName: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .inProgress: return "In Progress"
        case .paused: return "Paused"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .noShow: return "No Show"
        }
    }
    
    var color: String {
        switch self {
        case .scheduled: return "blue"
        case .inProgress: return "green"
        case .paused: return "orange"
        case .completed: return "purple"
        case .cancelled: return "red"
        case .noShow: return "gray"
        }
    }
    
    var isActive: Bool {
        self == .inProgress || self == .paused
    }
}

// MARK: - Supporting Enums
enum DifficultyLevel: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case expert = "expert"
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var numericValue: Int {
        switch self {
        case .beginner: return 1
        case .intermediate: return 2
        case .advanced: return 3
        case .expert: return 4
        }
    }
}

enum GameMode: String, CaseIterable, Codable {
    case practice = "practice"
    case strokePlay = "stroke_play"
    case matchPlay = "match_play"
    case skins = "skins"
    case scramble = "scramble"
    case bestBall = "best_ball"
    case skillsChallenge = "skills_challenge"
    
    var displayName: String {
        switch self {
        case .practice: return "Practice"
        case .strokePlay: return "Stroke Play"
        case .matchPlay: return "Match Play"
        case .skins: return "Skins"
        case .scramble: return "Scramble"
        case .bestBall: return "Best Ball"
        case .skillsChallenge: return "Skills Challenge"
        }
    }
}

enum ScoringMethod: String, CaseIterable, Codable {
    case stroke = "stroke"
    case stableford = "stableford"
    case modified = "modified"
    case points = "points"
    
    var displayName: String {
        switch self {
        case .stroke: return "Stroke Play"
        case .stableford: return "Stableford"
        case .modified: return "Modified Stableford"
        case .points: return "Points System"
        }
    }
}

// MARK: - Performance Data Models
struct ShotData: Identifiable, Codable {
    let id = UUID()
    let timestamp: Date
    let club: ClubSelection
    let distance: Double
    let accuracy: Double
    let ballSpeed: Double
    let clubSpeed: Double
    let launchAngle: Double
    let spinRate: Double
    let score: Int?
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case timestamp, club, distance, accuracy, ballSpeed, clubSpeed
        case launchAngle, spinRate, score, notes
    }
    
    var displayDistance: String {
        String(format: "%.0f yds", distance)
    }
    
    var displayAccuracy: String {
        String(format: "%.1f%%", accuracy * 100)
    }
    
    var isGoodShot: Bool {
        accuracy > 0.7 && score ?? 0 <= 2
    }
}

struct SessionMetrics: Codable {
    let totalShots: Int
    let averageDistance: Double
    let averageAccuracy: Double
    let bestShot: ShotData?
    let improvementAreas: [SkillArea]
    let strengths: [SkillArea]
    let overallScore: Double
    let handicapImpact: Double?
    
    var gradeLevel: GradeLevel {
        switch overallScore {
        case 90...100: return .excellent
        case 80..<90: return .good
        case 70..<80: return .average
        case 60..<70: return .needsWork
        default: return .poor
        }
    }
    
    enum GradeLevel: String, CaseIterable {
        case excellent = "excellent"
        case good = "good"
        case average = "average"
        case needsWork = "needs_work"
        case poor = "poor"
        
        var displayName: String {
            switch self {
            case .excellent: return "Excellent"
            case .good: return "Good"
            case .average: return "Average"
            case .needsWork: return "Needs Work"
            case .poor: return "Poor"
            }
        }
        
        var color: String {
            switch self {
            case .excellent: return "green"
            case .good: return "blue"
            case .average: return "orange"
            case .needsWork: return "red"
            case .poor: return "gray"
            }
        }
    }
}

struct Achievement: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let earnedAt: Date
    let category: AchievementCategory
    let rarity: AchievementRarity
    
    enum CodingKeys: String, CodingKey {
        case title, description, icon, earnedAt, category, rarity
    }
    
    enum AchievementCategory: String, CaseIterable, Codable {
        case accuracy = "accuracy"
        case distance = "distance"
        case consistency = "consistency"
        case improvement = "improvement"
        case milestone = "milestone"
        
        var displayName: String {
            rawValue.capitalized
        }
    }
    
    enum AchievementRarity: String, CaseIterable, Codable {
        case common = "common"
        case uncommon = "uncommon"
        case rare = "rare"
        case epic = "epic"
        case legendary = "legendary"
        
        var displayName: String {
            rawValue.capitalized
        }
        
        var color: String {
            switch self {
            case .common: return "gray"
            case .uncommon: return "green"
            case .rare: return "blue"
            case .epic: return "purple"
            case .legendary: return "orange"
            }
        }
    }
}

struct SessionFeedback: Codable {
    let instructorNotes: String?
    let playerNotes: String?
    let recommendedPractice: [SkillArea]
    let nextSessionFocus: [SkillArea]
    let overallRating: Int // 1-5 stars
    let improvements: [String]
    let challenges: [String]
    
    var hasInstructorFeedback: Bool {
        instructorNotes?.isEmpty == false
    }
    
    var hasPlayerFeedback: Bool {
        playerNotes?.isEmpty == false
    }
    
    var ratingStars: String {
        String(repeating: "★", count: overallRating) + String(repeating: "☆", count: 5 - overallRating)
    }
}

struct VirtualCourse: Identifiable, Codable {
    let id = UUID()
    let name: String
    let location: String
    let designer: String
    let difficulty: DifficultyLevel
    let holes: Int
    let par: Int
    let length: Int
    let description: String
    let features: [String]
    
    enum CodingKeys: String, CodingKey {
        case name, location, designer, difficulty, holes, par, length, description, features
    }
    
    var displayLength: String {
        String(format: "%d yards", length)
    }
    
    var isChampionship: Bool {
        length > 7000 && difficulty == .expert
    }
}