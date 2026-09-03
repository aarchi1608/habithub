//
//  ConfettiBurstView.swift
//  HabitTracker
//

import SwiftUI

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var rotationX: Double
    var rotationY: Double
    var rotationZ: Double
    var opacity: Double
    var shapeType: Int // 0: rect, 1: circle, 2: star
}

struct ConfettiBurstView: View {
    @Binding var trigger: Int
    @State private var particles: [ConfettiParticle] = []
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan, .mint]
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Group {
                    if particle.shapeType == 0 {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(particle.color)
                            .frame(width: particle.size, height: particle.size * 0.5)
                    } else if particle.shapeType == 1 {
                        Circle()
                            .fill(particle.color)
                            .frame(width: particle.size, height: particle.size)
                    } else {
                        Image(systemName: "star.fill")
                            .font(.system(size: particle.size))
                            .foregroundColor(particle.color)
                    }
                }
                .rotation3DEffect(.degrees(particle.rotationX), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.degrees(particle.rotationY), axis: (x: 0, y: 1, z: 0))
                .rotationEffect(.degrees(particle.rotationZ))
                .opacity(particle.opacity)
                .position(x: particle.x, y: particle.y)
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .onChange(of: trigger) { _ in
            spawnBurst()
        }
    }
    
    private func spawnBurst() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let originX = screenWidth / 2
        let originY = screenHeight * 0.4
        
        var newParticles: [ConfettiParticle] = []
        for _ in 0..<45 {
            let p = ConfettiParticle(
                x: originX,
                y: originY,
                size: CGFloat.random(in: 8...16),
                color: colors.randomElement() ?? .yellow,
                rotationX: Double.random(in: 0...360),
                rotationY: Double.random(in: 0...360),
                rotationZ: Double.random(in: 0...360),
                opacity: 1.0,
                shapeType: Int.random(in: 0...2)
            )
            newParticles.append(p)
        }
        self.particles = newParticles
        
        // Explode outward with 3D animation
        withAnimation(.easeOut(duration: 1.6)) {
            for i in 0..<particles.count {
                let angle = Double.random(in: 0...(2 * .pi))
                let distance = CGFloat.random(in: 80...260)
                particles[i].x = originX + cos(angle) * distance
                particles[i].y = originY + sin(angle) * distance + CGFloat.random(in: 60...180)
                particles[i].rotationX += Double.random(in: 360...1080)
                particles[i].rotationY += Double.random(in: 360...1080)
                particles[i].rotationZ += Double.random(in: 180...720)
                particles[i].opacity = 0.0
            }
        }
        
        // Clear particles after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            if trigger != 0 {
                particles.removeAll()
            }
        }
    }
}
