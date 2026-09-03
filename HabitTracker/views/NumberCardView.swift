//
//  NumberCardView.swift
//  HabitHub
//

import SwiftUI

struct NumberCard: View {
    let number: Int
    let text: String
    var fillColor: Color = .green
    var iconColor: Color = .secondary
    let icon: String
    var subtitle: String = "Tap to flip 3D"
    var backTitle: String = "Metric Detail"
    var backValue: String = "100%"
    var backDescription: String = "Consistency Score"
    
    @State private var isFlipped: Bool = false
    @State private var flipAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Front Side
            frontCard
                .opacity(flipAngle < 90 ? 1 : 0)
                .rotation3DEffect(.degrees(flipAngle), axis: (x: 0, y: 1, z: 0))
            
            // Back Side
            backCard
                .opacity(flipAngle >= 90 ? 1 : 0)
                .rotation3DEffect(.degrees(flipAngle + 180), axis: (x: 0, y: 1, z: 0))
        }
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .onTapGesture {
            SoundHapticManager.shared.lightImpact()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isFlipped.toggle()
                flipAngle += 180
            }
        }
        .threeDCardEffect(maxTilt: 12, isInteractive: true, cornerRadius: 18)
    }
    
    private var frontCard: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 20, weight: .bold))
                Text(text)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            
            Text("\(number)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(iconColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var backCard: some View {
        VStack(spacing: 8) {
            HStack {
                Text(backTitle)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(iconColor)
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
            }
            
            Text(backValue)
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(.primary)
            
            Text(backDescription)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(iconColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// Preview
struct NumberCard_Previews: PreviewProvider {
    static var previews: some View {
        NumberCard(
            number: 14,
            text: "Current Streak",
            iconColor: .orange,
            icon: "flame.fill"
        )
        .padding()
    }
}
