//
//  SymbolPicker.swift
//  HabitTracker
//
//  Created by Saikat Kumar Dey on 27/07/23.
//

import SwiftUI

struct SymbolPicker: View {
    @EnvironmentObject var habit: Habit
    @State private var selectedColor: Color = ColorOptions.default
    @State private var selectedTab: Int = 0 // 0: Vibrant Colors, 1: Multi-Gradients
    @State private var searchInput = ""
    
    var filteredSymbols: [String] {
        if searchInput.isEmpty {
            return Array(HabitSymbols.symbolDescriptions.keys)
        } else {
            return HabitSymbols.symbolDescriptions.filter { key, value in
                value.lowercased().contains(searchInput.lowercased())
            }.map { $0.key }
        }
    }
    
    var columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        VStack(spacing: 16) {
            // Segmented Picker for Color Style
            Picker("Color Mode", selection: $selectedTab) {
                Text("Vibrant Colors (16)").tag(0)
                Text("Gradients (8)").tag(1)
            }
            .pickerStyle(.segmented)
            
            // Color Swatches Row
            if selectedTab == 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(ColorOptions.vibrantColors) { preset in
                            Button {
                                selectedColor = preset.color
                                habit.color = preset.color
                                SoundHapticManager.shared.lightImpact()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(preset.color)
                                        .frame(width: selectedColor == preset.color ? 36 : 28, height: selectedColor == preset.color ? 36 : 28)
                                        .shadow(color: preset.color.opacity(0.6), radius: selectedColor == preset.color ? 8 : 2)
                                    
                                    if selectedColor == preset.color {
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2.5)
                                            .frame(width: 38, height: 38)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(ColorOptions.gradientPresets) { grad in
                            Button {
                                selectedColor = grad.primaryColor
                                habit.color = grad.primaryColor
                                SoundHapticManager.shared.lightImpact()
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(LinearGradient(colors: grad.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 70, height: 36)
                                        .shadow(color: grad.primaryColor.opacity(0.5), radius: 6)
                                    
                                    Text(grad.name)
                                        .font(.system(size: 9, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.4), radius: 2)
                                    
                                    if selectedColor == grad.primaryColor {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(Color.white, lineWidth: 2)
                                            .frame(width: 72, height: 38)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                }
            }

            // Search Symbols Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search 50+ habit symbols...", text: $searchInput)
                    .font(.system(size: 14, design: .rounded))
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // Symbol Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filteredSymbols, id: \.self) { symbolItem in
                        Button(action: {
                            habit.symbol = symbolItem
                            SoundHapticManager.shared.lightImpact()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(
                                        habit.symbol == symbolItem ?
                                        selectedColor.opacity(0.2) : Color(.systemGray6).opacity(0.8)
                                    )
                                    .frame(height: 70)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(
                                                habit.symbol == symbolItem ? selectedColor : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                                
                                Image(systemName: symbolItem)
                                    .font(.system(size: 26, weight: .semibold))
                                    .foregroundColor(habit.symbol == symbolItem ? selectedColor : .primary)
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
        SymbolPicker()
            .environmentObject(habit)
            .padding()
    }
}
