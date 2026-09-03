//
//  HabitRowView.swift
//  HabitHub
//

import SwiftUI

struct HabitRow: View {
    @ObservedObject var habit: Habit
    @EnvironmentObject var habitStore: HabitStore
    
    var body: some View {
        HStack(spacing: 14) {
            // Amber/Gold Icon Container
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(hex: "#FBF3E6"))
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(hex: "#E8D8C0"), lineWidth: 1)
                    )
                
                Image(systemName: habit.symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#C79546"))
            }
            
            // Title & Duration / Category
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(habit.title)
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundColor(Color(hex: "#2B2420"))
                        .strikethrough(habit.isHabitCompleted, color: Color(hex: "#244E3F").opacity(0.6))
                        .lineLimit(1)
                    
                    if habit.targetMinutes > 0 {
                        Text("\(habit.targetMinutes) min")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "#C79546"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "#FBF3E6"))
                            )
                    }
                }
                
                HStack(spacing: 6) {
                    Text(habit.category.rawValue)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#8C7A6B"))
                    
                    Text("•")
                        .font(.system(size: 9))
                        .foregroundColor(Color(hex: "#C2B5A5"))
                    
                    Text("\(habit.calculateStreak())d streak")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#244E3F"))
                }
            }
            
            Spacer()
            
            // Circular Checkmark Button
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                    habitStore.toggleHabitQuick(habit)
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            habit.isHabitCompleted ?
                            Color(hex: "#244E3F") :
                            Color(hex: "#FBF8F3")
                        )
                        .frame(width: 34, height: 34)
                        .overlay(
                            Circle()
                                .stroke(
                                    habit.isHabitCompleted ?
                                    Color(hex: "#244E3F") :
                                    Color(hex: "#D4A359").opacity(0.5),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(
                            color: habit.isHabitCompleted ? Color(hex: "#244E3F").opacity(0.3) : Color.clear,
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                    
                    if habit.isHabitCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .noorCard(cornerRadius: 16)
    }
}

struct HabitRow_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            NoorBackgroundView()
            HabitRow(habit: Habit(title: "Morning Reflection", category: .mindset))
                .environmentObject(HabitStore())
                .padding()
        }
    }
}
