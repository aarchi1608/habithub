//
//  FocusTimerView.swift
//  HabitTracker
//

import SwiftUI

struct FocusTimerView: View {
    @EnvironmentObject var habitStore: HabitStore
    @StateObject private var soundManager = AmbientSoundManager.shared
    
    @State private var focusModeSegment: Int = 0 // 0: Timer, 1: 3D Breathing
    @State private var selectedHabitId: UUID?
    @State private var totalSeconds: Int = 25 * 60
    @State private var remainingSeconds: Int = 25 * 60
    @State private var isRunning: Bool = false
    @State private var timer: Timer? = nil
    @State private var pulseScale: CGFloat = 1.0
    
    private let presets = [5, 10, 15, 25, 45, 60]
    
    private var selectedHabit: Habit? {
        if let id = selectedHabitId {
            return habitStore.getHabit(by: id)
        }
        return habitStore.habits.first
    }
    
    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - (Double(remainingSeconds) / Double(totalSeconds))
    }
    
    private var timeString: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Mode Selector (Focus Timer vs 3D Breathing)
                    Picker("Mode", selection: $focusModeSegment) {
                        Text("⏱️ Focus Timer").tag(0)
                        Text("🫁 3D Breathing").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if focusModeSegment == 1 {
                        // 3D Breathing Mindfulness Mode
                        ThreeDBreathingOrbView()
                            .padding(.top, 10)
                    } else {
                        // Habit Selector Pill
                        if !habitStore.habits.isEmpty {
                            Menu {
                                ForEach(habitStore.habits, id: \.id) { habit in
                                    Button(action: {
                                        selectedHabitId = habit.id
                                        SoundHapticManager.shared.lightImpact()
                                    }) {
                                        HStack {
                                            Image(systemName: habit.symbol)
                                            Text(habit.title)
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: selectedHabit?.symbol ?? "target")
                                        .foregroundColor(selectedHabit?.color ?? .blue)
                                    Text(selectedHabit?.title ?? "Select a Habit")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color(.secondarySystemGroupedBackground))
                                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                                )
                            }
                        }
                        
                        // 3D Pulsating Focus Ring
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            (selectedHabit?.color ?? .blue).opacity(isRunning ? 0.35 : 0.15),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 40,
                                        endRadius: 150
                                    )
                                )
                                .frame(width: 260, height: 260)
                                .scaleEffect(pulseScale)
                                .blur(radius: 20)
                            
                            Circle()
                                .stroke(Color.gray.opacity(0.18), lineWidth: 16)
                                .frame(width: 220, height: 220)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(progress))
                                .stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: [
                                            selectedHabit?.color ?? .blue,
                                            .purple,
                                            selectedHabit?.color ?? .cyan
                                        ]),
                                        center: .center,
                                        startAngle: .degrees(-90),
                                        endAngle: .degrees(270)
                                    ),
                                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                                )
                                .frame(width: 220, height: 220)
                                .rotationEffect(.degrees(-90))
                                .shadow(color: (selectedHabit?.color ?? .blue).opacity(0.6), radius: 10, x: 0, y: 0)
                            
                            VStack(spacing: 6) {
                                Text(timeString)
                                    .font(.system(size: 46, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .monospacedDigit()
                                
                                Text(isRunning ? "FOCUSING..." : (remainingSeconds == 0 ? "DONE! 🎉" : "READY"))
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(isRunning ? (selectedHabit?.color ?? .blue) : .secondary)
                                    .tracking(1.5)
                            }
                        }
                        .frame(height: 250)
                        .threeDCardEffect(maxTilt: 12, isInteractive: true, cornerRadius: 130)
                        
                        // Quick Preset Buttons
                        HStack(spacing: 8) {
                            ForEach(presets, id: \.self) { mins in
                                Button(action: {
                                    selectPreset(minutes: mins)
                                }) {
                                    Text("\(mins)m")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(totalSeconds == mins * 60 ? .white : .primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(totalSeconds == mins * 60 ? (selectedHabit?.color ?? .blue) : Color(.secondarySystemGroupedBackground))
                                        )
                                }
                                .disabled(isRunning)
                            }
                        }
                        
                        // Control Action Buttons
                        HStack(spacing: 24) {
                            Button(action: resetTimer) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.secondary)
                                    .frame(width: 50, height: 50)
                                    .background(Circle().fill(Color(.secondarySystemGroupedBackground)))
                                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                            }
                            
                            Button(action: toggleTimer) {
                                HStack(spacing: 8) {
                                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                        .font(.system(size: 20, weight: .bold))
                                    Text(isRunning ? "PAUSE" : "START FOCUS")
                                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 26)
                                .padding(.vertical, 15)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [selectedHabit?.color ?? .blue, Color.purple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: (selectedHabit?.color ?? .blue).opacity(0.45), radius: 10, x: 0, y: 5)
                                )
                            }
                            
                            Button(action: completeSession) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.green)
                                    .frame(width: 50, height: 50)
                                    .background(Circle().fill(Color(.secondarySystemGroupedBackground)))
                                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                            }
                        }
                    }
                    
                    // Ambient Soundscapes Selector Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "headphones")
                                .foregroundColor(.purple)
                            Text("Ambient Soundscapes")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                            Spacer()
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(SoundscapeType.allCases) { sound in
                                    Button(action: {
                                        soundManager.setSoundscape(sound)
                                        SoundHapticManager.shared.lightImpact()
                                    }) {
                                        HStack(spacing: 5) {
                                            Image(systemName: sound.icon)
                                                .font(.system(size: 11))
                                            Text(sound.rawValue)
                                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(soundManager.activeSoundscape == sound ? Color.purple : Color(.systemGray6))
                                        )
                                        .foregroundColor(soundManager.activeSoundscape == sound ? .white : .primary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .threeDCardEffect(maxTilt: 8, isInteractive: true, cornerRadius: 18)
                    .padding(.horizontal)
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("Focus & Mindfulness")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                stopTimer()
                soundManager.stopAudio()
            }
        }
    }
    
    private func selectPreset(minutes: Int) {
        stopTimer()
        totalSeconds = minutes * 60
        remainingSeconds = totalSeconds
        SoundHapticManager.shared.lightImpact()
    }
    
    private func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        isRunning = true
        SoundHapticManager.shared.mediumImpact()
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.15
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                completeSession()
            }
        }
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        withAnimation {
            pulseScale = 1.0
        }
        SoundHapticManager.shared.lightImpact()
    }
    
    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        withAnimation {
            pulseScale = 1.0
        }
    }
    
    private func resetTimer() {
        stopTimer()
        remainingSeconds = totalSeconds
        SoundHapticManager.shared.lightImpact()
    }
    
    private func completeSession() {
        stopTimer()
        remainingSeconds = 0
        if let habit = selectedHabit {
            habitStore.markHabitAsCompleted(habit)
        }
        SoundHapticManager.shared.celebrationFeedback()
    }
}

struct FocusTimerView_Previews: PreviewProvider {
    static var previews: some View {
        FocusTimerView()
            .environmentObject(HabitStore())
    }
}
