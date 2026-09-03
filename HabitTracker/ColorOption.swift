//
//  ColorOption.swift
//  HabitHub
//

import SwiftUI

struct ColorPreset: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let color: Color
    let hex: String
}

struct GradientPreset: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let colors: [Color]
    let primaryColor: Color
}

struct ColorOptions: Codable {
    // 16 Ultra-Vibrant Neon & Modern Cyberpunk Color Presets
    static let vibrantColors: [ColorPreset] = [
        ColorPreset(name: "Electric Violet", color: Color(hex: "#8B5CF6"), hex: "#8B5CF6"),
        ColorPreset(name: "Neon Cyan", color: Color(hex: "#06B6D4"), hex: "#06B6D4"),
        ColorPreset(name: "Sunset Orange", color: Color(hex: "#F97316"), hex: "#F97316"),
        ColorPreset(name: "Hot Magenta", color: Color(hex: "#EC4899"), hex: "#EC4899"),
        ColorPreset(name: "Emerald Glow", color: Color(hex: "#10B981"), hex: "#10B981"),
        ColorPreset(name: "Volt Yellow", color: Color(hex: "#EAB308"), hex: "#EAB308"),
        ColorPreset(name: "Cyber Blue", color: Color(hex: "#3B82F6"), hex: "#3B82F6"),
        ColorPreset(name: "Radiant Crimson", color: Color(hex: "#EF4444"), hex: "#EF4444"),
        ColorPreset(name: "Coral Flame", color: Color(hex: "#FB7185"), hex: "#FB7185"),
        ColorPreset(name: "Deep Lavender", color: Color(hex: "#A855F7"), hex: "#A855F7"),
        ColorPreset(name: "Aqua Marine", color: Color(hex: "#14B8A6"), hex: "#14B8A6"),
        ColorPreset(name: "Golden Solar", color: Color(hex: "#F59E0B"), hex: "#F59E0B"),
        ColorPreset(name: "Electric Indigo", color: Color(hex: "#6366F1"), hex: "#6366F1"),
        ColorPreset(name: "Lime Spark", color: Color(hex: "#84CC16"), hex: "#84CC16"),
        ColorPreset(name: "Rose Quartz", color: Color(hex: "#F43F5E"), hex: "#F43F5E"),
        ColorPreset(name: "Sky Breeze", color: Color(hex: "#0EA5E9"), hex: "#0EA5E9")
    ]
    
    static let gradientPresets: [GradientPreset] = [
        GradientPreset(name: "Cyber Neon", colors: [Color(hex: "#06B6D4"), Color(hex: "#8B5CF6")], primaryColor: Color(hex: "#06B6D4")),
        GradientPreset(name: "Sunset Flare", colors: [Color(hex: "#F97316"), Color(hex: "#EC4899")], primaryColor: Color(hex: "#F97316")),
        GradientPreset(name: "Toxic Lime", colors: [Color(hex: "#84CC16"), Color(hex: "#10B981")], primaryColor: Color(hex: "#84CC16")),
        GradientPreset(name: "Cosmic Wave", colors: [Color(hex: "#6366F1"), Color(hex: "#EC4899")], primaryColor: Color(hex: "#6366F1")),
        GradientPreset(name: "Solar Heat", colors: [Color(hex: "#EAB308"), Color(hex: "#EF4444")], primaryColor: Color(hex: "#EAB308")),
        GradientPreset(name: "Aqua Glow", colors: [Color(hex: "#14B8A6"), Color(hex: "#3B82F6")], primaryColor: Color(hex: "#14B8A6")),
        GradientPreset(name: "Berry Twilight", colors: [Color(hex: "#A855F7"), Color(hex: "#F43F5E")], primaryColor: Color(hex: "#A855F7")),
        GradientPreset(name: "Neon Horizon", colors: [Color(hex: "#FB7185"), Color(hex: "#F59E0B")], primaryColor: Color(hex: "#FB7185"))
    ]
    
    static var all: [Color] {
        vibrantColors.map { $0.color }
    }
    
    static var `default`: Color = Color(hex: "#8B5CF6")
    
    static func random() -> Color {
        vibrantColors.randomElement()?.color ?? `default`
    }
}

#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#elseif os(macOS)
import AppKit
#endif

fileprivate extension Color {
    #if os(macOS)
    typealias SystemColor = NSColor
    #else
    typealias SystemColor = UIColor
    #endif
    
    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        #if os(macOS)
        SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        #else
        guard SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return nil
        }
        #endif
        
        return (r, g, b, a)
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        
        self.init(red: r, green: g, blue: b)
    }

    public func encode(to encoder: Encoder) throws {
        guard let colorComponents = self.colorComponents else {
            return
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(colorComponents.red, forKey: .red)
        try container.encode(colorComponents.green, forKey: .green)
        try container.encode(colorComponents.blue, forKey: .blue)
    }
}
