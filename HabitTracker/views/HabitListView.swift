//
//  HabitListView.swift
//  HabitHub
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
    @State private var showReflectionSheet: Bool = false
    
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
    
    private var maxCurrentStreak: Int {
        habitStore.habits.map { $0.calculateStreak() }.max() ?? 0
    }
    
    var body: some View {
        ZStack {
            NoorBackgroundView()
            
            ScrollView {
                VStack(spacing: 20) {
                    if !isCompleted {
                        // MARK: - 1. Noor Emerald Streak Ring Hero Card
                        HStack(spacing: 20) {
                            // Circular Streak Ring
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.15), lineWidth: 8)
                                    .frame(width: 100, height: 100)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(min(1.0, Double(maxCurrentStreak) / 7.0)))
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(hex: "#D4A359"), Color(hex: "#FCE7C8"), Color(hex: "#D4A359")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                    )
                                    .frame(width: 100, height: 100)
                                    .rotationEffect(.degrees(-90))
                                    .shadow(color: Color(hex: "#D4A359").opacity(0.6), radius: 8)
                                
                                VStack(spacing: 2) {
                                    Text("\(maxCurrentStreak)")
                                        .font(.system(size: 32, weight: .bold, design: .serif))
                                        .foregroundColor(Color(hex: "#FBF8F3"))
                                    
                                    Text("Day Streak")
                                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "#D4A359"))
                                }
                            }
                            .padding(.leading, 8)
                            
                            // Streak Motivation Text
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Consistency Journey")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#D4A359"))
                                    .textCase(.uppercase)
                                    .tracking(1.0)
                                
                                Text("\(habitStore.habits.filter { $0.isHabitCompleted }.count) of \(habitStore.habits.count) Completed")
                                    .font(.system(size: 18, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                                
                                Text("Keep your unshakeable habit streak flourishing today.")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundColor(Color.white.opacity(0.8))
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                        }
                        .padding(18)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#1B3B30"), Color(hex: "#244E3F"), Color(hex: "#1A382E")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color(hex: "#D4A359").opacity(0.4), lineWidth: 1.2)
                        )
                        .shadow(color: Color(hex: "#1B3B30").opacity(0.25), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        // MARK: - 2. Noor "Today's Ayah / Wisdom" Reflection Card
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(Color(hex: "#D4A359"))
                                    Text("Today's Wisdom")
                                        .font(.system(size: 12, weight: .bold, design: .serif))
                                        .foregroundColor(Color(hex: "#D4A359"))
                                }
                                Spacer()
                                Button {
                                    showReflectionSheet = true
                                    SoundHapticManager.shared.lightImpact()
                                } label: {
                                    Text("Reflect")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "#244E3F"))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(Color(hex: "#D4A359")))
                                }
                            }
                            
                            Text("\"\(habitStore.dailyMotivationQuote.quote)\"")
                                .font(.system(size: 15, weight: .medium, design: .serif))
                                .foregroundColor(Color(hex: "#FBF8F3"))
                                .lineSpacing(3)
                            
                            Text("— \(habitStore.dailyMotivationQuote.author)")
                                .font(.system(size: 11, weight: .semibold, design: .serif))
                                .foregroundColor(Color(hex: "#D4A359").opacity(0.9))
                        }
                        .padding(16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#224A3C"), Color(hex: "#2A5949")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color(hex: "#D4A359").opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
                        .padding(.horizontal)
                        
                        // MARK: - 3. Quick Access 4-Grid Cards
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Quick Access")
                                .font(.system(size: 16, weight: .bold, design: .serif))
                                .foregroundColor(Color(hex: "#2B2420"))
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                                quickAccessCard(icon: "sun.max.fill", title: "Mindset", color: Color(hex: "#D4A359")) {
                                    selectedCategoryFilter = .mindset
                                }
                                quickAccessCard(icon: "leaf.fill", title: "Habits", color: Color(hex: "#244E3F")) {
                                    selectedCategoryFilter = nil
                                }
                                quickAccessCard(icon: "timer", title: "Focus", color: Color(hex: "#C79546")) {
                                    selectedCategoryFilter = .productivity
                                }
                                quickAccessCard(icon: "chart.bar.fill", title: "Insights", color: Color(hex: "#1E3F32")) {
                                    selectedCategoryFilter = .learning
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // MARK: - 4. Habit Section Header & Category Filters
                    VStack(spacing: 8) {
                        HStack {
                            Text(isCompleted ? "Completed Habits" : "Today's Habits")
                                .font(.system(size: 18, weight: .bold, design: .serif))
                                .foregroundColor(Color(hex: "#2B2420"))
                            
                            Spacer()
                            
                            // Shields Pill
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
                                .background(Capsule().fill(Color(hex: "#FBF3E6")))
                                .foregroundColor(Color(hex: "#C79546"))
                                .overlay(Capsule().stroke(Color(hex: "#E8D8C0"), lineWidth: 1))
                            }
                        }
                        .padding(.horizontal)
                        
                        // Category Pills
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                Button(action: {
                                    selectedCategoryFilter = nil
                                    SoundHapticManager.shared.lightImpact()
                                }) {
                                    Text("All")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(selectedCategoryFilter == nil ? Color(hex: "#244E3F") : Color(hex: "#FFFFFF"))
                                        )
                                        .foregroundColor(selectedCategoryFilter == nil ? .white : Color(hex: "#2B2420"))
                                        .overlay(
                                            Capsule().stroke(Color(hex: "#EBE1D3"), lineWidth: 1)
                                        )
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
                                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(selectedCategoryFilter == cat ? Color(hex: "#244E3F") : Color(hex: "#FFFFFF"))
                                        )
                                        .foregroundColor(selectedCategoryFilter == cat ? .white : Color(hex: "#2B2420"))
                                        .overlay(
                                            Capsule().stroke(Color(hex: "#EBE1D3"), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // MARK: - 5. Habits List Cards
                    if habits.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: isCompleted ? "checkmark.seal.fill" : "sparkles")
                                .font(.system(size: 48))
                                .foregroundColor(Color(hex: "#D4A359"))
                            
                            Text(isCompleted ? "No habits completed yet." : "Begin your consistency journey.")
                                .font(.system(size: 18, weight: .bold, design: .serif))
                                .foregroundColor(Color(hex: "#2B2420"))
                            
                            if !isCompleted {
                                Button(action: {
                                    self.showingAddHabitSheet = true
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add a Habit")
                                    }
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 22)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(Color(hex: "#244E3F"))
                                            .shadow(color: Color(hex: "#244E3F").opacity(0.3), radius: 8, x: 0, y: 4)
                                    )
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 40)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(sortedHabits, id: \.id) { habit in
                                NavigationLink(
                                    destination: HabitDetailView()
                                        .environmentObject(habit)
                                        .environmentObject(habitStore)
                                ) {
                                    HabitRow(habit: habit)
                                        .environmentObject(habitStore)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button {
                                        habitStore.toggleHabitQuick(habit)
                                    } label: {
                                        Label(
                                            habit.isHabitCompleted ? "Unmark" : "Complete",
                                            systemImage: habit.isHabitCompleted ? "arrow.uturn.backward" : "checkmark"
                                        )
                                    }
                                    
                                    Button(role: .destructive) {
                                        selectedHabit = habit
                                        self.showDeleteConfirmationAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 12)
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
        .sheet(isPresented: $showReflectionSheet) {
            VStack(spacing: 20) {
                Text("Daily Reflection")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(Color(hex: "#2B2420"))
                    .padding(.top, 20)
                
                Text("\"\(habitStore.dailyMotivationQuote.quote)\"")
                    .font(.system(size: 17, design: .serif))
                    .foregroundColor(Color(hex: "#2B2420"))
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("— \(habitStore.dailyMotivationQuote.author)")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundColor(Color(hex: "#D4A359"))
                
                Spacer()
                
                Button("Close") {
                    showReflectionSheet = false
                }
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(Capsule().fill(Color(hex: "#244E3F")))
                .padding(.bottom, 20)
            }
            .presentationDetents([.medium])
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
                        .background(Circle().fill(Color(hex: "#244E3F")))
                }
            }
        }
        .sheet(isPresented: $showingAddHabitSheet) {
            AddHabit {
                addHabit()
            }
            .environmentObject(newHabit)
        }
    }
    
    private func quickAccessCard(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            SoundHapticManager.shared.lightImpact()
            action()
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .serif))
                    .foregroundColor(Color(hex: "#2B2420"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .noorCard(cornerRadius: 14)
        }
        .buttonStyle(.plain)
    }
    
    private func addHabit() {
        habitStore.addHabit(newHabit)
        newHabit = Habit()
    }
}

struct HabitListView_Previews: PreviewProvider {
    static var previews: some View {
        HabitListView(habits: HabitStore().habits, isCompleted: false)
            .environmentObject(HabitStore())
    }
}
