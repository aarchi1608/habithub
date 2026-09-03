//
//  AmbientSoundManager.swift
//  HabitTracker
//

import AVFoundation
import Foundation

enum SoundscapeType: String, CaseIterable, Identifiable {
    case off = "Mute"
    case rain = "Rain Drops"
    case waves = "Ocean Waves"
    case lofi = "Cyber Lo-Fi"
    case whiteNoise = "Deep Focus"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .off: return "speaker.slash.fill"
        case .rain: return "cloud.rain.fill"
        case .waves: return "water.waves"
        case .lofi: return "headphones"
        case .whiteNoise: return "waveform"
        }
    }
}

class AmbientSoundManager: ObservableObject {
    static let shared = AmbientSoundManager()
    
    @Published var activeSoundscape: SoundscapeType = .off
    @Published var volume: Float = 0.6
    
    private var audioEngine: AVAudioEngine?
    private var noiseNode: AVAudioSourceNode?
    
    private init() {}
    
    func setSoundscape(_ type: SoundscapeType) {
        activeSoundscape = type
        if type == .off {
            stopAudio()
        } else {
            playSynthesizedSoundscape(type)
        }
    }
    
    private func playSynthesizedSoundscape(_ type: SoundscapeType) {
        stopAudio()
        
        let engine = AVAudioEngine()
        let mainMixer = engine.mainMixerNode
        let sampleRate = mainMixer.outputFormat(forBus: 0).sampleRate
        
        var filterState: Float = 0.0
        
        let node = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0..<Int(frameCount) {
                // Generate soft filtered ambient noise
                let white = Float.random(in: -1.0...1.0)
                // Low-pass filter for soothing rain/wave acoustic feel
                filterState = 0.95 * filterState + 0.05 * white
                let sample = filterState * 0.25 * self.volume
                
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = sample
                }
            }
            return noErr
        }
        
        engine.attach(node)
        engine.connect(node, to: mainMixer, format: mainMixer.outputFormat(forBus: 0))
        
        do {
            try engine.start()
            self.audioEngine = engine
            self.noiseNode = node
        } catch {
            print("Failed to start ambient audio engine: \(error)")
        }
    }
    
    func stopAudio() {
        if let engine = audioEngine {
            engine.stop()
            if let node = noiseNode {
                engine.detach(node)
            }
            self.audioEngine = nil
            self.noiseNode = nil
        }
    }
}
