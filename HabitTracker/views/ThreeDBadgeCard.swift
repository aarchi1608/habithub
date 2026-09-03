//
//  ThreeDBadgeCard.swift
//  HabitTracker
//

import SwiftUI

struct ThreeDBadgeCard: View {
    let badge: HabitBadge
    @State private var dragOffset: CGSize = .zero
    @State private var isTouching: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Outer 3D Hexagon / Shield Backdrop
                Circle()
                    .fill(
                        badge.isUnlocked ?
                        LinearGradient(
                            colors: [
                                Color(hex: badge.colorHex),
                                Color(hex: badge.colorHex).opacity(0.6),
                                Color.white.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 76, height: 76)
                    .shadow(
                        color: badge.isUnlocked ? Color(hex: badge.colorHex).opacity(0.5) : Color.clear,
                        radius: 10,
                        x: 0,
                        y: 5
                    )
                
                // Holographic Specular Rim
                Circle()
                    .stroke(
                        badge.isUnlocked ?
                        LinearGradient(
                            colors: [.white.opacity(0.9), .clear, Color(hex: badge.colorHex)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        :
                        LinearGradient(
                            colors: [.white.opacity(0.2), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 74, height: 74)
                
                // Badge Icon
                Image(systemName: badge.isUnlocked ? badge.icon : "lock.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(badge.isUnlocked ? .white : .secondary)
                    .shadow(color: .black.opacity(0.3), radius: 3)
            }
            .rotation3DEffect(.degrees(Double(-dragOffset.height / 5.0)), axis: (x: 1, y: 0, z: 0))
            .rotation3DEffect(.degrees(Double(dragOffset.width / 5.0)), axis: (x: 0, y: 1, z: 0))
            
            VStack(spacing: 4) {
                Text(badge.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(badge.description)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(minHeight: 28)
            }
            
            // Status Tag
            HStack(spacing: 4) {
                Image(systemName: badge.isUnlocked ? "checkmark.seal.fill" : "lock.fill")
                    .font(.system(size: 9, weight: .bold))
                Text(badge.isUnlocked ? "UNLOCKED" : badge.requirementText)
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
            }
            .foregroundColor(badge.isUnlocked ? Color(hex: badge.colorHex) : .secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(badge.isUnlocked ? Color(hex: badge.colorHex).opacity(0.15) : Color.gray.opacity(0.15))
            )
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            badge.isUnlocked ?
                            LinearGradient(
                                colors: [Color(hex: badge.colorHex).opacity(0.4), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            :
                            LinearGradient(colors: [Color.white.opacity(0.1), .clear], startPoint: .top, endPoint: .bottom),
                            lineWidth: 1
                        )
                )
        )
        .threeDCardEffect(maxTilt: 16.0, isInteractive: true, cornerRadius: 20)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 122, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
