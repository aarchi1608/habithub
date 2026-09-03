//
//  ThemeManager.swift
//  HabitTracker
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case neonNebula = "Neon Nebula"
    case cyberpunk = "Cyberpunk"
    case sunsetBlaze = "Sunset Blaze"
    case aurora = "Aurora Mint"
    case cosmic = "Cosmic Violet"
    case solar = "Solar Gold"
    case midnight = "Midnight Dark"
    
    var id: String { rawValue }
    
    var primaryAccent: Color {
        switch self {
        case .neonNebula: return Color(hex: "#8B5CF6")
        case .cyberpunk: return Color(hex: "#06B6D4")
        case .sunsetBlaze: return Color(hex: "#F97316")
        case .aurora: return Color(hex: "#10B981")
        case .cosmic: return Color(hex: "#EC4899")
        case .solar: return Color(hex: "#F59E0B")
        case .midnight: return Color(hex: "#6366F1")
        }
    }
    
    var secondaryAccent: Color {
        switch self {
        case .neonNebula: return Color(hex: "#EC4899")
        case .cyberpunk: return Color(hex: "#EAB308")
        case .sunsetBlaze: return Color(hex: "#EF4444")
        case .aurora: return Color(hex: "#06B6D4")
        case .cosmic: return Color(hex: "#8B5CF6")
        case .solar: return Color(hex: "#EF4444")
        case .midnight: return Color(hex: "#A855F7")
        }
    }
    
    var gradientColors: [Color] {
        [primaryAccent, secondaryAccent]
    }
    
    var backgroundGradient: LinearGradient {
        switch self {
        case .neonNebula:
            return LinearGradient(
                colors: [Color(hex: "#0D0B18"), Color(hex: "#16102B"), Color(hex: "#080611")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cyberpunk:
            return LinearGradient(
                colors: [Color(hex: "#07111E"), Color(hex: "#0B1D2C"), Color(hex: "#040910")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sunsetBlaze:
            return LinearGradient(
                colors: [Color(hex: "#1A0A10"), Color(hex: "#260F16"), Color(hex: "#0F0509")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .aurora:
            return LinearGradient(
                colors: [Color(hex: "#061512"), Color(hex: "#0A241E"), Color(hex: "#040D0B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cosmic:
            return LinearGradient(
                colors: [Color(hex: "#150A21"), Color(hex: "#220F35"), Color(hex: "#0C0514")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .solar:
            return LinearGradient(
                colors: [Color(hex: "#181205"), Color(hex: "#261D09"), Color(hex: "#0E0A03")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .midnight:
            return LinearGradient(
                colors: [Color(hex: "#0A0C14"), Color(hex: "#121724"), Color(hex: "#05070A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("selected_app_theme") var currentThemeRaw: String = AppTheme.neonNebula.rawValue
    
    var currentTheme: AppTheme {
        get {
            AppTheme(rawValue: currentThemeRaw) ?? .neonNebula
        }
        set {
            currentThemeRaw = newValue.rawValue
            objectWillChange.send()
        }
    }
}
