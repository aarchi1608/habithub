//
//  BadgeShowcaseView.swift
//  HabitTracker
//

import SwiftUI

struct BadgeShowcaseView: View {
    @EnvironmentObject var habitStore: HabitStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Level & XP Hero 3D Card
                    VStack(spacing: 16) {
                        HStack(alignment: .center, spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 64, height: 64)
                                    .shadow(color: .orange.opacity(0.6), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("LEVEL \(habitStore.userLevel)")
                                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                                        .foregroundColor(.orange)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Capsule().fill(Color.orange.opacity(0.18)))
                                    
                                    Spacer()
                                    
                                    Text("\(habitStore.totalXP) XP")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                }
                                
                                Text(habitStore.levelTitle)
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        // XP Progress to next level
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Progress to Next Level")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(Int(habitStore.levelProgress * 100))%")
                                    .font(.caption.bold())
                                    .foregroundColor(.orange)
                            }
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 10)
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.yellow, .orange, .red],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: max(10, geo.size.width * CGFloat(habitStore.levelProgress)), height: 10)
                                }
                            }
                            .frame(height: 10)
                        }
                    }
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .threeDCardEffect(maxTilt: 12, isInteractive: true, cornerRadius: 22)
                    
                    // Badges Grid
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                            Text("3D Achievement Badges")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Spacer()
                            Text("\(habitStore.allBadges.filter { $0.isUnlocked }.count)/\(habitStore.allBadges.count)")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 16) {
                            ForEach(habitStore.allBadges) { badge in
                                ThreeDBadgeCard(badge: badge)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Trophy Room")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct BadgeShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeShowcaseView()
            .environmentObject(HabitStore())
    }
}
