//
//  DashboardView.swift
//  HabitHub
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var habitStore: HabitStore
    @StateObject private var soundManager = AmbientSoundManager.shared
    @State private var searchInput = ""
    @State private var showingRoutineFlow = false
    @State private var selectedTabDestination: Int = 1
    
    // Day of week abbreviations
    private let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    private var completedTodayCount: Int {
        habitStore.habits.filter { $0.isHabitCompleted }.count
    }
    
    private var totalHabitsCount: Int {
        max(1, habitStore.habits.count)
    }
    
    private var maxStreak: Int {
        habitStore.habits.map { $0.calculateStreak() }.max() ?? 0
    }
    
    private var totalFocusMinutes: Int {
        habitStore.habits.reduce(0) { $0 + ($1.isHabitCompleted ? $1.targetMinutes : 0) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                NoorBackgroundView()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - 1. Top Search & Notification Bar
                        HStack(spacing: 12) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Color(hex: "#8C7A6B"))
                                TextField("Search habits, pillars...", text: $searchInput)
                                    .font(.system(size: 14, design: .rounded))
                            }
                            .padding(12)
                            .noorCard(cornerRadius: 14)
                            
                            // Bell Notification Badge
                            ZStack(alignment: .topTrailing) {
                                Button(action: {
                                    SoundHapticManager.shared.lightImpact()
                                }) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 17))
                                        .foregroundColor(Color(hex: "#244E3F"))
                                        .frame(width: 44, height: 44)
                                        .noorCard(cornerRadius: 14)
                                }
                                
                                Circle()
                                    .fill(Color(hex: "#C2593F"))
                                    .frame(width: 10, height: 10)
                                    .offset(x: -4, y: 4)
                            }
                            
                            // Avatar Icon
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#FBF3E6"))
                                    .frame(width: 44, height: 44)
                                    .overlay(Circle().stroke(Color(hex: "#E8D8C0"), lineWidth: 1))
                                
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(Color(hex: "#D4A359"))
                            }
                        }
                        .padding(.horizontal)
                        
                        // MARK: - 2. Hero Greeting Banner Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 6) {
                                        Text("Good Morning! ☀️")
                                            .font(.system(size: 20, weight: .bold, design: .serif))
                                            .foregroundColor(Color(hex: "#2B2420"))
                                    }
                                    
                                    Text("Let's build unshakeable discipline & peace today.")
                                        .font(.system(size: 13, design: .rounded))
                                        .foregroundColor(Color(hex: "#8C7A6B"))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 28))
                                    .foregroundColor(Color(hex: "#D4A359"))
                            }
                            
                            HStack(spacing: 12) {
                                Button(action: {
                                    SoundHapticManager.shared.lightImpact()
                                    showingRoutineFlow = true
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "play.fill")
                                            .font(.system(size: 11))
                                        Text("Start Morning Ritual")
                                            .font(.system(size: 13, weight: .bold, design: .serif))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(Color(hex: "#244E3F")))
                                    .shadow(color: Color(hex: "#244E3F").opacity(0.3), radius: 6, x: 0, y: 3)
                                }
                                
                                Spacer()
                                
                                Text("\(completedTodayCount)/\(habitStore.habits.count) Done")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#244E3F"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(Color(hex: "#FBF3E6")).overlay(Capsule().stroke(Color(hex: "#E8D8C0"), lineWidth: 1)))
                            }
                            .padding(.top, 4)
                        }
                        .padding(18)
                        .noorCard(cornerRadius: 20)
                        .padding(.horizontal)
                        
                        // MARK: - 3. 4-Metric Tactical KPI Cards Grid (2x2)
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            kpiCard(
                                icon: "checklist",
                                iconColor: Color(hex: "#8B5CF6"),
                                title: "Habits Done",
                                value: "\(completedTodayCount)/\(habitStore.habits.count)",
                                trend: "+18% this week",
                                trendPositive: true
                            )
                            
                            kpiCard(
                                icon: "flame.fill",
                                iconColor: Color(hex: "#F97316"),
                                title: "Current Streak",
                                value: "\(maxStreak) Days",
                                trend: "unshakeable",
                                trendPositive: true
                            )
                            
                            kpiCard(
                                icon: "timer",
                                iconColor: Color(hex: "#D4A359"),
                                title: "Focus Minutes",
                                value: "\(totalFocusMinutes)m",
                                trend: "+12m today",
                                trendPositive: true
                            )
                            
                            kpiCard(
                                icon: "crown.fill",
                                iconColor: Color(hex: "#244E3F"),
                                title: "Level & XP",
                                value: "LVL \(habitStore.userLevel)",
                                trend: "\(habitStore.totalXP) Total XP",
                                trendPositive: true
                            )
                        }
                        .padding(.horizontal)
                        
                        // MARK: - 4. Middle Section: Weekly Activity Bar Chart & Category Breakdown
                        VStack(spacing: 14) {
                            // Weekly Habit Activity Bar Chart
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Weekly Habit Activity")
                                            .font(.system(size: 15, weight: .bold, design: .serif))
                                            .foregroundColor(Color(hex: "#2B2420"))
                                        Text("Consistency overview")
                                            .font(.system(size: 11, design: .rounded))
                                            .foregroundColor(Color(hex: "#8C7A6B"))
                                    }
                                    
                                    Spacer()
                                    
                                    Text("This Week ▾")
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "#244E3F"))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(Color(hex: "#FBF3E6")).overlay(Capsule().stroke(Color(hex: "#E8D8C0"), lineWidth: 1)))
                                }
                                
                                // 7-Day Bar Chart
                                HStack(alignment: .bottom, spacing: 10) {
                                    ForEach(0..<7, id: \.self) { index in
                                        let heights: [CGFloat] = [45, 65, 80, 50, 70, 90, 60]
                                        let barColors = [
                                            Color(hex: "#8B5CF6"),
                                            Color(hex: "#EC4899"),
                                            Color(hex: "#D4A359"),
                                            Color(hex: "#F97316"),
                                            Color(hex: "#4D7C5D"),
                                            Color(hex: "#06B6D4"),
                                            Color(hex: "#244E3F")
                                        ]
                                        
                                        VStack(spacing: 6) {
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [barColors[index], barColors[index].opacity(0.65)],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                                .frame(height: heights[index])
                                                .shadow(color: barColors[index].opacity(0.3), radius: 4, x: 0, y: 2)
                                            
                                            Text(weekDays[index])
                                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(hex: "#8C7A6B"))
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                                .frame(height: 110, alignment: .bottom)
                                .padding(.top, 4)
                            }
                            .padding(16)
                            .noorCard(cornerRadius: 18)
                            .padding(.horizontal)
                            
                            // Category Distribution Breakdown
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Text("Life Pillar Balance")
                                        .font(.system(size: 15, weight: .bold, design: .serif))
                                        .foregroundColor(Color(hex: "#2B2420"))
                                    Spacer()
                                }
                                
                                HStack(spacing: 16) {
                                    // Donut Ring Indicator
                                    ZStack {
                                        Circle()
                                            .stroke(Color(hex: "#EBE1D3"), lineWidth: 14)
                                            .frame(width: 80, height: 80)
                                        
                                        Circle()
                                            .trim(from: 0, to: 0.35)
                                            .stroke(Color(hex: "#244E3F"), lineWidth: 14)
                                            .frame(width: 80, height: 80)
                                            .rotationEffect(.degrees(-90))
                                        
                                        Circle()
                                            .trim(from: 0.35, to: 0.65)
                                            .stroke(Color(hex: "#D4A359"), lineWidth: 14)
                                            .frame(width: 80, height: 80)
                                            .rotationEffect(.degrees(-90))
                                        
                                        Circle()
                                            .trim(from: 0.65, to: 0.85)
                                            .stroke(Color(hex: "#C2593F"), lineWidth: 14)
                                            .frame(width: 80, height: 80)
                                            .rotationEffect(.degrees(-90))
                                        
                                        Circle()
                                            .trim(from: 0.85, to: 1.0)
                                            .stroke(Color(hex: "#8B5CF6"), lineWidth: 14)
                                            .frame(width: 80, height: 80)
                                            .rotationEffect(.degrees(-90))
                                    }
                                    .padding(.leading, 6)
                                    
                                    // Pillar Legend List
                                    VStack(alignment: .leading, spacing: 6) {
                                        pillarLegendRow(color: Color(hex: "#244E3F"), name: "Mindset", percent: "35%")
                                        pillarLegendRow(color: Color(hex: "#D4A359"), name: "Learning", percent: "30%")
                                        pillarLegendRow(color: Color(hex: "#C2593F"), name: "Fitness", percent: "20%")
                                        pillarLegendRow(color: Color(hex: "#8B5CF6"), name: "Productivity", percent: "15%")
                                    }
                                }
                            }
                            .padding(16)
                            .noorCard(cornerRadius: 18)
                            .padding(.horizontal)
                        }
                        
                        // MARK: - 5. Bottom Split: Recently Active Habits & Daily Focus Player
                        VStack(spacing: 14) {
                            // Recent Habits Card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Recently Checked")
                                        .font(.system(size: 15, weight: .bold, design: .serif))
                                        .foregroundColor(Color(hex: "#2B2420"))
                                    Spacer()
                                    NavigationLink(destination: CurrentHabitsView().environmentObject(habitStore)) {
                                        Text("See All ➔")
                                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                                            .foregroundColor(Color(hex: "#244E3F"))
                                    }
                                }
                                
                                ForEach(habitStore.habits.prefix(3), id: \.id) { habit in
                                    HStack(spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(hex: "#FBF3E6"))
                                                .frame(width: 36, height: 36)
                                            Image(systemName: habit.symbol)
                                                .font(.system(size: 15))
                                                .foregroundColor(Color(hex: "#C79546"))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(habit.title)
                                                .font(.system(size: 14, weight: .semibold, design: .serif))
                                                .foregroundColor(Color(hex: "#2B2420"))
                                            Text(habit.category.rawValue)
                                                .font(.system(size: 10, design: .rounded))
                                                .foregroundColor(Color(hex: "#8C7A6B"))
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            withAnimation {
                                                habitStore.toggleHabitQuick(habit)
                                            }
                                        }) {
                                            Image(systemName: habit.isHabitCompleted ? "checkmark.circle.fill" : "play.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(habit.isHabitCompleted ? Color(hex: "#244E3F") : Color(hex: "#D4A359"))
                                        }
                                    }
                                    .padding(.vertical, 3)
                                }
                            }
                            .padding(16)
                            .noorCard(cornerRadius: 18)
                            .padding(.horizontal)
                            
                            // Daily Focus Ambient Player Card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Daily Focus Soundscape")
                                        .font(.system(size: 15, weight: .bold, design: .serif))
                                        .foregroundColor(Color(hex: "#2B2420"))
                                    Spacer()
                                }
                                
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(hex: "#244E3F"), Color(hex: "#1B3B30")],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: "headphones")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(Color(hex: "#D4A359"))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Deep Focus Ambient")
                                            .font(.system(size: 15, weight: .bold, design: .serif))
                                            .foregroundColor(Color(hex: "#2B2420"))
                                        Text("Curated synthesized white noise & lo-fi")
                                            .font(.system(size: 11, design: .rounded))
                                            .foregroundColor(Color(hex: "#8C7A6B"))
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        if soundManager.activeSoundscape == .off {
                                            soundManager.setSoundscape(.rain)
                                        } else {
                                            soundManager.setSoundscape(.off)
                                        }
                                        SoundHapticManager.shared.lightImpact()
                                    }) {
                                        Image(systemName: soundManager.activeSoundscape != .off ? "pause.circle.fill" : "play.circle.fill")
                                            .font(.system(size: 36))
                                            .foregroundColor(Color(hex: "#244E3F"))
                                    }
                                }
                            }
                            .padding(16)
                            .noorCard(cornerRadius: 18)
                            .padding(.horizontal)
                        }
                        
                        // MARK: - 6. Bottom Discovery Wisdom Banner
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#D4A359"))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "star.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Discover Daily Growth")
                                    .font(.system(size: 14, weight: .bold, design: .serif))
                                    .foregroundColor(Color(hex: "#2B2420"))
                                Text("Explore habits and track consistency")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundColor(Color(hex: "#8C7A6B"))
                            }
                            
                            Spacer()
                            
                            NavigationLink(destination: InsightsView().environmentObject(habitStore)) {
                                Text("Explore Now")
                                    .font(.system(size: 12, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(Color(hex: "#244E3F")))
                            }
                        }
                        .padding(16)
                        .noorCard(cornerRadius: 18)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingRoutineFlow) {
            RoutineStackFlowView(stackName: "🌅 Morning Ritual")
                .environmentObject(habitStore)
        }
    }
    
    private func kpiCard(icon: String, iconColor: Color, title: String, value: String, trend: String, trendPositive: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(hex: "#FBF3E6"))
                    .frame(width: 36, height: 36)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#E8D8C0"), lineWidth: 1))
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#8C7A6B"))
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "#2B2420"))
            
            Text(trend)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: "#244E3F"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .noorCard(cornerRadius: 16)
    }
    
    private func pillarLegendRow(color: Color, name: String, percent: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(name)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#2B2420"))
            
            Spacer()
            
            Text(percent)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#8C7A6B"))
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(HabitStore())
    }
}
