import AVFoundation
import UIKit

final class SoundManager: @unchecked Sendable {
    static let shared = SoundManager()
    private var players: [String: AVAudioPlayer] = [:]
    private var musicPlayer: AVAudioPlayer?
    private var isMusicPlaying = false

    private init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {}

        prepareSound("eat", frequency: 880, duration: 0.08, volume: 0.3)
        prepareSound("eatRare", frequency: 1200, duration: 0.12, volume: 0.35)
        prepareSound("munch", frequency: 660, duration: 0.10, volume: 0.3)
        prepareSound("jump", frequency: 520, duration: 0.1, volume: 0.2, sweep: 800)
        prepareSound("hit", frequency: 180, duration: 0.2, volume: 0.4)
        prepareSound("land", frequency: 200, duration: 0.06, volume: 0.15)
        prepareSound("gameOver", frequency: 400, duration: 0.4, volume: 0.35, sweep: 120)
        prepareSound("caw", frequency: 600, duration: 0.18, volume: 0.25, sweep: 350)
        prepareSound("ribbit", frequency: 250, duration: 0.15, volume: 0.3, sweep: 450)
        prepareSound("hiss", frequency: 300, duration: 0.25, volume: 0.3, sweep: 150) // snake/scorpion
        prepareSound("screech", frequency: 800, duration: 0.15, volume: 0.2, sweep: 500) // bat/hawk
        prepareSound("buzz", frequency: 350, duration: 0.10, volume: 0.15, sweep: 400) // flies/gnats
        prepareSound("chirp", frequency: 1000, duration: 0.06, volume: 0.2) // cricket/beetle
        prepareSound("hoot", frequency: 350, duration: 0.20, volume: 0.25, sweep: 250) // owl
        prepareSound("squawk", frequency: 700, duration: 0.15, volume: 0.25, sweep: 450) // toucan
        prepareSound("crunch", frequency: 500, duration: 0.08, volume: 0.3, sweep: 200) // spider
        prepareSound("splash", frequency: 200, duration: 0.18, volume: 0.25, sweep: 80) // pond
        prepareSound("whoosh", frequency: 350, duration: 0.12, volume: 0.2, sweep: 600) // swooper dive
        prepareSound("snap", frequency: 900, duration: 0.05, volume: 0.3) // scorpion pincer
        prepareSound("rattle", frequency: 1800, duration: 0.20, volume: 0.2, sweep: 2200) // rattlesnake
        prepareSound("flutter", frequency: 700, duration: 0.10, volume: 0.15, sweep: 900) // butterfly/moth
        prepareSound("skitter", frequency: 1200, duration: 0.06, volume: 0.15, sweep: 800) // beetle scurry
        prepareSound("pop", frequency: 1000, duration: 0.04, volume: 0.25) // food eaten
        prepareSound("powerup", frequency: 500, duration: 0.25, volume: 0.35, sweep: 1500) // firefly/heartbug
        prepareSound("newBug", frequency: 600, duration: 0.15, volume: 0.35, sweep: 1000) // bugopedia unlock
        prepareMusic()
    }

    func play(_ name: String) {
        players[name]?.currentTime = 0
        players[name]?.play()
    }

    func startMusic() {
        guard !isMusicPlaying else { return }
        isMusicPlaying = true
        musicPlayer?.currentTime = 0
        musicPlayer?.play()
    }

    func stopMusic() {
        isMusicPlaying = false
        musicPlayer?.stop()
    }

    private func prepareSound(_ name: String, frequency: Double, duration: Double, volume: Float, sweep: Double? = nil) {
        let sampleRate: Double = 44100
        let numSamples = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: numSamples)

        for i in 0..<numSamples {
            let t = Double(i) / sampleRate
            let progress = t / duration
            let freq = sweep != nil ? frequency + (sweep! - frequency) * progress : frequency
            let envelope = (1.0 - progress) * (1.0 - progress)
            let value = sin(2.0 * .pi * freq * t) * envelope
            samples[i] = Int16(max(-32767, min(32767, value * 32767.0)))
        }

        let data = samples.withUnsafeBufferPointer { Data(buffer: $0) }
        if let player = try? AVAudioPlayer(data: buildWAV(from: data)) {
            player.volume = volume
            player.prepareToPlay()
            players[name] = player
        }
    }

    private func prepareMusic() {
        let sampleRate: Double = 44100
        let bpm: Double = 125
        let beatDur = 60.0 / bpm
        let totalBeats = 16 // 4 bars of 4
        let totalDur = beatDur * Double(totalBeats)
        let numSamples = Int(sampleRate * totalDur)
        var samples = [Int16](repeating: 0, count: numSamples)

        // Simple deterministic LCG for noise (no randomness issues)
        var noiseSeed: UInt32 = 12345

        for i in 0..<numSamples {
            let t = Double(i) / sampleRate
            let beatPos = t / beatDur
            let beatIndex = Int(beatPos) % 4
            let timeInBeat = (beatPos - floor(beatPos)) * beatDur

            var sample: Double = 0

            // Kick on beats 0, 2
            if (beatIndex == 0 || beatIndex == 2) && timeInBeat < 0.12 {
                let env = max(0, 1.0 - timeInBeat / 0.12)
                sample += sin(2.0 * .pi * (55.0 + 70.0 * env) * timeInBeat) * env * env * 0.5
            }

            // Hi-hat on every beat
            if timeInBeat < 0.035 {
                let env = max(0, 1.0 - timeInBeat / 0.035)
                // Deterministic noise
                noiseSeed = noiseSeed &* 1664525 &+ 1013904223
                let noise = Double(Int32(bitPattern: noiseSeed)) / Double(Int32.max)
                sample += noise * env * 0.15
            }

            // Off-beat hi-hat
            let offTime = timeInBeat - beatDur * 0.5
            if offTime > 0 && offTime < 0.025 {
                let env = max(0, 1.0 - offTime / 0.025)
                noiseSeed = noiseSeed &* 1664525 &+ 1013904223
                let noise = Double(Int32(bitPattern: noiseSeed)) / Double(Int32.max)
                sample += noise * env * 0.10
            }

            // Bass
            let bassFreqs: [Double] = [110, 110, 130.81, 146.83]
            let bassFreq = bassFreqs[beatIndex]
            if timeInBeat < beatDur * 0.7 {
                let env = max(0, 1.0 - timeInBeat / (beatDur * 0.7))
                sample += sin(2.0 * .pi * bassFreq * t) * env * 0.20
            }

            // Pad chord
            for pf in [220.0, 277.18, 329.63] {
                sample += sin(2.0 * .pi * pf * t) * 0.04
            }

            sample = max(-0.95, min(0.95, sample))
            samples[i] = Int16(sample * 28000)
        }

        let data = samples.withUnsafeBufferPointer { Data(buffer: $0) }
        if let player = try? AVAudioPlayer(data: buildWAV(from: data)) {
            player.volume = 0.20
            player.numberOfLoops = -1
            player.prepareToPlay()
            musicPlayer = player
        }
    }

    private func buildWAV(from pcmData: Data) -> Data {
        var wav = Data()
        let dataSize = UInt32(pcmData.count)
        let fileSize = UInt32(36 + pcmData.count)

        wav.append(contentsOf: [0x52, 0x49, 0x46, 0x46]) // "RIFF"
        wav.append(withUnsafeBytes(of: fileSize.littleEndian) { Data($0) })
        wav.append(contentsOf: [0x57, 0x41, 0x56, 0x45]) // "WAVE"
        wav.append(contentsOf: [0x66, 0x6D, 0x74, 0x20]) // "fmt "
        wav.append(withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) })
        wav.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })  // PCM
        wav.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })  // mono
        wav.append(withUnsafeBytes(of: UInt32(44100).littleEndian) { Data($0) })
        wav.append(withUnsafeBytes(of: UInt32(88200).littleEndian) { Data($0) })
        wav.append(withUnsafeBytes(of: UInt16(2).littleEndian) { Data($0) })
        wav.append(withUnsafeBytes(of: UInt16(16).littleEndian) { Data($0) })
        wav.append(contentsOf: [0x64, 0x61, 0x74, 0x61]) // "data"
        wav.append(withUnsafeBytes(of: dataSize.littleEndian) { Data($0) })
        wav.append(pcmData)
        return wav
    }
}
