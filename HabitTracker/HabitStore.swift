//
//  HabitStore.swift
//  HabitTracker
//
//  Created by Saikat Kumar Dey on 08/07/23.
//

import SwiftUI
import Foundation

struct HabitBadge: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var icon: String
    var colorHex: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    var requirementText: String
}

struct HabitMoodEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var emoji: String
    var label: String
    var energyLevel: Int // 1 to 5
}

class HabitStore: ObservableObject {
    
    private let accessQueue = DispatchQueue(label: "com.saikatkumardey.habittracker.habitstore")
    private let moodStorageKey = "habit_mood_entries"
    private let shieldStorageKey = "habit_streak_shields"
    
    @Published private(set) var habits: [Habit] {
        didSet {
            saveHabits()
        }
    }
    
    @Published var habitsChanged = false {
        didSet {
            habitsChanged = false
        }
    }
    
    @Published var selectedCategory: HabitCategory? = nil
    @Published var selectedRoutineStack: String? = nil
    @Published var searchText: String = ""
    @Published var celebrationTrigger: Int = 0
    @Published var moodEntries: [HabitMoodEntry] = [] {
        didSet {
            saveMoodEntries()
        }
    }
    @Published var streakShieldsCount: Int = 2 {
        didSet {
            UserDefaults.standard.set(streakShieldsCount, forKey: shieldStorageKey)
        }
    }
    
    init() {
        habits = UserDefaults.standard.loadHabits()
        streakShieldsCount = UserDefaults.standard.object(forKey: shieldStorageKey) as? Int ?? 2
        
        if let moodData = UserDefaults.standard.data(forKey: moodStorageKey),
           let decoded = try? JSONDecoder().decode([HabitMoodEntry].self, from: moodData) {
            moodEntries = decoded
        }
        print("HabitStore initialized with \(habits.count) habits.")
    }
    
    // MARK: - Routine Stacks
    
    let defaultRoutineStacks = [
        "🌅 Morning Ritual",
        "⚡ Deep Work",
        "🧘 Wellness & Mindfulness",
        "🌙 Evening Reset"
    ]
    
    func habitsForStack(_ stack: String) -> [Habit] {
        habits.filter { $0.routineStack == stack }
    }
    
    // MARK: - Daily Mood & Energy Tracking
    
    func logTodayMood(emoji: String, label: String, energy: Int) {
        let today = Date().startOfDay
        moodEntries.removeAll { Calendar.current.isDate($0.date, inSameDayAs: today) }
        let entry = HabitMoodEntry(date: Date(), emoji: emoji, label: label, energyLevel: energy)
        moodEntries.insert(entry, at: 0)
        SoundHapticManager.shared.successFeedback()
    }
    
