# HabitHub 🪐

A next-generation, immersive habit-tracking iOS app built with **SwiftUI**, featuring **interactive 3D spatial effects**, **cyberpunk & neon visual themes**, **3D Habit Cube matrix**, **guided mindfulness breathing**, **habit routine stacks**, **daily mood tracking**, **ambient soundscapes**, and **gamified trophy achievements**.

---

## ✨ Features & Highlights

### 🪐 1. 3D Spatial Effects & Interactive Visuals
- **Interactive 3D Habit Matrix Cube**: A rotatable 3D matrix cube in Insights displaying your Daily Power, Best Streak, XP Level, and Streak Shields with touch-drag rotation.
- **3D Guided Mindfulness Breathing Orb**: Expandable 3D glowing sphere guiding 4-4-4-4 Box Breathing with synced tactile respiration haptics.
- **Interactive 3D Tilt Cards**: Habit and stat cards respond to touch with dynamic gyro-tilt, depth shadows, and specular light reflections.
- **3D Streak Gyroscope Orb**: An interactive 3D particle sphere in Habit Details with multi-axis planetary rings you can spin 360°.
- **3D Card Flip Animation**: Tap any stat card to flip it 180° in 3D space with backface culling to reveal deeper metrics.
- **3D Confetti Particle Bursts**: Particle celebration with 3D rotating stars and ribbons on habit completion.
- **3D Metallic Achievement Badges**: Holographic metallic foil badges with dynamic sheen and tilt physics.

### 🎨 2. Cyberpunk & Vibrant Color Themes
- **Live Theme Switcher**:
  - 🌌 **Neon Nebula** (Cyber Violet & Neon Pink)
  - ⚡ **Cyberpunk** (Dark Noir, Electric Cyan & Volt Yellow)
  - 🌅 **Sunset Blaze** (Midnight Ember & Sunset Orange)
  - 🌲 **Aurora Mint** (Dark Forest & Electric Mint)
  - 🔮 **Cosmic Violet** (Cosmic Dark & Deep Lavender)
  - ☀️ **Solar Gold** (Obsidian & Electric Amber)
  - 🌑 **Midnight Dark** (Deep Indigo & Cyber Blue)
- **16 Ultra-Vibrant Color Presets**: Electric Violet, Neon Cyan, Sunset Orange, Hot Magenta, Emerald Glow, Volt Yellow, Cyber Blue, Radiant Crimson, Coral Flame, Aqua Marine, and more.
- **8 Multi-Color Gradient Presets**: Cyber Neon, Sunset Flare, Toxic Lime, Cosmic Wave, Solar Heat, Aqua Glow, Berry Twilight, Neon Horizon.

### ⚡ 3. Routine Stacks, Mood & Habit Tracking
- **Habit Routine Stacks & Guided Flow**: Group habits into sequential routines (*🌅 Morning Ritual, ⚡ Deep Work, 🧘 Wellness, 🌙 Evening Reset*) with step-by-step guided execution.
- **Daily Mood & Energy Check-in**: Track daily mood and energy levels with history trends in Insights.
- **Ambient Focus Soundscapes**: Synthesized background audio during focus sessions (*Rain Drops, Ocean Waves, Cyber Lo-Fi, Deep Focus*).
- **Streak Freeze Shields**: Protect your streaks when life gets busy.
- **One-Tap Quick Checkmark**: Direct checkmark button on habit cards with spring bounce and celebratory haptics.
- **Habit Categories / Life Pillars**: Filter and categorize habits into *Fitness, Mindset, Productivity, Health, Finance, Creativity, Learning, and General*.
- **Daily Reflection Notes Log**: Write and save thoughts for each habit.
- **Daily Motivation & Power Score**: Dynamic daily habit power score meter with curated inspirational quotes.

### 🏆 4. Gamification & Trophy Room
- **XP & Leveling System**: Earn 50 XP per habit completion plus bonus XP for streak milestones. Level up from *Habit Novice* to *Legend of Consistency*.
- **Trophy Room**: Unlockable achievement badges (*First Step, 7-Day Ignition, 30-Day Titan, Century Club, Pillar Master, Perfectionist*).

### 📊 5. Deep Analytics & Insights
- **30-Day Activity Matrix**: Visual habit heatmap grid showing completion density across the month.
- **Habit Strength Index**: Recency-weighted adherence score calculating long-term consistency.
- **Mood Correlation**: Analyze how your mood and energy correlate with habit completion.

---

## 📱 App Navigation Structure

| Tab | Icon | Description |
|---|---|---|
| **Habits** | `checklist` | Active & completed habits, routine stacks, mood check-in, streak shields, and theme switcher |
| **Focus** | `timer` | 3D Focus Timer, 3D Guided Breathing mode, and ambient soundscapes |
| **Insights** | `chart.xyaxis.line` | 3D Habit Cube, 30-day activity matrix heatmap, and habit strength index |
| **Trophies** | `trophy.fill` | XP level progression and 3D metallic achievement badges |

---

## 🛠️ Tech Stack & Architecture

- **Platform**: iOS 16.4+
- **Language**: Swift 5.0
- **Framework**: SwiftUI (100% native declarative UI)
- **Audio & Soundscapes**: AVFoundation (`AVAudioEngine`, `AVAudioSourceNode`) / AudioToolbox
- **Haptics**: CoreHaptics / `UIImpactFeedbackGenerator` / `UINotificationFeedbackGenerator`
- **Persistence**: `UserDefaults` with JSON Codable serialization
- **Notifications**: `UserNotifications` framework for scheduled reminders
- **Zero External Dependencies**: Lightweight, fast, pure native Apple frameworks.

---

## 🚀 How to Launch & Run Locally

### Option 1: Via Xcode (Recommended)
1. Open the project in Xcode:
   ```bash
   open HabitTracker.xcodeproj
   ```
2. Select any iOS Simulator (e.g., **iPhone 17 Pro** or **iPhone 17**).
3. Press **`Cmd + R`** to build and run.

### Option 2: Via Terminal
1. Boot the Simulator:
   ```bash
   open -a Simulator
   xcrun simctl boot "iPhone 17 Pro"
   ```
2. Build and install:
   ```bash
   xcodebuild -project HabitTracker.xcodeproj -scheme HabitTracker -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
   xcrun simctl install booted ./build/Build/Products/Debug-iphonesimulator/HabitTracker.app
   xcrun simctl launch booted com.aarchi.habithub
   ```
