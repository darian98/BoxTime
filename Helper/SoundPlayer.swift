//
//  SoundPlayer.swift
//  BoxTime
//
//  Created by Darian Hanci on 07.11.25.
//
import AVFoundation

final class SoundPlayer {
    static let shared = SoundPlayer()
    private var player: AVAudioPlayer?
    private var stopTimer: Timer?

    private init() {
        // Spielt auch im Stummmodus (falls gewünscht). Wenn es Stumm respektieren soll: .ambient
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func playSound(named: String, ext: String, duration: TimeInterval? = nil) {
        play(named: named, ext: ext, duration: duration) // oder wav/aiff etc.
    }

    private func play(named: String, ext: String, duration: TimeInterval?) {
        guard let url = Bundle.main.url(forResource: named, withExtension: ext) else {
            print("⚠️ Sound \(named).\(ext) nicht gefunden")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
            
            if let duration = duration {
                stopTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                    self?.player?.stop()
                }
            }
        } catch {
            print("⚠️ Konnte Sound nicht abspielen: \(error)")
        }
    }
}

