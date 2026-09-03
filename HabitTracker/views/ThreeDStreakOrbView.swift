//
//  ThreeDStreakOrbView.swift
//  HabitTracker
//

import SwiftUI

struct ThreeDStreakOrbView: View {
    let streakCount: Int
    let longestStreak: Int
    var primaryColor: Color = .orange
    var symbol: String = "flame.fill"
    
    @State private var rotationX: Double = 15.0
    @State private var rotationY: Double = 25.0
    @State private var rotationZ: Double = 0.0
    @State private var isSpinningAuto: Bool = true
    @State private var dragStart: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background Ambient 3D Glow
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                primaryColor.opacity(0.45),
                                primaryColor.opacity(0.1),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 12)
                
                // Outer 3D Gyroscope Ring 1 (Yaw axis)
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [primaryColor.opacity(0.8), primaryColor.opacity(0.1), primaryColor.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 155, height: 155)
                    .rotation3DEffect(.degrees(rotationX), axis: (x: 1, y: 0, z: 0))
                    .rotation3DEffect(.degrees(rotationY * 1.2), axis: (x: 0, y: 1, z: 0))
                
                // Outer 3D Gyroscope Ring 2 (Pitch axis)
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.pink.opacity(0.8), Color.orange.opacity(0.2), Color.yellow.opacity(0.8)],
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        ),
                        lineWidth: 2.5
                    )
                    .frame(width: 135, height: 135)
                    .rotation3DEffect(.degrees(rotationX * 1.3), axis: (x: 0, y: 1, z: 0))
                    .rotation3DEffect(.degrees(rotationY), axis: (x: 1, y: 0, z: 0))
                
                // Orbiting 3D Particle Nodes
                ForEach(0..<6, id: \.self) { i in
                    Circle()
                        .fill(LinearGradient(colors: [.white, primaryColor], startPoint: .top, endPoint: .bottom))
                        .frame(width: 8, height: 8)
                        .shadow(color: .white, radius: 4)
                        .offset(
                            x: 65 * cos(Double(i) * .pi / 3.0 + rotationZ * 0.02),
                            y: 65 * sin(Double(i) * .pi / 3.0 + rotationZ * 0.02)
                        )
                        .rotation3DEffect(.degrees(rotationX), axis: (x: 1, y: 0, z: 0))
                        .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0))
                }
                
                // Central Glowing 3D Glass Sphere Core
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [primaryColor.opacity(0.9), Color.red.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 86, height: 86)
                        .shadow(color: primaryColor.opacity(0.7), radius: 15, x: 0, y: 8)
                    
                    // Specular 3D highlight lens
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.75), Color.white.opacity(0.0)],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                        .frame(width: 78, height: 78)
                        .offset(x: -4, y: -4)
                    
                    // Icon & Streak Number
                    VStack(spacing: 2) {
                        Image(systemName: symbol)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                        
                        Text("\(streakCount)")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                    }
                    .rotation3DEffect(.degrees(-rotationX * 0.3), axis: (x: 1, y: 0, z: 0))
                    .rotation3DEffect(.degrees(-rotationY * 0.3), axis: (x: 0, y: 1, z: 0))
                }
                .rotation3DEffect(.degrees(rotationX), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0))
            }
            .frame(height: 190)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { val in
                        isSpinningAuto = false
                        rotationY += val.translation.width * 0.1
                        rotationX -= val.translation.height * 0.1
                    }
                    .onEnded { _ in
                        SoundHapticManager.shared.lightImpact()
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                            rotationX = 15.0
                            rotationY = 25.0
                        }
                    }
            )
            .onAppear {
                withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                    rotationZ = 360.0
                }
            }
            
            Text("3D Streak Orb • Drag to Spin 🪐")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}

struct ThreeDStreakOrbView_Previews: PreviewProvider {
    static var previews: some View {
        ThreeDStreakOrbView(streakCount: 14, longestStreak: 21)
            .padding()
            .preferredColorScheme(.dark)
    }
}
