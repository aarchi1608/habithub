//
//  AddHabitView.swift
//  HabitHub
//

import SwiftUI

struct HabitPresetItem: Identifiable {
    let id = UUID()
    let title: String
    let symbol: String
    let category: HabitCategory
    let minutes: Int
    let color: Color
}

struct AddHabit: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var habit: Habit
    
    var isEditing: Bool = false
    let onAdd: () -> Void
    
    private let targetDurations = [5, 10, 15, 20, 30, 45, 60]
    
    private let quickPresets: [HabitPresetItem] = [
        HabitPresetItem(title: "Morning Meditation", symbol: "sun.max.fill", category: .mindset, minutes: 15, color: Color(hex: "#D4A359")),
        HabitPresetItem(title: "Daily Quran / Wisdom", symbol: "book.fill", category: .learning, minutes: 20, color: Color(hex: "#244E3F")),
        HabitPresetItem(title: "Daily Workout", symbol: "figure.run", category: .fitness, minutes: 30, color: Color(hex: "#C2593F")),
        HabitPresetItem(title: "Drink 2L Water", symbol: "drop.fill", category: .health, minutes: 5, color: Color(hex: "#0F766E")),
        HabitPresetItem(title: "Evening Reflection", symbol: "moon.stars.fill", category: .mindset, minutes: 10, color: Color(hex: "#4D7C5D")),
        HabitPresetItem(title: "Deep Work Session", symbol: "bolt.fill", category: .productivity, minutes: 45, color: Color(hex: "#C79546"))
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                NoorBackgroundView()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        // MARK: - 1. Live Interactive Noor Card Preview
                        VStack(alignment: .leading, spacing: 8) {
                            Text("LIVE CARD PREVIEW")
                                .font(.system(size: 11, weight: .bold, design: .serif))
                                .foregroundColor(Color(hex: "#8C7A6B"))
                                .tracking(1.0)
                            
                            HStack(spacing: 14) {
                                // Amber Icon Container
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color(hex: "#FBF3E6"))
                                        .frame(width: 48, height: 48)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(Color(hex: "#E8D8C0"), lineWidth: 1)
                                        )
                                    
                                    Image(systemName: habit.symbol)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color(hex: "#C79546"))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(habit.title.isEmpty ? "Your New Habit" : habit.title)
                                        .font(.system(size: 17, weight: .bold, design: .serif))
                                        .foregroundColor(Color(hex: "#2B2420"))
                                        .lineLimit(1)
                                    
                                    HStack(spacing: 6) {
                                        Text(habit.category.rawValue)
                                            .font(.system(size: 11, weight: .medium, design: .rounded))
                                            .foregroundColor(Color(hex: "#8C7A6B"))
                                        
                                        if habit.targetMinutes > 0 {
                                            Text("•")
                                                .font(.system(size: 9))
                                                .foregroundColor(Color(hex: "#C2B5A5"))
                                            
                                            Text("\(habit.targetMinutes) min")
                                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                                .foregroundColor(Color(hex: "#C79546"))
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                // Preview Checkmark Ring
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "#244E3F"))
                                        .frame(width: 34, height: 34)
                                        .shadow(color: Color(hex: "#244E3F").opacity(0.3), radius: 4, x: 0, y: 2)
                                    
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(16)
                            .noorCard(cornerRadius: 18)
                            .threeDCardEffect(maxTilt: 12, isInteractive: true, cornerRadius: 18)
                        }
                        .padding(.top, 4)
                        
                        // MARK: - 2. Quick Preset Suggestion Chips
                        VStack(alignment: .leading, spacing: 8) {
                            Text("QUICK INSPIRATIONS")
                                .font(.system(size: 11, weight: .bold, design: .serif))
                                .foregroundColor(Color(hex: "#8C7A6B"))
                                .tracking(1.0)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(quickPresets) { preset in
                                        Button(action: {
                                            habit.title = preset.title
                                            habit.symbol = preset.symbol
                                            habit.category = preset.category
                                            habit.targetMinutes = preset.minutes
                                            habit.color = preset.color
                                            SoundHapticManager.shared.lightImpact()
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: preset.symbol)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(Color(hex: "#C79546"))
                                                Text(preset.title)
                                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                                    .foregroundColor(Color(hex: "#2B2420"))
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color(hex: "#FFFFFF"))
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(Color(hex: "#EBE1D3"), lineWidth: 1))
                                        }
                                    }
                                }
                            }
                        }
                        
                        // MARK: - 3. Habit Title Input Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("HABIT TITLE")
                                .font(.system(size: 11, weight: .bold, design: .serif))
                                .foregroundColor(Color(hex: "#8C7A6B"))
                                .tracking(1.0)
                            
                            HStack(spacing: 10) {
                                Image(systemName: "pencil")
                                    .foregroundColor(Color(hex: "#C79546"))
                                
                                TextField("e.g. Read 20 pages, Morning Jog", text: $habit.title)
                                    .font(.system(size: 16, design: .serif))
                                
                                if !habit.title.isEmpty {
                                    Button(action: { habit.title = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(Color(hex: "#8C7A6B"))
                                    }
                                }
                            }
                            .padding(14)
                            .noorCard(cornerRadius: 16)
                        }
                        
                        // MARK: - 4. Category Selector
                        VStack(alignment: .leading, spacing: 8) {
                            Text("LIFE PILLAR / CATEGORY")
                                .font(.system(size: 11, weight: .bold, design: .serif))
                                .foregroundColor(Color(hex: "#8C7A6B"))
                                .tracking(1.0)
                            
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
                                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(habit.category == cat ? Color(hex: "#244E3F") : Color(hex: "#FFFFFF"))
                                            )
                                            .foregroundColor(habit.category == cat ? .white : Color(hex: "#2B2420"))
                                            .overlay(
                                                Capsule().stroke(Color(hex: "#EBE1D3"), lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        
                        // MARK: - 5. Target Duration Selector
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DAILY DURATION")
                                .font(.system(size: 11, weight: .bold, design: .serif))
                                .foregroundColor(Color(hex: "#8C7A6B"))
                                .tracking(1.0)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(targetDurations, id: \.self) { mins in
                                        Button(action: {
                                            habit.targetMinutes = mins
                                            SoundHapticManager.shared.lightImpact()
                                        }) {
                                            Text("\(mins) min")
                                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                                .foregroundColor(habit.targetMinutes == mins ? .white : Color(hex: "#2B2420"))
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 8)
                                                .background(
                                                    Capsule()
                                                        .fill(habit.targetMinutes == mins ? Color(hex: "#244E3F") : Color(hex: "#FFFFFF"))
                                                )
                                                .overlay(
                                                    Capsule().stroke(Color(hex: "#EBE1D3"), lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        
                        // MARK: - 6. Routine Stack Assignment
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ROUTINE STACK")
                                .font(.system(size: 11, weight: .bold, design: .serif))
                                .foregroundColor(Color(hex: "#8C7A6B"))
                                .tracking(1.0)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    Button(action: {
                                        habit.routineStack = nil
                                        SoundHapticManager.shared.lightImpact()
                                    }) {
                                        Text("None")
                                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(habit.routineStack == nil ? Color(hex: "#244E3F") : Color(hex: "#FFFFFF"))
                                            )
                                            .foregroundColor(habit.routineStack == nil ? .white : Color(hex: "#2B2420"))
                                            .overlay(Capsule().stroke(Color(hex: "#EBE1D3"), lineWidth: 1))
                                    }
                                    
                                    ForEach([
                                        "🌅 Morning Ritual",
                                        "⚡ Deep Work",
                                        "🧘 Wellness",
                                        "🌙 Evening Reset"
                                    ], id: \.self) { stack in
                                        Button(action: {
                                            habit.routineStack = stack
                                            SoundHapticManager.shared.lightImpact()
                                        }) {
                                            Text(stack)
                                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(
                                                    Capsule()
                                                        .fill(habit.routineStack == stack ? Color(hex: "#244E3F") : Color(hex: "#FFFFFF"))
                                                )
                                                .foregroundColor(habit.routineStack == stack ? .white : Color(hex: "#2B2420"))
                                                .overlay(Capsule().stroke(Color(hex: "#EBE1D3"), lineWidth: 1))
                                        }
                                    }
                                }
                            }
                        }
                        
                        // MARK: - 7. Reminder Time Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("REMINDER & SCHEDULE")
                                .font(.system(size: 11, weight: .bold, design: .serif))
                                .foregroundColor(Color(hex: "#8C7A6B"))
                                .tracking(1.0)
                            
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(Color(hex: "#C79546"))
                                
                                DatePicker(
                                    "Reminder Time",
                                    selection: $habit.startDate,
                                    displayedComponents: [.hourAndMinute]
                                )
                                .font(.system(size: 15, design: .serif))
                                .onChange(of: habit.startDate) { _ in
                                    habit.clearCompletedDates()
                                }
                            }
                            .padding(14)
                            .noorCard(cornerRadius: 16)
                        }
                        
                        // MARK: - 8. Icon & Color Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CUSTOMIZE ICON & SYMBOL")
                                .font(.system(size: 11, weight: .bold, design: .serif))
                                .foregroundColor(Color(hex: "#8C7A6B"))
                                .tracking(1.0)
                            
                            SymbolPicker()
                                .environmentObject(habit)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitle(isEditing ? "Edit Habit" : "New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#8C7A6B"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Create") {
                        onAdd()
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundColor(Color(hex: "#244E3F"))
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
