//
//  HabitDetailView.swift
//  HabitHub
//

import SwiftUI
import StoreKit

struct HabitDetailView: View {
    @AppStorage("lastRequestDateEpoch") var lastRequestDateEpoch: Double = 0
    @AppStorage("daysToWait") var daysToWait: Int = 7
    
    @EnvironmentObject var habit: Habit
    @EnvironmentObject var habitStore: HabitStore
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.requestReview) var requestReview
    
    @State private var isEditing: Bool = false
    @State private var today: Date = Date().startOfDay.addingTimeInterval(86399)
    @State private var newNoteText: String = ""
    @State private var showFocusTimerSheet: Bool = false
    
    func requestReviewIfAppropriate(userStreak: Int) {
        if userStreak > 0 && (userStreak % 7 == 0) {
            let daysSinceLastRequest = (Date().timeIntervalSince1970 - Double(lastRequestDateEpoch)) / 86400
            if daysSinceLastRequest >= Double(daysToWait) {
                requestReview()
                lastRequestDateEpoch = Date().timeIntervalSince1970
                daysToWait += 7
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Interactive 3D Streak Orb Hero
                ThreeDStreakOrbView(
                    streakCount: habit.calculateStreak(),
                    longestStreak: habit.calculateLongestStreak(),
                    primaryColor: habit.color,
                    symbol: habit.symbol
                )
                .padding(.top, 10)
                
                // Metadata & Category Pill
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: habit.category.icon)
                        Text(habit.category.rawValue)
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(habit.category.gradientColors.first ?? .blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(habit.category.gradientColors.first?.opacity(0.15) ?? Color.blue.opacity(0.15)))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        Text(habit.startDate, style: .date)
                    }
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "alarm")
                        Text(habit.startDate, style: .time)
                    }
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                }
                
                // Launch Focus Session Button
                Button(action: {
                    showFocusTimerSheet = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "timer")
                            .font(.system(size: 16, weight: .bold))
                        Text("Start Focus Session")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        LinearGradient(
                            colors: [habit.color, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: habit.color.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                
                // 3D Flippable Number Cards
                VStack(spacing: 12) {
                    NumberCard(
                        number: habit.calculateTotalCompleted(),
                        text: "Total Check-ins",
                        fillColor: .gray.opacity(0.1),
                        iconColor: .green,
                        icon: "checkmark.circle.fill",
                        subtitle: "Tap to flip for XP",
                        backTitle: "Total XP Earned",
                        backValue: "\(habit.xpEarned) XP",
                        backDescription: "Earned from completions & streak milestones"
                    )
                    
                    HStack(spacing: 12) {
                        NumberCard(
                            number: habit.calculateStreak(),
                            text: "Streak",
                            fillColor: .gray.opacity(0.1),
                            iconColor: .orange,
                            icon: "flame.fill",
                            subtitle: "Tap for score",
                            backTitle: "Consistency",
                            backValue: "\(habit.consistencyScore)%",
                            backDescription: "Last 30-day completion rate"
                        )
                        
                        NumberCard(
                            number: habit.calculateLongestStreak(),
                            text: "Max Streak",
                            fillColor: .gray.opacity(0.1),
                            iconColor: .pink,
                            icon: "trophy.fill",
                            subtitle: "Tap for strength",
                            backTitle: "Habit Strength",
                            backValue: "\(habit.habitStrength)%",
                            backDescription: "Recency-weighted index"
                        )
                    }
                }
                .padding(.horizontal)
                
                // Calendar MultiDatePicker Card
                VStack(alignment: .leading, spacing: 10) {
                    Text("Completion History")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    MultiDatePicker("Select Dates", selection: $habit.completedDates, in: habit.startDate.startOfDay..<today)
                        .datePickerStyle(.graphical)
                        .tint(habit.color)
                        .onChange(of: habit.completedDates) { _ in
                            habitStore.updateHabit(habit)
                            if habit.calculateStreak() > 0 {
                                requestReviewIfAppropriate(userStreak: habit.calculateStreak())
                            }
                        }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .threeDCardEffect(maxTilt: 8, isInteractive: true, cornerRadius: 18)
                .padding(.horizontal)
                
                // Daily Reflection Notes Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "note.text")
                            .foregroundColor(habit.color)
                        Text("Reflection & Notes")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Spacer()
                    }
                    
                    // Add Note Input
                    HStack {
                        TextField("Add a thought or reflection...", text: $newNoteText)
                            .font(.system(size: 14, design: .rounded))
                        
                        Button(action: {
                            habit.addNote(newNoteText)
                            newNoteText = ""
                            habitStore.updateHabit(habit)
                            SoundHapticManager.shared.lightImpact()
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(newNoteText.isEmpty ? .gray : habit.color)
                        }
                        .disabled(newNoteText.isEmpty)
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    
                    // Notes Timeline
                    if habit.notes.isEmpty {
                        Text("No reflections logged yet. Jot down how you felt today!")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 6)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(habit.notes) { note in
                                HStack(alignment: .top, spacing: 10) {
                                    Circle()
                                        .fill(habit.color)
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 6)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(note.text)
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundColor(.primary)
                                        Text(note.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.system(size: 10, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(10)
                                .background(Color(.systemGray6).opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .threeDCardEffect(maxTilt: 8, isInteractive: true, cornerRadius: 18)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle(habit.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            AddHabit(isEditing: true) {
                habitStore.updateHabit(habit)
            }
            .environmentObject(habit)
        }
        .sheet(isPresented: $showFocusTimerSheet) {
            FocusTimerView()
                .environmentObject(habitStore)
        }
        .onAppear {
            today = Date().startOfDay.addingTimeInterval(86399)
        }
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
}()
