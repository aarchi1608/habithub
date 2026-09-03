//
//  ThreeDHabitCubeView.swift
//  HabitTracker
//

import SwiftUI

struct CubeFaceData: Identifiable {
    let id = UUID()
    let angle: Double
    let title: String
    let value: String
    let sub: String
    let icon: String
    let color: Color
    let gradient: [Color]
}

struct ThreeDHabitCubeView: View {
    @EnvironmentObject var habitStore: HabitStore
    
    @State private var rotY: Double = 0.0
    @State private var rotX: Double = -10.0
    @State private var dragOffset: CGFloat = 0.0
    
    private let cubeWidth: CGFloat = 175.0
    private let cubeHeight: CGFloat = 175.0
    
    private var faces: [CubeFaceData] {
        [
            CubeFaceData(
                angle: 0,
                title: "DAILY POWER",
                value: "\(habitStore.dailyPowerScore)%",
                sub: "\(habitStore.habits.filter { $0.isHabitCompleted }.count)/\(habitStore.habits.count) Done",
                icon: "bolt.fill",
                color: .yellow,
                gradient: [Color(hex: "#8B5CF6"), Color(hex: "#EC4899")]
            ),
            CubeFaceData(
                angle: 90,
                title: "BEST STREAK",
                value: "\(habitStore.habits.map { $0.calculateLongestStreak() }.max() ?? 0)d",
                sub: "Longest Record",
                icon: "flame.fill",
                color: .red,
                gradient: [Color(hex: "#F97316"), Color(hex: "#FB7185")]
            ),
            CubeFaceData(
                angle: 180,
                title: "XP & LEVEL",
                value: "LVL \(habitStore.userLevel)",
                sub: "\(habitStore.totalXP) XP Total",
                icon: "crown.fill",
                color: .orange,
                gradient: [Color(hex: "#F59E0B"), Color(hex: "#EF4444")]
            ),
            CubeFaceData(
                angle: 270,
                title: "SHIELDS",
                value: "\(habitStore.streakShieldsCount)",
                sub: "Active Shields",
                icon: "shield.fill",
                color: .cyan,
                gradient: [Color(hex: "#06B6D4"), Color(hex: "#3B82F6")]
            )
        ]
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background Cyber Radial Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.purple.opacity(0.35), Color.cyan.opacity(0.15), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 130
                        )
                    )
                    .frame(width: 250, height: 250)
                    .blur(radius: 20)
                
                // 3D Rotatable Faces
                ForEach(faces) { face in
                    let currentAngle = (face.angle + rotY).truncatingRemainder(dividingBy: 360)
                    let rad = currentAngle * .pi / 180.0
                    let depth = cos(rad)
                    let xOffset = sin(rad) * 90.0
                    let scale = 0.72 + max(0.0, depth) * 0.28
                    let opacity = depth > -0.2 ? (0.4 + (depth + 0.2) * 0.6) : 0.0
                    
                    cubeFaceView(face: face)
                        .scaleEffect(scale)
                        .offset(x: xOffset)
                        .rotation3DEffect(.degrees(currentAngle), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
                        .rotation3DEffect(.degrees(rotX), axis: (x: 1, y: 0, z: 0), perspective: 0.5)
                        .opacity(opacity)
                        .zIndex(depth)
                }
            }
            .frame(height: 220)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { val in
                        rotY += Double(val.translation.width - dragOffset) * 0.5
                        dragOffset = val.translation.width
                    }
                    .onEnded { _ in
                        dragOffset = 0.0
                        SoundHapticManager.shared.lightImpact()
                    }
            )
            
            // Interactive Face Quick-Jump Pills
            HStack(spacing: 8) {
                Button(action: { snapTo(angle: 0) }) {
                    Text("⚡ Power")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color(.secondarySystemGroupedBackground)))
                }
                
                Button(action: { snapTo(angle: -90) }) {
                    Text("🔥 Streak")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color(.secondarySystemGroupedBackground)))
                }
                
                Button(action: { snapTo(angle: -180) }) {
                    Text("👑 Level")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color(.secondarySystemGroupedBackground)))
                }
                
                Button(action: { snapTo(angle: -270) }) {
                    Text("🛡️ Shields")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color(.secondarySystemGroupedBackground)))
                }
            }
            
            Text("3D Habit Matrix Cube • Drag to inspect 🎲")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
    
    private func snapTo(angle: Double) {
        SoundHapticManager.shared.lightImpact()
        withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
            rotY = angle
            rotX = -10.0
        }
    }
    
    private func cubeFaceView(face: CubeFaceData) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: face.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(face.color)
                Text(face.title)
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .tracking(1.0)
            }
            
            Text(face.value)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.4), radius: 3)
            
            Text(face.sub)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(width: cubeWidth, height: cubeHeight)
        .background(
            LinearGradient(colors: face.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                .opacity(0.9)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.8), .clear, face.color.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 2
                )
        )
        .shadow(color: face.gradient.first?.opacity(0.5) ?? .clear, radius: 12)
    }
}

struct ThreeDHabitCubeView_Previews: PreviewProvider {
    static var previews: some View {
        ThreeDHabitCubeView()
            .environmentObject(HabitStore())
            .preferredColorScheme(.dark)
            .padding()
    }
}
