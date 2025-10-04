import AVFoundation

@MainActor
final class BeepPlayer {
    static let shared = BeepPlayer()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var playbackFormat: AVAudioFormat!   // <-- keep a single, consistent format

    private init() {
        // Audio session
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [])
        try? session.setActive(true)

        // Graph
        engine.attach(player)

        // Use the mixer’s output format (usually stereo) for a consistent connection
        let mixer = engine.mainMixerNode
        let mixerOut = mixer.outputFormat(forBus: 0)              // e.g. 48kHz, 2ch
        let format = AVAudioFormat(standardFormatWithSampleRate: mixerOut.sampleRate,
                                   channels: max(2, mixerOut.channelCount))! // ensure >= 2
        engine.connect(player, to: mixer, format: format)
        self.playbackFormat = format

        do { try engine.start() } catch {
            print("BeepPlayer engine start failed:", error)
        }
    }

    /// Generate + play a sine tone buffer that matches `playbackFormat`
    func playBeep(frequency: Double = 880.0, duration: Double = 0.20, amplitude: Float = 0.2) {
        let sr = playbackFormat.sampleRate
        let ch = Int(playbackFormat.channelCount)
        let frames = AVAudioFrameCount(duration * sr)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: playbackFormat, frameCapacity: frames) else { return }
        buffer.frameLength = frames

        // Write samples to all channels (stereo-safe)
        let theta = 2.0 * Double.pi * frequency / sr
        if let channels = buffer.floatChannelData {
            for i in 0..<Int(frames) {
                let v = amplitude * Float(sin(theta * Double(i)))
                for c in 0..<ch {
                    channels[c][i] = v
                }
            }
        }

        if !player.isPlaying { player.play() }
        player.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
    }

    func playRandomBeep() {
        let freqs: [Double] = [523.25, 659.25, 783.99, 880.0, 987.77]
        let freq = freqs.randomElement()!
        let dur = [0.15, 0.2, 0.25].randomElement()!
        playBeep(frequency: freq, duration: dur)
    }
}
