//
//  ThreeDCardModifier.swift
//  HabitTracker
//

import SwiftUI

struct ThreeDCardModifier: ViewModifier {
    var maxTilt: Double = 14.0
    var isInteractive: Bool = true
    var cornerRadius: CGFloat = 18.0
    
    @State private var dragOffset: CGSize = .zero
    @State private var isTouching: Bool = false
    
    var rotationX: Double {
        guard isInteractive else { return 0 }
        let normalized = max(-1.0, min(1.0, dragOffset.height / 80.0))
        return -normalized * maxTilt
    }
    
    var rotationY: Double {
        guard isInteractive else { return 0 }
        let normalized = max(-1.0, min(1.0, dragOffset.width / 120.0))
        return normalized * maxTilt
    }
    
    var shineLocationX: CGFloat {
        let normalized = (dragOffset.width / 120.0) + 0.5
        return max(0.1, min(0.9, normalized))
    }
    
    var shineLocationY: CGFloat {
        let normalized = (dragOffset.height / 80.0) + 0.5
        return max(0.1, min(0.9, normalized))
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                // Dynamic 3D Specular Light Sheen
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(isTouching ? 0.22 : 0.05),
                        Color.white.opacity(0.0)
                    ]),
                    center: UnitPoint(x: shineLocationX, y: shineLocationY),
                    startRadius: 5,
                    endRadius: 180
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .allowsHitTesting(false)
            )
            .rotation3DEffect(
                .degrees(rotationX),
                axis: (x: 1.0, y: 0.0, z: 0.0),
                perspective: 0.7
            )
            .rotation3DEffect(
                .degrees(rotationY),
                axis: (x: 0.0, y: 1.0, z: 0.0),
                perspective: 0.7
            )
            .scaleEffect(isTouching ? 1.02 : 1.0)
            .shadow(
                color: Color.black.opacity(isTouching ? 0.25 : 0.08),
                radius: isTouching ? 18 : 8,
                x: isTouching ? dragOffset.width * 0.15 : 0,
                y: isTouching ? dragOffset.height * 0.15 + 10 : 4
            )
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: dragOffset)
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isTouching)
            .simultaneousGesture(
                isInteractive ?
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        dragOffset = value.translation
                        if !isTouching {
                            isTouching = true
                            SoundHapticManager.shared.lightImpact()
                        }
                    }
                    .onEnded { _ in
                        dragOffset = .zero
                        isTouching = false
                    }
                : nil
            )
    }
}

extension View {
    func threeDCardEffect(maxTilt: Double = 14.0, isInteractive: Bool = true, cornerRadius: CGFloat = 18.0) -> some View {
        self.modifier(ThreeDCardModifier(maxTilt: maxTilt, isInteractive: isInteractive, cornerRadius: cornerRadius))
    }
}
