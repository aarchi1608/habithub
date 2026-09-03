//
//  Onboarding.swift
//  HabitHub
//

import SwiftUI

struct OnboardingItem: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String
    var icon: String
    var colors: [Color]
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingItem] = [
        OnboardingItem(
            title: "Welcome to HabitHub",
            subtitle: "Build atomic habits, master your daily discipline, and unlock your true potential.",
            icon: "sparkles",
            colors: [.purple, .blue]
        ),
        OnboardingItem(
            title: "3D Spatial Tracking",
            subtitle: "Interact with 3D Habit Cubes, gyroscope streak orbs, and holographic trophy badges.",
            icon: "cube.transparent.fill",
            colors: [.cyan, .blue]
        ),
        OnboardingItem(
            title: "Routines & Focus Timer",
            subtitle: "Execute guided habit routine stacks with ambient focus soundscapes & 3D breathing.",
            icon: "timer",
            colors: [.orange, .red]
        ),
        OnboardingItem(
            title: "You're All Set!",
            subtitle: "Start building your unshakeable daily consistency streak right now.",
            icon: "checkmark.seal.fill",
            colors: [.green, .mint]
        )
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 24) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        let item = pages[index]
                        VStack(spacing: 24) {
                            Spacer()
                            
                            // 3D Card Icon
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [item.colors.first?.opacity(0.35) ?? .purple, Color.clear],
                                            center: .center,
                                            startRadius: 20,
                                            endRadius: 100
                                        )
                                    )
                                    .frame(width: 200, height: 200)
                                    .blur(radius: 10)
                                
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: item.colors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                    .shadow(color: item.colors.first?.opacity(0.5) ?? .purple, radius: 15, x: 0, y: 8)
                                
                                Image(systemName: item.icon)
                                    .font(.system(size: 52, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .threeDCardEffect(maxTilt: 15, isInteractive: true, cornerRadius: 60)
                            
                            VStack(spacing: 10) {
                                Text(item.title)
                                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                
                                Text(item.subtitle)
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                            
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                // Bottom Action Button
                Button(action: {
                    SoundHapticManager.shared.lightImpact()
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        hasCompletedOnboarding = true
                    }
                }) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: pages[currentPage].colors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: pages[currentPage].colors.first?.opacity(0.4) ?? .blue, radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 20)
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasCompletedOnboarding: .constant(false))
            .preferredColorScheme(.dark)
    }
}
