//
//  InsightsView.swift
//  HabitHub
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
            ZStack {
                NoorBackgroundView()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 3D Habit Matrix Cube
                        ThreeDHabitCubeView()
                            .padding(.top, 8)
                        
                        // 30-Day Activity Heatmap Matrix
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "square.grid.3x3.fill")
                                    .foregroundColor(Color(hex: "#244E3F"))
                                Text("30-Day Activity Matrix")
                                    .font(.system(size: 17, weight: .bold, design: .serif))
                                    .foregroundColor(Color(hex: "#2B2420"))
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
                                                .foregroundColor(count > 0 ? .white : Color(hex: "#8C7A6B"))
                                        )
                                }
                            }
                            
                            HStack {
                                Text("Less")
                                    .font(.caption2)
                                    .foregroundColor(Color(hex: "#8C7A6B"))
                                RoundedRectangle(cornerRadius: 3).fill(Color(hex: "#EBE1D3")).frame(width: 14, height: 14)
                                RoundedRectangle(cornerRadius: 3).fill(Color(hex: "#D4A359").opacity(0.4)).frame(width: 14, height: 14)
                                RoundedRectangle(cornerRadius: 3).fill(Color(hex: "#244E3F").opacity(0.6)).frame(width: 14, height: 14)
                                RoundedRectangle(cornerRadius: 3).fill(Color(hex: "#244E3F")).frame(width: 14, height: 14)
                                Text("More")
                                    .font(.caption2)
                                    .foregroundColor(Color(hex: "#8C7A6B"))
                                Spacer()
                            }
                            .padding(.top, 4)
                        }
                        .padding(18)
                        .noorCard(cornerRadius: 20)
                        
                        // Habit Strength Leaderboard
                        if !habitStore.habits.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                        .foregroundColor(Color(hex: "#C79546"))
                                    Text("Habit Strength Index")
                                        .font(.system(size: 17, weight: .bold, design: .serif))
                                        .foregroundColor(Color(hex: "#2B2420"))
                                    Spacer()
                                }
                                
                                ForEach(habitStore.habits.sorted(by: { $0.habitStrength > $1.habitStrength }), id: \.id) { habit in
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Image(systemName: habit.symbol)
                                                .foregroundColor(Color(hex: "#C79546"))
                                            Text(habit.title)
                                                .font(.system(size: 14, weight: .semibold, design: .serif))
                                                .foregroundColor(Color(hex: "#2B2420"))
                                            Spacer()
                                            Text("\(habit.habitStrength)%")
                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(hex: "#244E3F"))
                                        }
                                        
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                Capsule()
                                                    .fill(Color(hex: "#EBE1D3"))
                                                    .frame(height: 8)
                                                Capsule()
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [Color(hex: "#244E3F"), Color(hex: "#D4A359")],
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
                            .noorCard(cornerRadius: 20)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Analytics & Insights")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
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
            return Color(hex: "#EBE1D3")
        } else if count == 1 {
            return Color(hex: "#D4A359").opacity(0.5)
        } else if count == 2 {
            return Color(hex: "#244E3F").opacity(0.65)
        } else {
            return Color(hex: "#244E3F")
        }
    }
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView()
            .environmentObject(HabitStore())
    }
}
