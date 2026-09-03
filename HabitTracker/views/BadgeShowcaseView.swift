//
//  BadgeShowcaseView.swift
//  HabitHub
//

import SwiftUI

struct BadgeShowcaseView: View {
    @EnvironmentObject var habitStore: HabitStore
    
    var body: some View {
        NavigationView {
            ZStack {
                NoorBackgroundView()
                
                ScrollView {
                    VStack(spacing: 22) {
                        // Level & XP Hero Card
                        VStack(spacing: 16) {
                            HStack(alignment: .center, spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "#D4A359"), Color(hex: "#244E3F")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 60, height: 60)
                                        .shadow(color: Color(hex: "#D4A359").opacity(0.3), radius: 8, x: 0, y: 4)
                                    
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 26, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("LEVEL \(habitStore.userLevel)")
                                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                                            .foregroundColor(Color(hex: "#244E3F"))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Capsule().fill(Color(hex: "#FBF3E6")).overlay(Capsule().stroke(Color(hex: "#E8D8C0"), lineWidth: 1)))
                                        
                                        Spacer()
                                        
                                        Text("\(habitStore.totalXP) XP")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(Color(hex: "#2B2420"))
                                    }
                                    
                                    Text(habitStore.levelTitle)
                                        .font(.system(size: 20, weight: .bold, design: .serif))
                                        .foregroundColor(Color(hex: "#2B2420"))
                                }
                            }
                            
                            // XP Progress to next level
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Progress to Next Level")
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(hex: "#8C7A6B"))
                                    
                                    Spacer()
                                    
                                    Text("\(Int(habitStore.levelProgress * 100))%")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "#244E3F"))
                                }
                                
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color(hex: "#EBE1D3"))
                                            .frame(height: 8)
                                        
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(hex: "#244E3F"), Color(hex: "#D4A359")],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: max(8, geo.size.width * CGFloat(habitStore.levelProgress)), height: 8)
                                    }
                                }
                                .frame(height: 8)
                            }
                        }
                        .padding(20)
                        .noorCard(cornerRadius: 22)
                        
                        // Badges Grid
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(Color(hex: "#D4A359"))
                                Text("Achievement Badges")
                                    .font(.system(size: 18, weight: .bold, design: .serif))
                                    .foregroundColor(Color(hex: "#2B2420"))
                                
                                Spacer()
                                
                                Text("\(habitStore.allBadges.filter { $0.isUnlocked }.count)/\(habitStore.allBadges.count)")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#244E3F"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(Color(hex: "#FBF3E6")).overlay(Capsule().stroke(Color(hex: "#E8D8C0"), lineWidth: 1)))
                            }
                            
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                                ForEach(habitStore.allBadges) { badge in
                                    ThreeDBadgeCard(badge: badge)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Trophies & Badges")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}

struct BadgeShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeShowcaseView()
            .environmentObject(HabitStore())
    }
}
