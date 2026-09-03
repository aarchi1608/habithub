//
//  Habit.swift
//  HabitTracker
//
//  Created by Saikat Kumar Dey on 01/07/23.
//

import Foundation
import SwiftUI

enum ReminderFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}

enum HabitCategory: String, Codable, CaseIterable, Identifiable {
    case general = "General"
    case fitness = "Fitness"
    case mindset = "Mindset"
    case productivity = "Productivity"
    case health = "Health"
    case wealth = "Finance"
    case creativity = "Creativity"
    case learning = "Learning"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .general: return "sparkles"
        case .fitness: return "figure.run"
        case .mindset: return "brain.head.profile"
        case .productivity: return "bolt.fill"
        case .health: return "heart.fill"
        case .wealth: return "dollarsign.circle.fill"
        case .creativity: return "paintpalette.fill"
        case .learning: return "book.fill"
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .general: return [Color.purple, Color.blue]
        case .fitness: return [Color.orange, Color.red]
        case .mindset: return [Color.indigo, Color.purple]
        case .productivity: return [Color.blue, Color.cyan]
        case .health: return [Color.green, Color.mint]
        case .wealth: return [Color.yellow, Color.orange]
        case .creativity: return [Color.pink, Color.purple]
        case .learning: return [Color.teal, Color.blue]
        }
    }
}

enum HabitTargetType: String, Codable, CaseIterable {
    case checkmark = "Checkmark"
    case timer = "Focus Timer"
}

struct HabitNote: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var text: String
}

class Habit: ObservableObject, Identifiable, Codable {
    
    @Published var id: UUID = UUID()
    @Published var symbol: String = HabitSymbols.default
    @Published var color: Color = ColorOptions.default
    @Published var title: String = ""
    @Published var completedDates: Set<DateComponents> = []
    @Published var maxStreak: Int = 0
    @Published var startDate: Date = Date()
    @Published var isHabitCompleted: Bool = false
    @Published var completedDate: Date? = nil
    @Published var reminderFrequency: ReminderFrequency? = nil
    @Published var lastUpdated: Date = Date()
    
    // New Feature Properties
    @Published var category: HabitCategory = .general
    @Published var targetType: HabitTargetType = .checkmark
    @Published var targetMinutes: Int = 15
    @Published var notes: [HabitNote] = []
    @Published var routineStack: String? = nil
    
    init(title: String = "",
         completedDates: Set<DateComponents> = [],
         startDate: Date = Date(),
         isCompleted: Bool = false,
         completedDate: Date? = nil,
         category: HabitCategory = .general,
         targetType: HabitTargetType = .checkmark,
         targetMinutes: Int = 15,
         routineStack: String? = nil) {
        self.title = title
        self.completedDates = completedDates
        self.startDate = startDate
        self.isHabitCompleted = isCompleted
        self.completedDate = completedDate
        self.category = category
        self.targetType = targetType
        self.targetMinutes = targetMinutes
        self.routineStack = routineStack
        self.lastUpdated = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, completedDates, startDate, isHabitCompleted, completedDate,
             reminderFrequency, lastUpdated, symbol, color, category, targetType, targetMinutes, notes, routineStack
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        completedDates = try container.decodeIfPresent(Set<DateComponents>.self, forKey: .completedDates) ?? []
        startDate = try container.decodeIfPresent(Date.self, forKey: .startDate) ?? Date()
        isHabitCompleted = try container.decodeIfPresent(Bool.self, forKey: .isHabitCompleted) ?? false
        completedDate = try container.decodeIfPresent(Date?.self, forKey: .completedDate) ?? nil
        reminderFrequency = try container.decodeIfPresent(ReminderFrequency?.self, forKey: .reminderFrequency) ?? nil
        symbol = try container.decodeIfPresent(String.self, forKey: .symbol) ?? HabitSymbols.default
        lastUpdated = Date()
        color = try container.decodeIfPresent(Color.self, forKey: .color) ?? ColorOptions.default
        category = try container.decodeIfPresent(HabitCategory.self, forKey: .category) ?? .general
        targetType = try container.decodeIfPresent(HabitTargetType.self, forKey: .targetType) ?? .checkmark
        targetMinutes = try container.decodeIfPresent(Int.self, forKey: .targetMinutes) ?? 15
        notes = try container.decodeIfPresent([HabitNote].self, forKey: .notes) ?? []
        routineStack = try container.decodeIfPresent(String?.self, forKey: .routineStack) ?? nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(completedDates, forKey: .completedDates)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(isHabitCompleted, forKey: .isHabitCompleted)
        try container.encode(completedDate, forKey: .completedDate)
        try container.encode(lastUpdated, forKey: .lastUpdated)
        try container.encode(reminderFrequency, forKey: .reminderFrequency)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(color, forKey: .color)
        try container.encode(category, forKey: .category)
        try container.encode(targetType, forKey: .targetType)
        try container.encode(targetMinutes, forKey: .targetMinutes)
        try container.encode(notes, forKey: .notes)
        try container.encode(routineStack, forKey: .routineStack)
    }
    
    func completedDatesSet() -> Set<Date> {
        var dates = Set<Date>()
        for dateComponent in completedDates {
            if let date = Calendar.current.date(from: dateComponent) {
                dates.insert(date)
            }
        }
        return dates
    }
    
