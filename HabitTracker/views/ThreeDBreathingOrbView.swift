//
//  ThreeDBreathingOrbView.swift
//  HabitTracker
//

import SwiftUI

struct ThreeDBreathingOrbView: View {
    @State private var phaseText: String = "Inhale"
    @State private var scale: CGFloat = 0.75
    @State private var orbColor: Color = Color(hex: "#06B6D4")
    @State private var timer: Timer? = nil
    @State private var cycleSeconds: Int = 0
    @State private var isBreathingActive: Bool = true
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Expanding Radial Aura
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [orbColor.opacity(0.4), orbColor.opacity(0.1), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 140
                        )
                    )
                    .frame(width: 250, height: 250)
                    .scaleEffect(scale * 1.3)
                    .blur(radius: 16)
                
                // Outer 3D Gyro Wave Ring
                Circle()
                    .stroke(
                        LinearGradient(colors: [orbColor, .white, orbColor.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 3
                    )
                    .frame(width: 170, height: 170)
                    .scaleEffect(scale * 1.1)
                    .rotation3DEffect(.degrees(scale * 45), axis: (x: 1, y: 0, z: 0))
                
                // Central Glowing 3D Glass Sphere
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [orbColor, Color(hex: "#8B5CF6")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 110, height: 110)
                        .shadow(color: orbColor.opacity(0.7), radius: 20)
                    
                    // Specular 3D highlight lens
                    Circle()
                        .fill(
                            LinearGradient(colors: [.white.opacity(0.7), .clear], startPoint: .topLeading, endPoint: .center)
                        )
                        .frame(width: 90, height: 90)
                        .offset(x: -8, y: -8)
                    
                    VStack(spacing: 4) {
                        Image(systemName: "lungs.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                        
                        Text(phaseText)
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 2)
                    }
                }
                .scaleEffect(scale)
            }
            .frame(height: 230)
            .contentShape(Rectangle())
            .threeDCardEffect(maxTilt: 10, isInteractive: true, cornerRadius: 130)
            
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundColor(orbColor)
                Text("Box Breathing (4-4-4-4) • Center your mind")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            startBreathingCycle()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func startBreathingCycle() {
        timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            cycleSeconds = (cycleSeconds + 4) % 16
            
            switch cycleSeconds {
            case 0:
                phaseText = "Inhale"
                orbColor = Color(hex: "#06B6D4")
                SoundHapticManager.shared.lightImpact()
                withAnimation(.easeInOut(duration: 4.0)) {
                    scale = 1.15
                }
            case 4:
                phaseText = "Hold"
                orbColor = Color(hex: "#10B981")
                SoundHapticManager.shared.lightImpact()
            case 8:
                phaseText = "Exhale"
                orbColor = Color(hex: "#8B5CF6")
                SoundHapticManager.shared.lightImpact()
                withAnimation(.easeInOut(duration: 4.0)) {
                    scale = 0.75
                }
            case 12:
                phaseText = "Hold"
                orbColor = Color(hex: "#EC4899")
                SoundHapticManager.shared.lightImpact()
            default:
                break
            }
        }
        
        // Initial trigger
        withAnimation(.easeInOut(duration: 4.0)) {
            scale = 1.15
        }
    }
}

struct ThreeDBreathingOrbView_Previews: PreviewProvider {
    static var previews: some View {
        ThreeDBreathingOrbView()
            .padding()
            .preferredColorScheme(.dark)
    }
}
