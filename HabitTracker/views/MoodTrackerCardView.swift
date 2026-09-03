//
//  MoodTrackerCardView.swift
//  HabitTracker
//

import SwiftUI

struct MoodTrackerCardView: View {
    @EnvironmentObject var habitStore: HabitStore
    @State private var selectedEmoji: String = "🔥"
    @State private var selectedLabel: String = "Productive"
    @State private var selectedEnergy: Int = 4
    @State private var isSavedToday: Bool = false
    
    private let moods = [
        ("⚡", "Energetic"),
        ("🧘", "Peaceful"),
        ("🔥", "Productive"),
        ("😴", "Tired"),
        ("🚀", "Unstoppable")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "face.smiling.fill")
                    .foregroundColor(.yellow)
                Text("Daily Mood & Energy Check-in")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Spacer()
                if let todays = habitStore.todaysMood() {
                    Text("\(todays.emoji) \(todays.label)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.green.opacity(0.15)))
                }
            }
            
            // Mood Emoji Selectors
            HStack(spacing: 8) {
                ForEach(moods, id: \.0) { emoji, label in
                    Button(action: {
                        selectedEmoji = emoji
                        selectedLabel = label
                        habitStore.logTodayMood(emoji: emoji, label: label, energy: selectedEnergy)
                        SoundHapticManager.shared.lightImpact()
                    }) {
                        VStack(spacing: 4) {
                            Text(emoji)
                                .font(.system(size: 24))
                            Text(label)
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    selectedEmoji == emoji ?
                                    Color.yellow.opacity(0.2) : Color(.systemGray6)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(
                                            selectedEmoji == emoji ? Color.yellow : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                        )
                    }
                }
            }
            
            // Energy Level Selector
            HStack {
                Text("Energy Level:")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 6) {
                    ForEach(1...5, id: \.self) { level in
                        Button(action: {
                            selectedEnergy = level
                            habitStore.logTodayMood(emoji: selectedEmoji, label: selectedLabel, energy: level)
                            SoundHapticManager.shared.lightImpact()
                        }) {
                            Image(systemName: level <= selectedEnergy ? "bolt.fill" : "bolt")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(level <= selectedEnergy ? .yellow : .gray.opacity(0.4))
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .threeDCardEffect(maxTilt: 8, isInteractive: true, cornerRadius: 18)
        .onAppear {
            if let todays = habitStore.todaysMood() {
                selectedEmoji = todays.emoji
                selectedLabel = todays.label
                selectedEnergy = todays.energyLevel
            }
        }
    }
}

struct MoodTrackerCardView_Previews: PreviewProvider {
    static var previews: some View {
        MoodTrackerCardView()
            .environmentObject(HabitStore())
            .padding()
    }
}