    func isCompleted(on date: Date) -> Bool {
        let noTimeDate = date.startOfDay
        let completedDates = completedDatesSet()
        return completedDates.contains(noTimeDate)
    }
    
    func calculateStreak(from: Date = Date()) -> Int {
        var streak = 0
        var date = from.startOfDay
        while isCompleted(on: date) {
            streak += 1
            guard let previous = Calendar.current.date(byAdding: .day, value: -1, to: date) else { break }
            date = previous
        }
        return streak
    }
    
    func clearCompletedDates() {
        var datesToRemove = [DateComponents]()
        for dateComponent in completedDates {
            if let date = Calendar.current.date(from: dateComponent) {
                if date < startDate.startOfDay {
                    datesToRemove.append(dateComponent)
                }
            }
        }
        for dateComponent in datesToRemove {
            completedDates.remove(dateComponent)
        }
    }
    
    func calculateTotalCompleted() -> Int {
        return completedDates.count
    }
    
    func calculateLongestStreak() -> Int {
        var longestStreak = 0
        var date = Date().startOfDay
        while date >= startDate.startOfDay {
            if isCompleted(on: date) {
                let streak = calculateStreak(from: date)
                if streak > longestStreak {
                    longestStreak = streak
                }
                guard let jumpedDate = Calendar.current.date(byAdding: .day, value: -max(1, streak), to: date) else { break }
                date = jumpedDate
            } else {
                guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: date) else { break }
                date = prev
            }
        }
        return longestStreak
    }
    
    // Consider from start date only, min(n, today - startDate)
    func lastNdayCells(n: Int) -> [Int] {
        var cells = [Int]()
        var date = Date()
        var i = 0
        while i < n && date >= startDate.startOfDay {
            if isCompleted(on: date) {
                cells.append(1)
            } else {
                cells.append(0)
            }
            guard let previous = Calendar.current.date(byAdding: .day, value: -1, to: date) else { break }
            date = previous
            i += 1
        }
        return cells.reversed()
    }
    
    // Last 30 days grid data: returns array of (Date, Bool)
    func last30DaysStatus() -> [(date: Date, isCompleted: Bool)] {
        var result: [(Date, Bool)] = []
        let calendar = Calendar.current
        let today = Date().startOfDay
        for offset in (0..<30).reversed() {
            if let d = calendar.date(byAdding: .day, value: -offset, to: today) {
                result.append((d, isCompleted(on: d)))
            }
        }
        return result
    }
    
    // Consistency Score (0% - 100%) in the last 30 days
    var consistencyScore: Int {
        let cells = lastNdayCells(n: 30)
        guard !cells.isEmpty else { return 0 }
        let completed = cells.filter { $0 == 1 }.count
        return Int((Double(completed) / Double(cells.count)) * 100)
    }
    
    // Habit Strength Index (0 - 100) with recency weighting
    var habitStrength: Int {
        let cells = lastNdayCells(n: 30)
        guard !cells.isEmpty else { return 0 }
        var weightedSum = 0.0
        var totalWeight = 0.0
        for (index, val) in cells.enumerated() {
            let weight = 1.0 + (Double(index) / Double(cells.count)) * 2.0 // More recent days carry higher weight
            weightedSum += Double(val) * weight
            totalWeight += weight
        }
        guard totalWeight > 0 else { return 0 }
        let rawScore = Int((weightedSum / totalWeight) * 100)
        return min(100, max(0, rawScore))
    }
    
    // Total XP contributed by this habit
    var xpEarned: Int {
        let baseXP = calculateTotalCompleted() * 50
        let streakBonus = (calculateLongestStreak() / 7) * 100
        return baseXP + streakBonus
    }
    
    func markDateCompleted(date: Date) {
        let noTimeDate = date.startOfDay
        if isCompleted(on: noTimeDate) {
            return
        }
        lastUpdated = Date()
        completedDates.insert(Calendar.current.dateComponents([.year, .month, .day], from: noTimeDate))
    }
    
    func toggleCompletion() {
        isHabitCompleted.toggle()
        lastUpdated = Date()
        if isHabitCompleted {
            completedDate = Date()
            markDateCompleted(date: Date())
        } else {
            completedDate = nil
            // remove today from completedDates
            let todayComp = Calendar.current.dateComponents([.year, .month, .day], from: Date().startOfDay)
            completedDates.remove(todayComp)
        }
    }
    
    func addNote(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let newNote = HabitNote(text: text)
        notes.insert(newNote, at: 0)
        lastUpdated = Date()
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}

extension UserDefaults {
    private static let habitsKey = "habits"
    private static let lastReviewRequestDateKey = "lastReviewRequestDate"
    
    func saveHabits(_ habits: [Habit]) {
        if let encodedData = try? JSONEncoder().encode(habits) {
            set(encodedData, forKey: UserDefaults.habitsKey)
        }
    }
    
    func loadHabits() -> [Habit] {
        if let data = data(forKey: UserDefaults.habitsKey) {
            if let decodedHabits = try? JSONDecoder().decode([Habit].self, from: data) {
                return decodedHabits
            }
        }
        return []
    }
    
    func saveLastReviewRequestDate(_ date: Date) {
        set(date, forKey: UserDefaults.lastReviewRequestDateKey)
    }
    
    func loadLastReviewRequestDate() -> Date? {
        return object(forKey: UserDefaults.lastReviewRequestDateKey) as? Date
    }
}
