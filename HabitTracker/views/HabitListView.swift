//
//  HabitListView.swift
//  HabitTracker
//
//  Created by Saikat Kumar Dey on 09/07/23.
//

import SwiftUI

struct HabitListView: View {
    @EnvironmentObject var habitStore: HabitStore
    @State private var selectedHabit: Habit?
    @State private var showingAddHabitSheet = false
    @State private var newHabit: Habit = Habit()
    @State private var showDeleteConfirmationAlert = false
    @State private var sortOrder = SortOrder.startDate
    @State private var selectedCategoryFilter: HabitCategory? = nil
    @State private var searchKeyword: String = ""
    @State private var selectedRoutineForFlow: String? = nil
    @State private var showShieldAlert: Bool = false
    
    enum SortOrder {
        case startDate, totalCompleted, longestStreak, currentStreak, reminderTime
    }
    
    var habits: [Habit]
    let isCompleted: Bool
    
    var filteredHabits: [Habit] {
        var list = habits
        if let cat = selectedCategoryFilter {
            list = list.filter { $0.category == cat }
        }
        if !searchKeyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            list = list.filter { $0.title.localizedCaseInsensitiveContains(searchKeyword) }
        }
        return list
    }
    
    var sortedHabits: [Habit] {
        switch sortOrder {
        case .startDate:
            return filteredHabits.sorted { $0.startDate.startOfDay < $1.startDate.startOfDay }
        case .reminderTime:
            return filteredHabits.sorted {
                let firstTime = Calendar.current.dateComponents([.hour, .minute], from: $0.startDate)
                let secondTime = Calendar.current.dateComponents([.hour, .minute], from: $1.startDate)
                let firstInSec = (firstTime.hour ?? 0) * 3600 + (firstTime.minute ?? 0) * 60
                let secondInSec = (secondTime.hour ?? 0) * 3600 + (secondTime.minute ?? 0) * 60
                return firstInSec < secondInSec
            }
        case .totalCompleted:
            return filteredHabits.sorted { $0.calculateTotalCompleted() > $1.calculateTotalCompleted() }
        case .longestStreak:
            return filteredHabits.sorted { $0.calculateLongestStreak() > $1.calculateLongestStreak() }
        case .currentStreak:
            return filteredHabits.sorted { $0.calculateStreak() > $1.calculateStreak() }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Filter Pills & Routine Stacks
            VStack(spacing: 10) {
                // Category Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button(action: {
                            selectedCategoryFilter = nil
                            SoundHapticManager.shared.lightImpact()
                        }) {
                            Text("All")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(selectedCategoryFilter == nil ? Color.primary : Color(.systemGray6))
                                )
                                .foregroundColor(selectedCategoryFilter == nil ? Color(.systemBackground) : .primary)
                        }
                        
                        ForEach(HabitCategory.allCases) { cat in
                            Button(action: {
                                selectedCategoryFilter = (selectedCategoryFilter == cat) ? nil : cat
                                SoundHapticManager.shared.lightImpact()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: cat.icon)
                                        .font(.system(size: 10))
                                    Text(cat.rawValue)
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(selectedCategoryFilter == cat ? (cat.gradientColors.first ?? .blue) : Color(.systemGray6))
                                )
                                .foregroundColor(selectedCategoryFilter == cat ? .white : .primary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 8)
                
                // Routine Stack Flow Quick-Launch Pills (Only in Active view)
                if !isCompleted {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(habitStore.defaultRoutineStacks, id: \.self) { stack in
                                Button(action: {
                                    selectedRoutineForFlow = stack
                                    SoundHapticManager.shared.lightImpact()
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "play.fill")
                                            .font(.system(size: 9))
                                        Text(stack)
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Capsule().fill(Color.purple.opacity(0.15)))
                                    .foregroundColor(.purple)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Sort by Selector & Streak Shield Status
                HStack {
                    Text("\(sortedHabits.count) \(isCompleted ? "completed" : "active") habits")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Streak Shield Pill
                    Button(action: {
                        showShieldAlert = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "shield.fill")
                                .font(.system(size: 10))
                            Text("\(habitStore.streakShieldsCount) Shields")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.cyan.opacity(0.15)))
                        .foregroundColor(.cyan)
                    }
                    
                    Picker("Sort by", selection: $sortOrder) {
                        Text("Start Date").tag(SortOrder.startDate)
                        Text("Reminder Time").tag(SortOrder.reminderTime)
                        Text("Completed Days").tag(SortOrder.totalCompleted)
                        Text("Longest Streak").tag(SortOrder.longestStreak)
                        Text("Current Streak").tag(SortOrder.currentStreak)
                    }
                    .pickerStyle(.menu)
                    .font(.caption.bold())
                }
                .padding(.horizontal)
            }
            
            if habits.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: isCompleted ? "checkmark.circle.badge.questionmark" : "sparkles")
                        .font(.system(size: 54))
                        .foregroundColor(.secondary.opacity(0.6))
                    
                    Text(isCompleted ? "No habits completed yet." : "Build your first great habit!")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    if !isCompleted {
                        Button(action: {
                            self.showingAddHabitSheet = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 18))
                                Text("Add a Habit")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                                    .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 5)
                            )
                        }
                    }
                    Spacer()
                }
                .padding()
            } else {
                List {
                    // Mood Tracker & Power Score Header Section (Only in Active view)
                    if !isCompleted {
                        Section {
                            // Mood & Energy Tracker Card
                            MoodTrackerCardView()
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            
                            // Daily Power Score & Wisdom Card
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    HStack(spacing: 6) {
                                        Image(systemName: "bolt.fill")
                                            .foregroundColor(.yellow)
                                        Text("DAILY POWER SCORE")
                                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                                            .foregroundColor(.white.opacity(0.8))
                                            .tracking(1.2)
                                    }
                                    Spacer()
                                    Text("\(habitStore.dailyPowerScore)%")
                                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(height: 6)
                                        Capsule()
                                            .fill(Color.white)
                                            .frame(width: max(6, geo.size.width * CGFloat(habitStore.dailyPowerScore) / 100.0), height: 6)
                                    }
                                }
                                .frame(height: 6)
                                
                                Text("\"\(habitStore.dailyMotivationQuote.quote)\"")
                                    .font(.system(size: 12, weight: .medium, design: .serif))
                                    .foregroundColor(.white.opacity(0.95))
                                    .italic()
                                
                                Text("— \(habitStore.dailyMotivationQuote.author)")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.75))
                            }
                            .padding(16)
                            .background(
                                LinearGradient(
                                    colors: [Color.indigo, Color.purple, Color.blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .threeDCardEffect(maxTilt: 10, isInteractive: true, cornerRadius: 18)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    
                    // Habits List Items
                    Section {
                        ForEach(sortedHabits, id: \.id) { habit in
                            NavigationLink(
                                destination: HabitDetailView()
                                    .environmentObject(habit)
                                    .environmentObject(habitStore)
                            ) {
                                HabitRow(habit: habit)
                                    .environmentObject(habitStore)
                            }
                            .padding(.vertical, 4)
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(.secondarySystemGroupedBackground))
                                    .padding(.vertical, 4)
                            )
                            .listRowSeparator(.hidden)
                            .threeDCardEffect(maxTilt: 8, isInteractive: false, cornerRadius: 16)
                            .swipeActions(edge: .leading) {
                                Button {
                                    habitStore.toggleHabitQuick(habit)
                                } label: {
                                    Label(
                                        habit.isHabitCompleted ? "Unmark" : "Complete",
                                        systemImage: habit.isHabitCompleted ? "arrow.uturn.backward" : "checkmark"
                                    )
                                }
                                .tint(habit.isHabitCompleted ? .gray : .green)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    selectedHabit = habit
                                    self.showDeleteConfirmationAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $searchKeyword, prompt: "Search habits...")
        .alert(isPresented: $showDeleteConfirmationAlert) {
            Alert(
                title: Text("Delete Habit"),
                message: Text("Are you sure you want to delete this habit?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let habit = selectedHabit {
                        habitStore.deleteHabit(habit)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .alert("Streak Freeze Shield 🛡️", isPresented: $showShieldAlert) {
            Button("Protect Streak Now") {
                if habitStore.useStreakShield() {
                    SoundHapticManager.shared.celebrationFeedback()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You have \(habitStore.streakShieldsCount) shields remaining. Shields prevent streak resets if you miss completing a habit.")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.showingAddHabitSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)))
                }
            }
        }
        .sheet(isPresented: $showingAddHabitSheet) {
            AddHabit {
                addHabit()
            }
            .environmentObject(newHabit)
        }
        .sheet(item: Binding(
            get: { selectedRoutineForFlow.map { IdentifiableString(id: $0) } },
            set: { selectedRoutineForFlow = $0?.id }
        )) { item in
            RoutineStackFlowView(stackName: item.id)
                .environmentObject(habitStore)
        }
    }
    
    private func addHabit() {
        habitStore.addHabit(newHabit)
        newHabit = Habit()
    }
}

struct IdentifiableString: Identifiable {
    let id: String
}

struct HabitListView_Previews: PreviewProvider {
    static var previews: some View {
        HabitListView(habits: HabitStore().habits, isCompleted: false)
            .environmentObject(HabitStore())
    }
}
