//
//  RoutineStackFlowView.swift
//  HabitTracker
//

import SwiftUI

struct RoutineStackFlowView: View {
    let stackName: String
    @EnvironmentObject var habitStore: HabitStore
    @Environment(\.dismiss) var dismiss
    
    @State private var currentIndex: Int = 0
    @State private var isFinished: Bool = false
    
    private var stackHabits: [Habit] {
        habitStore.habitsForStack(stackName)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if stackHabits.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "square.stack.3d.up.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No habits assigned to \(stackName)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("Edit your habits to assign them to this routine stack.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding()
                } else if isFinished {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.green)
                            .shadow(color: .green.opacity(0.5), radius: 15)
                        
                        Text("Routine Complete! 🎉")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("You've successfully completed all habits in \(stackName). Great consistency!")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Finish Routine")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(LinearGradient(colors: [.green, .teal], startPoint: .leading, endPoint: .trailing)))
                        }
                        Spacer()
                    }
                } else {
                    // Progress Bar
                    VStack(spacing: 6) {
                        HStack {
                            Text("Step \(currentIndex + 1) of \(stackHabits.count)")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int((Double(currentIndex) / Double(stackHabits.count)) * 100))%")
                                .font(.caption.bold())
                                .foregroundColor(.purple)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.gray.opacity(0.2)).frame(height: 8)
                                Capsule()
                                    .fill(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: geo.size.width * CGFloat(currentIndex + 1) / CGFloat(stackHabits.count), height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(.horizontal)
                    
                    let habit = stackHabits[currentIndex]
                    
                    // Current Step 3D Hero Card
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [habit.color, habit.color.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 80, height: 80)
                                .shadow(color: habit.color.opacity(0.5), radius: 12, x: 0, y: 6)
                            
                            Image(systemName: habit.symbol)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 6) {
                            Text(habit.title)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text(habit.category.rawValue)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(habit.category.gradientColors.first ?? .blue)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(habit.category.gradientColors.first?.opacity(0.15) ?? Color.blue.opacity(0.15)))
                        }
                    }
                    .padding(32)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .threeDCardEffect(maxTilt: 16, isInteractive: true, cornerRadius: 24)
                    .padding(.horizontal)
                    
                    // Complete & Next Action
                    Button(action: {
                        habitStore.markHabitAsCompleted(habit)
                        SoundHapticManager.shared.celebrationFeedback()
                        if currentIndex + 1 < stackHabits.count {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                currentIndex += 1
                            }
                        } else {
                            withAnimation {
                                isFinished = true
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .bold))
                            Text(currentIndex + 1 < stackHabits.count ? "Mark Done & Next" : "Complete Routine")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [habit.color, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: habit.color.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle(stackName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
