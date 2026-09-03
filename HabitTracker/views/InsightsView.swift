//
//  InsightsView.swift
//  HabitTracker
//

import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var habitStore: HabitStore
    
    private var totalCompletedAll: Int {
        habitStore.habits.reduce(0) { $0 + $1.calculateTotalCompleted() }
    }
    
    private var averageStrength: Int {
        guard !habitStore.habits.isEmpty else { return 0 }
        let total = habitStore.habits.reduce(0) { $0 + $1.habitStrength }
        return total / habitStore.habits.count
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 22) {
                    // Interactive 3D Habit Matrix Cube Hero
                    ThreeDHabitCubeView()
                        .padding(.top, 10)
                    
                    // 30-Day Activity Matrix Heatmap
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Image(systemName: "square.grid.3x3.fill")
                                .foregroundColor(.green)
                            Text("30-Day Activity Matrix")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                            Spacer()
                        }
                        
                        let days = getLast30Days()
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 10), spacing: 6) {
                            ForEach(days, id: \.self) { day in
                                let count = getCompletedHabitsCount(on: day)
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(getColorForCount(count))
                                    .frame(height: 26)
                                    .overlay(
                                        Text("\(Calendar.current.component(.day, from: day))")
                                            .font(.system(size: 9, weight: .bold, design: .rounded))
                                            .foregroundColor(count > 0 ? .white : .secondary.opacity(0.7))
                                    )
                            }
                        }
                        
                        HStack {
                            Text("Less")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            RoundedRectangle(cornerRadius: 3).fill(Color.gray.opacity(0.2)).frame(width: 14, height: 14)
                            RoundedRectangle(cornerRadius: 3).fill(Color.green.opacity(0.4)).frame(width: 14, height: 14)
                            RoundedRectangle(cornerRadius: 3).fill(Color.green.opacity(0.7)).frame(width: 14, height: 14)
                            RoundedRectangle(cornerRadius: 3).fill(Color.green).frame(width: 14, height: 14)
                            Text("More")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                    .padding(18)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .threeDCardEffect(maxTilt: 10, isInteractive: true, cornerRadius: 20)
                    
                    // Mood & Energy Trends Section
                    if !habitStore.moodEntries.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "heart.text.square.fill")
                                    .foregroundColor(.pink)
                                Text("Mood & Energy History")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                Spacer()
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(habitStore.moodEntries.prefix(7)) { entry in
                                        VStack(spacing: 4) {
                                            Text(entry.emoji)
                                                .font(.system(size: 24))
                                            Text(entry.label)
                                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                                .foregroundColor(.primary)
                                            HStack(spacing: 2) {
                                                ForEach(1...entry.energyLevel, id: \.self) { _ in
                                                    Image(systemName: "bolt.fill")
                                                        .font(.system(size: 8))
                                                        .foregroundColor(.yellow)
                                                }
                                            }
                                            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.system(size: 8))
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(10)
                                        .background(Color(.systemGray6))
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    }
                                }
                            }
                        }
                        .padding(18)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .threeDCardEffect(maxTilt: 8, isInteractive: true, cornerRadius: 20)
                    }
                    
                    // Habit Strength Leaderboard
                    if !habitStore.habits.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.orange)
                                Text("Habit Strength Index")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                Spacer()
                            }
                            
                            ForEach(habitStore.habits.sorted(by: { $0.habitStrength > $1.habitStrength }), id: \.id) { habit in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Image(systemName: habit.symbol)
                                            .foregroundColor(habit.color)
                                        Text(habit.title)
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        Spacer()
                                        Text("\(habit.habitStrength)%")
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundColor(habit.color)
                                    }
                                    
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Color.gray.opacity(0.15))
                                                .frame(height: 8)
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [habit.color, habit.color.opacity(0.6)],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(width: max(8, geo.size.width * CGFloat(habit.habitStrength) / 100.0), height: 8)
                                        }
                                    }
                                    .frame(height: 8)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(18)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .threeDCardEffect(maxTilt: 10, isInteractive: true, cornerRadius: 20)
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics & 3D Cube")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func getLast30Days() -> [Date] {
        var days: [Date] = []
        let cal = Calendar.current
        let today = Date().startOfDay
        for i in (0..<30).reversed() {
            if let d = cal.date(byAdding: .day, value: -i, to: today) {
                days.append(d)
            }
        }
        return days
    }
    
    private func getCompletedHabitsCount(on date: Date) -> Int {
        habitStore.habits.filter { $0.isCompleted(on: date) }.count
    }
    
    private func getColorForCount(_ count: Int) -> Color {
        if count == 0 {
            return Color.gray.opacity(0.15)
        } else if count == 1 {
            return Color.green.opacity(0.4)
        } else if count == 2 {
            return Color.green.opacity(0.7)
        } else {
            return Color.green
        }
    }
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView()
            .environmentObject(HabitStore())
    }
}
