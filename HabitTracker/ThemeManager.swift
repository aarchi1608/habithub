//
//  ThemeManager.swift
//  HabitHub
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case noorEmerald = "✨ Noor Emerald & Gold"
    case sandIvory = "📜 Sand Ivory"
    case midnightForest = "🌲 Midnight Forest"
    case amberWarmth = "☀️ Amber Warmth"
    case royalTeal = "🌊 Royal Teal"
    
    var id: String { rawValue }
    
    var primaryAccent: Color {
        switch self {
        case .noorEmerald: return Color(hex: "#244E3F")
        case .sandIvory: return Color(hex: "#C79546")
        case .midnightForest: return Color(hex: "#1A3D31")
        case .amberWarmth: return Color(hex: "#D97706")
        case .royalTeal: return Color(hex: "#0F766E")
        }
    }
    
    var goldAccent: Color {
        return Color(hex: "#D4A359")
    }
    
    var backgroundColors: [Color] {
        switch self {
        case .noorEmerald, .sandIvory, .amberWarmth:
            return [Color(hex: "#FBF8F3"), Color(hex: "#F6EFE5"), Color(hex: "#EFE6D8")]
        case .midnightForest, .royalTeal:
            return [Color(hex: "#0A1712"), Color(hex: "#12261F"), Color(hex: "#08120E")]
        }
    }
    
    var cardBackground: Color {
        switch self {
        case .noorEmerald, .sandIvory, .amberWarmth:
            return Color(hex: "#FFFFFF")
        default:
            return Color(hex: "#142820").opacity(0.8)
        }
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    private let storageKey = "habithub_selected_app_theme"
    
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: storageKey)
        }
    }
    
    private init() {
        if let savedTheme = UserDefaults.standard.string(forKey: storageKey),
           let theme = AppTheme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .noorEmerald
        }
    }
}
