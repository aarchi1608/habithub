//
//  ContentView.swift
//  HabitTracker
//

import SwiftUI
import StoreKit

struct CurrentHabitsView: View {
    @EnvironmentObject var habitStore: HabitStore
    @State private var today = Date()
    private let timer = Timer.publish(every: 60 * 60 * 3, on: .main, in: .common).autoconnect()
    
    private var uncompletedHabits: [Habit] {
        habitStore.habits.filter { !$0.isHabitCompleted }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            }
        }
    }
    
    func registerNotificationCategory() {
        let habitCategory = UNNotificationCategory(identifier: "HABIT_REMINDER", actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([habitCategory])
    }
    
    var body: some View {
        HabitListView(habits: uncompletedHabits, isCompleted: false)
            .environmentObject(habitStore)
            .navigationTitle("HabitHub")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    if settings.authorizationStatus != .authorized {
                        requestNotificationPermission()
                        registerNotificationCategory()
                    }
                }
                today = Date()
            }
            .onReceive(timer) { _ in
                today = Date()
            }
    }
}

struct CompletedHabitsView: View {
    @EnvironmentObject var habitStore: HabitStore
    
    private var completedHabits: [Habit] {
        habitStore.habits.filter { $0.isHabitCompleted }
    }
    
    var body: some View {
        HabitListView(habits: completedHabits, isCompleted: true)
            .environmentObject(habitStore)
            .navigationTitle("Completed")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct HabitsMasterView: View {
    @EnvironmentObject var habitStore: HabitStore
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedSegment: Int = 0
    @State private var showingThemeSheet: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segmented View Mode
                Picker("View Mode", selection: $selectedSegment) {
                    Text("Today (\(habitStore.habits.filter { !$0.isHabitCompleted }.count))").tag(0)
                    Text("Completed (\(habitStore.habits.filter { $0.isHabitCompleted }.count))").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 4)
                
                if selectedSegment == 0 {
                    CurrentHabitsView()
                } else {
                    CompletedHabitsView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Theme Switcher Menu
                    Menu {
                        Section(header: Text("Choose Visual Theme")) {
                            ForEach(AppTheme.allCases) { theme in
                                Button {
                                    themeManager.currentTheme = theme
                                    SoundHapticManager.shared.lightImpact()
                                } label: {
                                    HStack {
                                        Text(theme.rawValue)
                                        if themeManager.currentTheme == theme {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(LinearGradient(colors: themeManager.currentTheme.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 14, height: 14)
                                .shadow(color: themeManager.currentTheme.primaryAccent.opacity(0.6), radius: 4)
                            Image(systemName: "paintpalette.fill")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.currentTheme.primaryAccent)
                        }
                        .padding(6)
                        .background(Capsule().fill(Color(.systemGray6)))
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var habitStore: HabitStore
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        ZStack {
            TabView {
                HabitsMasterView()
                    .tabItem {
                        Label("Habits", systemImage: "checklist")
                    }
                
                FocusTimerView()
                    .tabItem {
                        Label("Focus", systemImage: "timer")
                    }
                
                InsightsView()
                    .tabItem {
                        Label("Insights", systemImage: "chart.xyaxis.line")
                    }
                
                BadgeShowcaseView()
                    .tabItem {
                        Label("Trophies", systemImage: "trophy.fill")
                    }
            }
            .accentColor(themeManager.currentTheme.primaryAccent)
            
            // Global 3D Confetti Burst Overlay
            ConfettiBurstView(trigger: $habitStore.celebrationTrigger)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HabitStore())
    }
}
