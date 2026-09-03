//
//  HabitRowView.swift
//  HabitTracker
//
//  Created by Saikat Kumar Dey on 09/07/23.
//

import SwiftUI

struct HabitRow: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var habitStore: HabitStore
    @ObservedObject var habit: Habit
    
    @State private var lastNdays = [Int]()
    @State private var isCheckmarkPressed = false
    
    var body: some View {
        HStack(spacing: 14) {
            // Quick-Complete Action Checkmark Button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    isCheckmarkPressed = true
                }
                habitStore.toggleHabitQuick(habit)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isCheckmarkPressed = false
                    }
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            habit.isHabitCompleted ?
                            LinearGradient(
                                colors: [habit.color, habit.color.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.12), Color.gray.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(
                            color: habit.isHabitCompleted ? habit.color.opacity(0.4) : Color.clear,
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    
                    if habit.isHabitCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: habit.symbol)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(colorScheme == .dark && habit.color == .black ? .primary : habit.color)
                    }
                }
                .scaleEffect(isCheckmarkPressed ? 0.82 : 1.0)
            }
            .buttonStyle(.plain)
            
            // Habit Info & Category Pill
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(habit.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(habit.isHabitCompleted ? .secondary : .primary)
                        .strikethrough(habit.isHabitCompleted, color: .secondary)
                    
                    Spacer()
                    
                    // Streak Pill
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.orange)
                        Text("\(habit.calculateStreak())")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.orange.opacity(0.12)))
                }
                
                HStack(spacing: 8) {
                    // Category Tag
                    HStack(spacing: 3) {
                        Image(systemName: habit.category.icon)
                            .font(.system(size: 9))
                        Text(habit.category.rawValue)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(LinearGradient(colors: habit.category.gradientColors, startPoint: .leading, endPoint: .trailing).opacity(0.15))
                    )
                    .foregroundColor(habit.category.gradientColors.first ?? .blue)
                    
                    // Reminder Time
                    HStack(spacing: 3) {
                        Image(systemName: "clock")
                            .font(.system(size: 9))
                        Text(habit.startDate.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 10, design: .rounded))
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // 7-Day History Dots
                    HStack(spacing: 4) {
                        ForEach(0..<lastNdays.count, id: \.self) { index in
                            let cell = lastNdays[index]
                            Circle()
                                .fill(
                                    cell == 1 ? Color.green : (index == lastNdays.count - 1 && cell == 0 ? Color.gray.opacity(0.3) : Color.red.opacity(0.6))
                                )
                                .frame(width: 6, height: 6)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .onAppear {
            lastNdays = habit.lastNdayCells(n: 7)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                lastNdays = habit.lastNdayCells(n: 7)
            }
        }
    }
}

struct HabitRow_Previews: PreviewProvider {
    static var previews: some View {
        HabitRow(habit: Habit(title: "Morning Meditation", completedDates: [], startDate: Date()))
            .environmentObject(HabitStore())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
