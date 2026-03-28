import AVFoundation
import UIKit

final class SoundManager: @unchecked Sendable {
    static let shared = SoundManager()
    private var players: [String: AVAudioPlayer] = [:]
    private var musicPlayer: AVAudioPlayer?

    private init() {
        prepareSound("eat", frequency: 880, duration: 0.08, volume: 0.3)
        prepareSound("eatRare", frequency: 1200, duration: 0.12, volume: 0.35)
        prepareSound("munch", frequency: 660, duration: 0.10, volume: 0.3)
        prepareSound("jump", frequency: 520, duration: 0.1, volume: 0.2, sweep: 800)
        prepareSound("hit", frequency: 180, duration: 0.2, volume: 0.4)
        prepareSound("land", frequency: 200, duration: 0.06, volume: 0.15)
        prepareSound("gameOver", frequency: 400, duration: 0.4, volume: 0.35, sweep: 120)
        prepareSound("caw", frequency: 600, duration: 0.18, volume: 0.25, sweep: 350)
        prepareSound("ribbit", frequency: 250, duration: 0.15, volume: 0.3, sweep: 450)
        prepareMusic()
    }

    func play(_ name: String) {
        players[name]?.currentTime = 0
        players[name]?.play()
    }

    func startMusic() {
        musicPlayer?.currentTime = 0
        musicPlayer?.play()
    }

    func stopMusic() {
        musicPlayer?.stop()
    }

    // MARK: - Sound synthesis

    private func prepareSound(_ name: String, frequency: Double, duration: Double, volume: Float, sweep: Double? = nil) {
        let sampleRate: Double = 44100
        let numSamples = Int(sampleRate * duration)
        var data = Data()

        for i in 0..<numSamples {
            let t = Double(i) / sampleRate
            let progress = t / duration
            let freq: Double
            if let sw = sweep {
                freq = frequency + (sw - frequency) * progress
            } else {
                freq = frequency
            }
            let envelope = (1.0 - progress) * (1.0 - progress)
            let sample = sin(2.0 * .pi * freq * t) * envelope
            var pcm = Int16(max(-32767, min(32767, sample * 32767.0)))
            data.append(Data(bytes: &pcm, count: 2))
        }

        if let player = try? AVAudioPlayer(data: buildWAV(from: data)) {
            player.volume = volume
            player.prepareToPlay()
            players[name] = player
        }
    }

    // MARK: - Background music (simple looping beat)

    private func prepareMusic() {
        let sampleRate: Double = 44100
        let bpm: Double = 120
        let beatDuration = 60.0 / bpm
        let bars = 4
        let beatsPerBar = 4
        let totalBeats = bars * beatsPerBar
        let totalDuration = beatDuration * Double(totalBeats)
        let numSamples = Int(sampleRate * totalDuration)
        var data = Data()

        // Simple house-style pattern: kick on 1,3 — hihat on every beat — bass note on 1
        for i in 0..<numSamples {
            let t = Double(i) / sampleRate
            let beatPos = t / beatDuration
            let beatInBar = beatPos.truncatingRemainder(dividingBy: Double(beatsPerBar))
            let timeInBeat = (beatPos - beatPos.rounded(.down)) * beatDuration

            var sample: Double = 0

            // Kick drum (beats 0, 2) — low sine with fast decay
            if (Int(beatInBar) == 0 || Int(beatInBar) == 2) && timeInBeat < 0.15 {
                let kickEnv = max(0, 1.0 - timeInBeat / 0.15)
                let kickFreq = 60.0 + 80.0 * kickEnv
                sample += sin(2.0 * .pi * kickFreq * timeInBeat) * kickEnv * 0.4
            }

            // Hi-hat (every beat) — noise burst
            if timeInBeat < 0.04 {
                let hhEnv = max(0, 1.0 - timeInBeat / 0.04)
                let noise = Double.random(in: -1...1)
                sample += noise * hhEnv * 0.12
            }

            // Off-beat hi-hat (between beats)
            let offBeatTime = timeInBeat - beatDuration * 0.5
            if offBeatTime > 0 && offBeatTime < 0.03 {
                let hhEnv = max(0, 1.0 - offBeatTime / 0.03)
                let noise = Double.random(in: -1...1)
                sample += noise * hhEnv * 0.08
            }

            // Bass line — simple pattern per bar
            let barPos = Int(beatPos) % beatsPerBar
            let bassNotes: [Double] = [110, 110, 130.81, 146.83] // A2, A2, C3, D3
            let bassFreq = bassNotes[barPos]
            if timeInBeat < beatDuration * 0.8 {
                let bassEnv = max(0, 1.0 - timeInBeat / (beatDuration * 0.8))
                sample += sin(2.0 * .pi * bassFreq * t) * bassEnv * 0.15
            }

            // Pad chord — warm background (bar-level)
            let padFreqs: [Double] = [220, 277.18, 329.63] // A3, C#4, E4 — A major
            for pf in padFreqs {
                sample += sin(2.0 * .pi * pf * t) * 0.03
            }

            sample = max(-1, min(1, sample))
            var pcm = Int16(sample * 20000)
            data.append(Data(bytes: &pcm, count: 2))
        }

        if let player = try? AVAudioPlayer(data: buildWAV(from: data)) {
            player.volume = 0.15
            player.numberOfLoops = -1 // Loop forever
            player.prepareToPlay()
            musicPlayer = player
        }
    }

    private func buildWAV(from pcmData: Data) -> Data {
        var wav = Data()
        let dataSize = UInt32(pcmData.count)
        let fileSize = UInt32(36 + pcmData.count)

        wav.append(contentsOf: "RIFF".utf8)
        wav.append(withUnsafeBytes(of: fileSize.littleEndian) { Data($0) })
        wav.append(contentsOf: "WAVE".utf8)
        wav.append(contentsOf: "fmt ".utf8)
        wav.append(withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) })
        wav.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })
        wav.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })
        wav.append(withUnsafeBytes(of: UInt32(44100).littleEndian) { Data($0) })
        wav.append(withUnsafeBytes(of: UInt32(88200).littleEndian) { Data($0) })
        wav.append(withUnsafeBytes(of: UInt16(2).littleEndian) { Data($0) })
        wav.append(withUnsafeBytes(of: UInt16(16).littleEndian) { Data($0) })
        wav.append(contentsOf: "data".utf8)
        wav.append(withUnsafeBytes(of: dataSize.littleEndian) { Data($0) })
        wav.append(pcmData)
        return wav
    }
}
