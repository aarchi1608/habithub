//
//  NoorCardModifier.swift
//  HabitHub
//

import SwiftUI

struct NoorCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 18
    var backgroundColor: Color = Color(hex: "#FFFFFF")
    var borderColor: Color = Color(hex: "#EBE1D3")
    var borderWidth: CGFloat = 1.0
    var shadowRadius: CGFloat = 6
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: Color(hex: "#2A2421").opacity(0.05), radius: shadowRadius, x: 0, y: 3)
    }
}

extension View {
    func noorCard(
        cornerRadius: CGFloat = 18,
        backgroundColor: Color = Color(hex: "#FFFFFF"),
        borderColor: Color = Color(hex: "#EBE1D3"),
        borderWidth: CGFloat = 1.0,
        shadowRadius: CGFloat = 6
    ) -> some View {
        self.modifier(
            NoorCardModifier(
                cornerRadius: cornerRadius,
                backgroundColor: backgroundColor,
                borderColor: borderColor,
                borderWidth: borderWidth,
                shadowRadius: shadowRadius
            )
        )
    }
}

struct NoorBackgroundView: View {
    var body: some View {
        ZStack {
            // Warm Cream / Champagne Base
            LinearGradient(
                colors: [
                    Color(hex: "#FBF8F3"),
                    Color(hex: "#F6EFE5"),
                    Color(hex: "#EFE6D8")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Soft Ambient Gold Glow Top-Right
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#D4A359").opacity(0.18),
                            Color(hex: "#EADCC9").opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 240
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: 140, y: -200)
                .blur(radius: 40)
            
            // Soft Emerald Glow Bottom-Left
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#244E3F").opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 200
                    )
                )
                .frame(width: 350, height: 350)
                .offset(x: -120, y: 300)
                .blur(radius: 50)
        }
    }
}