    func todaysMood() -> HabitMoodEntry? {
        let today = Date().startOfDay
        return moodEntries.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    private func saveMoodEntries() {
        if let encoded = try? JSONEncoder().encode(moodEntries) {
            UserDefaults.standard.set(encoded, forKey: moodStorageKey)
        }
    }
    
    // MARK: - Streak Shields
    
    func useStreakShield() -> Bool {
        guard streakShieldsCount > 0 else { return false }
        streakShieldsCount -= 1
        SoundHapticManager.shared.celebrationFeedback()
        return true
    }
    
    func earnStreakShield() {
        streakShieldsCount += 1
        SoundHapticManager.shared.celebrationFeedback()
    }
    
    // MARK: - Gamification & XP System
    
    var totalXP: Int {
        habits.reduce(0) { $0 + $1.xpEarned }
    }
    
    var userLevel: Int {
        let level = Int(sqrt(Double(totalXP) / 75.0)) + 1
        return max(1, level)
    }
    
    var levelTitle: String {
        switch userLevel {
        case 1: return "Habit Novice"
        case 2: return "Habit Spark"
        case 3: return "Streak Builder"
        case 4: return "Consistency Knight"
        case 5: return "Discipline Master"
        case 6...8: return "Habit Grandmaster"
        default: return "Legend of Consistency"
        }
    }
    
    var xpForNextLevel: Int {
        let nextLevel = userLevel
        return (nextLevel * nextLevel) * 75
    }
    
    var currentLevelBaseXP: Int {
        let cur = userLevel - 1
        return (cur * cur) * 75
    }
    
    var levelProgress: Double {
        let base = currentLevelBaseXP
        let next = xpForNextLevel
        guard next > base else { return 1.0 }
        let progress = Double(totalXP - base) / Double(next - base)
        return min(1.0, max(0.0, progress))
    }
    
    // MARK: - Badges & Achievements
    
    var allBadges: [HabitBadge] {
        let totalCompleted = habits.reduce(0) { $0 + $1.calculateTotalCompleted() }
        let maxStreakAll = habits.map { $0.calculateLongestStreak() }.max() ?? 0
        let currentStreakAll = habits.map { $0.calculateStreak() }.max() ?? 0
        let uniqueCategories = Set(habits.map { $0.category }).count
        let perfectToday = !habits.isEmpty && habits.allSatisfy { $0.isHabitCompleted }
        
        return [
            HabitBadge(
                id: "first_step",
                title: "First Step",
                description: "Completed your very first habit!",
                icon: "shoe.fill",
                colorHex: "#34C759",
                isUnlocked: totalCompleted >= 1,
                unlockedDate: totalCompleted >= 1 ? Date() : nil,
                requirementText: "Complete 1 habit"
            ),
            HabitBadge(
                id: "7_day_ignition",
                title: "7-Day Ignition",
                description: "Reached a 7-day streak on any habit.",
                icon: "flame.fill",
                colorHex: "#FF3B30",
                isUnlocked: maxStreakAll >= 7 || currentStreakAll >= 7,
                unlockedDate: (maxStreakAll >= 7 || currentStreakAll >= 7) ? Date() : nil,
                requirementText: "Achieve a 7-day streak"
            ),
            HabitBadge(
                id: "30_day_titan",
                title: "30-Day Titan",
                description: "Built an unshakeable 30-day streak.",
                icon: "crown.fill",
                colorHex: "#FF9500",
                isUnlocked: maxStreakAll >= 30 || currentStreakAll >= 30,
                unlockedDate: (maxStreakAll >= 30 || currentStreakAll >= 30) ? Date() : nil,
                requirementText: "Achieve a 30-day streak"
            ),
            HabitBadge(
                id: "century_club",
                title: "Century Club",
                description: "Completed 100 total habit check-ins!",
                icon: "sparkles",
                colorHex: "#AF52DE",
                isUnlocked: totalCompleted >= 100,
                unlockedDate: totalCompleted >= 100 ? Date() : nil,
                requirementText: "Reach 100 total check-ins"
            ),
            HabitBadge(
                id: "multi_pillar",
                title: "Pillar Master",
                description: "Balancing habits across 3+ categories.",
                icon: "square.grid.2x2.fill",
                colorHex: "#007AFF",
                isUnlocked: uniqueCategories >= 3,
                unlockedDate: uniqueCategories >= 3 ? Date() : nil,
                requirementText: "Track 3+ habit categories"
            ),
            HabitBadge(
                id: "perfect_day",
                title: "Perfectionist",
                description: "Completed 100% of all habits today!",
                icon: "checkmark.seal.fill",
                colorHex: "#5856D6",
                isUnlocked: perfectToday,
                unlockedDate: perfectToday ? Date() : nil,
                requirementText: "Complete all active habits in a single day"
            )
        ]
    }
    
    // MARK: - Daily Power Score & Stats
    
    var dailyPowerScore: Int {
        guard !habits.isEmpty else { return 0 }
        let completedToday = habits.filter { $0.isHabitCompleted }.count
        return Int((Double(completedToday) / Double(habits.count)) * 100)
    }
    
    var dailyMotivationQuote: (quote: String, author: String) {
        let quotes: [(String, String)] = [
            ("We are what we repeatedly do. Excellence, then, is not an act, but a habit.", "Aristotle"),
            ("Small disciplines repeated with consistency every day lead to great achievements.", "John C. Maxwell"),
            ("You do not rise to the level of your goals. You fall to the level of your systems.", "James Clear"),
            ("Success is the sum of small efforts, repeated day in and day out.", "Robert Collier"),
            ("Motivation is what gets you started. Habit is what keeps you going.", "Jim Ryun"),
            ("Your habits shape your identity, and your identity shapes your habits.", "Atomic Habits"),
            ("The secret of getting ahead is getting started.", "Mark Twain"),
            ("Champions keep playing until they get it right.", "Billie Jean King")
        ]
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return quotes[dayOfYear % quotes.count]
    }
    
    // MARK: - Habit Mutations & Scheduling
    
    func addHabit(_ habit: Habit) {
        accessQueue.sync {
            habits.append(habit)
        }
        scheduleNotification(for: habit, at: habit.startDate)
        SoundHapticManager.shared.successFeedback()
        print("added habit \(habit.title), id \(habit.id.uuidString)")
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            print("updating habit \(habit.title), id \(habit.id.uuidString)")
            cancelNotification(for: habits[index])
            scheduleNotification(for: habit, at: habit.startDate)
            habits[index] = habit
            saveHabits()
        }
    }
    
    func toggleHabitQuick(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].toggleCompletion()
            if habits[index].isHabitCompleted {
                SoundHapticManager.shared.celebrationFeedback()
                celebrationTrigger += 1
            } else {
                SoundHapticManager.shared.lightImpact()
            }
            saveHabits()
        }
    }
    
    func getHabit(by id: UUID) -> Habit? {
        accessQueue.sync {
            for habit in habits {
                if habit.id == id {
                    return habit
                }
            }
            return nil
        }
    }
    
    func markHabitAsCompleted(_ habit: Habit) {
        habit.isHabitCompleted = true
        habit.completedDate = Date()
        habit.markDateCompleted(date: Date())
        SoundHapticManager.shared.celebrationFeedback()
        celebrationTrigger += 1
        updateHabit(habit)
    }
    
    func markHabitAsNotCompleted(_ habit: Habit) {
        habit.isHabitCompleted = false
        habit.completedDate = nil
        let todayComp = Calendar.current.dateComponents([.year, .month, .day], from: Date().startOfDay)
        habit.completedDates.remove(todayComp)
        SoundHapticManager.shared.lightImpact()
        updateHabit(habit)
    }
    
    func markDayAsCompleted(_ habit: Habit, date: Date) {
        habit.markDateCompleted(date: date)
        updateHabit(habit)
    }
    
    func saveHabits() {
        UserDefaults.standard.saveHabits(habits)
    }
    
    func deleteHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            cancelNotification(for: habits[index])
            habits.remove(at: index)
            SoundHapticManager.shared.mediumImpact()
        }
    }
    
    func scheduleNotification(for habit: Habit, at date: Date) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            if requests.contains(where: { $0.identifier == habit.id.uuidString }) {
                return
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Time for your habit!"
        content.body = "Keep your streak going: \(habit.title)"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "HABIT_REMINDER"
        content.userInfo = ["habitId": habit.id.uuidString]
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelNotification(for habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
    }
    
    // MARK: - Export Data
    
    func exportDataJSON() -> String? {
        if let data = try? JSONEncoder().encode(habits),
           let jsonStr = String(data: data, encoding: .utf8) {
            return jsonStr
        }
        return nil
    }
}
