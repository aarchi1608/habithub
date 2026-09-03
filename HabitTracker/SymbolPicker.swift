//
//  SymbolPicker.swift
//  HabitHub
//

import SwiftUI

struct SymbolPicker: View {
    @EnvironmentObject var habit: Habit
    @State private var selectedColor: Color = ColorOptions.default
    @State private var searchInput = ""
    
    // Noor-curated luxury color palette
    private let noorColors: [ColorPreset] = [
        ColorPreset(name: "Deep Emerald", color: Color(hex: "#244E3F"), hex: "#244E3F"),
        ColorPreset(name: "Warm Gold", color: Color(hex: "#D4A359"), hex: "#D4A359"),
        ColorPreset(name: "Amber Sand", color: Color(hex: "#C79546"), hex: "#C79546"),
        ColorPreset(name: "Royal Teal", color: Color(hex: "#0F766E"), hex: "#0F766E"),
        ColorPreset(name: "Terracotta", color: Color(hex: "#C2593F"), hex: "#C2593F"),
        ColorPreset(name: "Rose Bronze", color: Color(hex: "#B4697E"), hex: "#B4697E"),
        ColorPreset(name: "Forest Sage", color: Color(hex: "#4D7C5D"), hex: "#4D7C5D"),
        ColorPreset(name: "Obsidian Slate", color: Color(hex: "#374151"), hex: "#374151"),
        ColorPreset(name: "Electric Cyan", color: Color(hex: "#06B6D4"), hex: "#06B6D4"),
        ColorPreset(name: "Sunset Orange", color: Color(hex: "#F97316"), hex: "#F97316"),
        ColorPreset(name: "Lavender", color: Color(hex: "#8B5CF6"), hex: "#8B5CF6"),
        ColorPreset(name: "Crimson", color: Color(hex: "#E11D48"), hex: "#E11D48")
    ]
    
    var filteredSymbols: [String] {
        if searchInput.isEmpty {
            return Array(HabitSymbols.symbolDescriptions.keys)
        } else {
            return HabitSymbols.symbolDescriptions.filter { key, value in
                value.lowercased().contains(searchInput.lowercased())
            }.map { $0.key }
        }
    }
    
    var columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        VStack(spacing: 16) {
            // Color Swatches Row
            VStack(alignment: .leading, spacing: 8) {
                Text("ACCENT COLOR")
                    .font(.system(size: 11, weight: .bold, design: .serif))
                    .foregroundColor(Color(hex: "#8C7A6B"))
                    .tracking(1.0)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(noorColors) { preset in
                            Button {
                                selectedColor = preset.color
                                habit.color = preset.color
                                SoundHapticManager.shared.lightImpact()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(preset.color)
                                        .frame(width: selectedColor == preset.color ? 34 : 26, height: selectedColor == preset.color ? 34 : 26)
                                        .shadow(color: preset.color.opacity(0.4), radius: selectedColor == preset.color ? 6 : 2)
                                    
                                    if selectedColor == preset.color {
                                        Circle()
                                            .stroke(Color(hex: "#D4A359"), lineWidth: 2)
                                            .frame(width: 38, height: 38)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                }
            }
            .padding(14)
            .noorCard(cornerRadius: 16)

            // Search Symbols Field
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(hex: "#8C7A6B"))
                TextField("Search 50+ habit symbols...", text: $searchInput)
                    .font(.system(size: 14, design: .rounded))
            }
            .padding(12)
            .noorCard(cornerRadius: 14)

            // Symbol Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(filteredSymbols, id: \.self) { symbolItem in
                        Button(action: {
                            habit.symbol = symbolItem
                            SoundHapticManager.shared.lightImpact()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(
                                        habit.symbol == symbolItem ?
                                        Color(hex: "#FBF3E6") : Color(hex: "#FFFFFF")
                                    )
                                    .frame(height: 56)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(
                                                habit.symbol == symbolItem ? Color(hex: "#D4A359") : Color(hex: "#EBE1D3"),
                                                lineWidth: habit.symbol == symbolItem ? 1.5 : 1
                                            )
                                    )
                                
                                Image(systemName: symbolItem)
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(habit.symbol == symbolItem ? Color(hex: "#244E3F") : Color(hex: "#8C7A6B"))
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(maxHeight: 220)
        }
        .onAppear {
            selectedColor = habit.color
        }
    }
}

struct SymbolPicker_Previews: PreviewProvider {
    static var previews: some View {
        let habit = Habit(title: "Test")
        ZStack {
            NoorBackgroundView()
            SymbolPicker()
                .environmentObject(habit)
                .padding()
        }
    }
}
