//
//  FocusTimerView.swift
//  HabitHub
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
    
    private let presets = [5, 10, 15, 20, 25, 45]
    
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
            ZStack {
                NoorBackgroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Mode Selector (Focus Timer vs 3D Breathing)
                        Picker("Mode", selection: $focusModeSegment) {
                            Text("⏱️ Focus Timer").tag(0)
                            Text("🕊️ Calm Breathing").tag(1)
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
                                    HStack(spacing: 8) {
                                        Image(systemName: selectedHabit?.symbol ?? "target")
                                            .foregroundColor(Color(hex: "#C79546"))
                                        Text(selectedHabit?.title ?? "Select a Habit")
                                            .font(.system(size: 15, weight: .semibold, design: .serif))
                                            .foregroundColor(Color(hex: "#2B2420"))
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(Color(hex: "#8C7A6B"))
                                    }
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .noorCard(cornerRadius: 20)
                                }
                            }
                            
                            // Glowing Sand Gold Countdown Ring
                            ZStack {
                                Circle()
                                    .stroke(Color(hex: "#EBE1D3"), lineWidth: 14)
                                    .frame(width: 220, height: 220)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(progress))
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(hex: "#D4A359"), Color(hex: "#244E3F")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                                    )
                                    .frame(width: 220, height: 220)
                                    .rotationEffect(.degrees(-90))
                                    .shadow(color: Color(hex: "#D4A359").opacity(0.4), radius: 10)
                                
                                VStack(spacing: 6) {
                                    Text(timeString)
                                        .font(.system(size: 48, weight: .bold, design: .serif))
                                        .foregroundColor(Color(hex: "#2B2420"))
                                        .monospacedDigit()
                                    
                                    Text(isRunning ? "FOCUSING..." : (remainingSeconds == 0 ? "COMPLETED! 🎉" : "READY"))
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundColor(isRunning ? Color(hex: "#244E3F") : Color(hex: "#8C7A6B"))
                                        .tracking(1.5)
                                }
                            }
                            .frame(height: 240)
                            
                            // Quick Preset Buttons
                            HStack(spacing: 8) {
                                ForEach(presets, id: \.self) { mins in
                                    Button(action: {
                                        selectPreset(minutes: mins)
                                    }) {
                                        Text("\(mins)m")
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .foregroundColor(totalSeconds == mins * 60 ? .white : Color(hex: "#2B2420"))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(totalSeconds == mins * 60 ? Color(hex: "#244E3F") : Color(hex: "#FFFFFF"))
                                            )
                                            .overlay(
                                                Capsule().stroke(Color(hex: "#EBE1D3"), lineWidth: 1)
                                            )
                                    }
                                    .disabled(isRunning)
                                }
                            }
                            
                            // Action Control Buttons
                            HStack(spacing: 24) {
                                Button(action: resetTimer) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color(hex: "#8C7A6B"))
                                        .frame(width: 50, height: 50)
                                        .background(Circle().fill(Color(hex: "#FFFFFF")).overlay(Circle().stroke(Color(hex: "#EBE1D3"), lineWidth: 1)))
                                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                                }
                                
                                Button(action: toggleTimer) {
                                    HStack(spacing: 8) {
                                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                            .font(.system(size: 18, weight: .bold))
                                        Text(isRunning ? "PAUSE" : "START FOCUS")
                                            .font(.system(size: 15, weight: .bold, design: .serif))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 14)
                                    .background(
                                        Capsule()
                                            .fill(Color(hex: "#244E3F"))
                                            .shadow(color: Color(hex: "#244E3F").opacity(0.35), radius: 10, x: 0, y: 4)
                                    )
                                }
                                
                                Button(action: completeSession) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color(hex: "#244E3F"))
                                        .frame(width: 50, height: 50)
                                        .background(Circle().fill(Color(hex: "#FFFFFF")).overlay(Circle().stroke(Color(hex: "#EBE1D3"), lineWidth: 1)))
                                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                                }
                            }
                        }
                        
                        // Ambient Soundscapes Selector Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "headphones")
                                    .foregroundColor(Color(hex: "#C79546"))
                                Text("Ambient Focus Audio")
                                    .font(.system(size: 15, weight: .bold, design: .serif))
                                    .foregroundColor(Color(hex: "#2B2420"))
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
                                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(soundManager.activeSoundscape == sound ? Color(hex: "#244E3F") : Color(hex: "#FBF3E6"))
                                            )
                                            .foregroundColor(soundManager.activeSoundscape == sound ? .white : Color(hex: "#2B2420"))
                                            .overlay(
                                                Capsule().stroke(Color(hex: "#E8D8C0"), lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .noorCard(cornerRadius: 18)
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Focus & Mindfulness")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                stopTimer()
                soundManager.stopAudio()
            }
        }
        .navigationViewStyle(.stack)
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
            pulseScale = 1.12
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
