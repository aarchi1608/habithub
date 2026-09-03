//
//  AddHabitView.swift
//  HabitTracker
//
//  Created by Saikat Kumar Dey on 01/07/23.
//

import SwiftUI

struct AddHabit: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var habit: Habit
    
    @State private var isPickingSymbol: Bool = false
    @State private var showingPopover = false
    
    var isEditing: Bool = false
    let onAdd: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Live 3D Interactive Card Preview
                    VStack(alignment: .leading, spacing: 10) {
                        Text("LIVE 3D PREVIEW")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.2)
                        
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [habit.color, habit.color.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 48, height: 48)
                                    .shadow(color: habit.color.opacity(0.4), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: habit.symbol)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(habit.title.isEmpty ? "Your New Habit" : habit.title)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                HStack(spacing: 8) {
                                    HStack(spacing: 3) {
                                        Image(systemName: habit.category.icon)
                                            .font(.system(size: 9))
                                        Text(habit.category.rawValue)
                                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                                    }
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(habit.category.gradientColors.first?.opacity(0.18) ?? Color.blue.opacity(0.18)))
                                    .foregroundColor(habit.category.gradientColors.first ?? .blue)
                                    
                                    HStack(spacing: 3) {
                                        Image(systemName: "clock")
                                            .font(.system(size: 9))
                                        Text(habit.startDate.formatted(date: .omitted, time: .shortened))
                                            .font(.system(size: 10, design: .rounded))
                                    }
                                    .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .threeDCardEffect(maxTilt: 14, isInteractive: true, cornerRadius: 18)
                    }
                    .padding(.top, 4)
                    
                    // Habit Title Input
                    VStack(alignment: .leading, spacing: 6) {
                        Text("HABIT TITLE")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.2)
                        
                        TextField(isEditing ? habit.title : "e.g. Read 20 pages, Morning Jog", text: $habit.title)
                            .font(.system(size: 16, design: .rounded))
                            .padding(14)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    // Category Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("LIFE PILLAR / CATEGORY")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.2)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(HabitCategory.allCases) { cat in
                                    Button(action: {
                                        habit.category = cat
                                        SoundHapticManager.shared.lightImpact()
                                    }) {
                                        HStack(spacing: 5) {
                                            Image(systemName: cat.icon)
                                                .font(.system(size: 11))
                                            Text(cat.rawValue)
                                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(habit.category == cat ? cat.gradientColors.first ?? .blue : Color(.systemGray6))
                                        )
                                        .foregroundColor(habit.category == cat ? .white : .primary)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Target Mode & Reminder Time
                    VStack(alignment: .leading, spacing: 10) {
                        Text("REMINDER & SCHEDULE")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.2)
                        
                        HStack {
                            DatePicker(
                                "Reminder Time",
                                selection: $habit.startDate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .font(.system(size: 15, design: .rounded))
                            .onChange(of: habit.startDate) { _ in
                                habit.clearCompletedDates()
                            }
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Icon & Color Picker Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CUSTOMIZE ICON & COLOR")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.2)
                        
                        SymbolPicker()
                            .environmentObject(habit)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .navigationBarTitle(isEditing ? "Edit Habit" : "New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Create") {
                        onAdd()
                        dismiss()
                    }
                    .font(.headline)
                    .disabled(habit.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct AddHabit_Previews: PreviewProvider {
    static var previews: some View {
        AddHabit() {}
            .environmentObject(Habit())
    }
}
