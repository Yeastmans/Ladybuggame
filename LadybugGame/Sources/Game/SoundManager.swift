import AVFoundation
import UIKit

final class SoundManager: @unchecked Sendable {
    static let shared = SoundManager()
    private var players: [String: AVAudioPlayer] = [:]

    private init() {
        prepareSound("eat", frequency: 880, duration: 0.08, volume: 0.3)
        prepareSound("eatRare", frequency: 1200, duration: 0.12, volume: 0.35)
        prepareSound("jump", frequency: 520, duration: 0.1, volume: 0.2, sweep: 800)
        prepareSound("hit", frequency: 180, duration: 0.2, volume: 0.4)
        prepareSound("land", frequency: 200, duration: 0.06, volume: 0.15)
        prepareSound("gameOver", frequency: 400, duration: 0.4, volume: 0.35, sweep: 120)
    }

    func play(_ name: String) {
        players[name]?.currentTime = 0
        players[name]?.play()
    }

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
            let envelope = (1.0 - progress) * (1.0 - progress) // Quadratic decay
            let sample = sin(2.0 * .pi * freq * t) * envelope
            var pcm = Int16(max(-32767, min(32767, sample * 32767.0)))
            data.append(Data(bytes: &pcm, count: 2))
        }

        // Build WAV header
        var wav = Data()
        let dataSize = UInt32(data.count)
        let fileSize = UInt32(36 + data.count)

        wav.append(contentsOf: "RIFF".utf8)
        wav.append(withUnsafeBytes(of: fileSize.littleEndian) { Data($0) })
        wav.append(contentsOf: "WAVE".utf8)
        wav.append(contentsOf: "fmt ".utf8)
        wav.append(withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) }) // chunk size
        wav.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })  // PCM
        wav.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })  // mono
        wav.append(withUnsafeBytes(of: UInt32(44100).littleEndian) { Data($0) }) // sample rate
        wav.append(withUnsafeBytes(of: UInt32(88200).littleEndian) { Data($0) }) // byte rate
        wav.append(withUnsafeBytes(of: UInt16(2).littleEndian) { Data($0) })  // block align
        wav.append(withUnsafeBytes(of: UInt16(16).littleEndian) { Data($0) }) // bits
        wav.append(contentsOf: "data".utf8)
        wav.append(withUnsafeBytes(of: dataSize.littleEndian) { Data($0) })
        wav.append(data)

        if let player = try? AVAudioPlayer(data: wav) {
            player.volume = volume
            player.prepareToPlay()
            players[name] = player
        }
    }
}
