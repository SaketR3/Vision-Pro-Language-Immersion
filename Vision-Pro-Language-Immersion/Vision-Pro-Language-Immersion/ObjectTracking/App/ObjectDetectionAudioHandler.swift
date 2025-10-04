// ObjectDetectionAudioHandler.swift
// Plays translation audio when an object is detected by name.

import Foundation
import AVFoundation

// MARK: - API Models & Errors

struct TranslationResponse: Codable {
    let translation: String
    let fact: String
    let translation_audio_url: String?
    let fact_audio_url: String?
}

enum TranslationError: Error {
    case badURL
    case badHTTPStatus(Int)
    case emptyData
    case decodingFailed(Error)
}

extension TranslationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badURL:                       return "Failed to form a valid request."
        case .badHTTPStatus(let code)
            where (500...599).contains(code): return "The translation service is temporarily unavailable."
        case .badHTTPStatus(let code):      return "The server returned an unexpected status: \(code)."
        case .emptyData:                    return "The server responded with no data."
        case .decodingFailed:               return "Received an unexpected response from the server."
        }
    }
}

// MARK: - Audio Helpers

// See AudioHelpers.swift for base64 decoding and AVAudioPlayer construction.

// MARK: - API Service

enum TranslationService {
    /// Calls the audio endpoint with a few retries. On server 5xx, it throws (you could add a fallback to a non-audio endpoint if you want).
    static func translate(text: String, maxRetries: Int = 2) async throws -> TranslationResponse {
        var comps = URLComponents(string: "https://lingua-spatial-gemini-api.onrender.com/translate-fact-audio")
        comps?.queryItems = [URLQueryItem(name: "text", value: text)]
        guard let url = comps?.url else { throw TranslationError.badURL }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.timeoutInterval = 20

        var attempt = 0
        while true {
            let (data, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                // Log body for debugging
                if let body = String(data: data, encoding: .utf8), !body.isEmpty {
                    print("TranslationService non-2xx (\(http.statusCode)) body:", body)
                }
                if (500...599).contains(http.statusCode), attempt < maxRetries {
                    attempt += 1
                    try? await Task.sleep(nanoseconds: backoff(attempt: attempt))
                    continue
                }
                throw TranslationError.badHTTPStatus(http.statusCode)
            }

            guard !data.isEmpty else { throw TranslationError.emptyData }

            do {
                let dec = JSONDecoder()
                // If you ever rename properties to camelCase in Swift,
                // you can switch to: dec.keyDecodingStrategy = .convertFromSnakeCase
                return try dec.decode(TranslationResponse.self, from: data)
            } catch {
                throw TranslationError.decodingFailed(error)
            }
        }
    }

    private static func backoff(attempt: Int) -> UInt64 {
        // 0.5s, 1s, 2s (+ small jitter)
        let base = pow(2.0, Double(attempt - 1)) * 0.5
        let jitter = Double.random(in: 0...0.15)
        return UInt64((base + jitter) * 1_000_000_000)
    }
}

// MARK: - Main Controller (call this from your AR anchor `.added` branch)

@MainActor
final class ObjectDetectionAudioHandler {
    static let shared = ObjectDetectionAudioHandler()

    private var player: AVAudioPlayer?
    private var playedNames = Set<String>()  // debounces by object name

    private let tts = AVSpeechSynthesizer()

    private func speakFallback(_ text: String) {
        guard !text.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.identifier)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        tts.speak(utterance)
    }

    private init() {
        // Configure audio session once
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback)
        try? session.setActive(true)
    }

    /// Public entry point. Call when ARKit reports a *newly added* anchor for an object.
    func playForDetectedObject(name: String, force: Bool = false) async {
        guard !name.isEmpty else { return }

        // Debounce: if we've already played for this name, skip (unless force == true)
        if !force, playedNames.contains(name) {
            return
        }

        do {
            let response = try await TranslationService.translate(text: name)

            // Mark as played after we have a successful response to avoid repeated requests
            playedNames.insert(name)

            // Prefer translation audio, fall back to fact audio if needed
            let b64 = response.fact_audio_url ?? response.fact_audio_url

            if let b64, !b64.isEmpty {
                do {
                    let data = try AudioHelpers.decodeBase64AudioString(b64)
                    // Adjust the preferred extension if your backend is known to return mp3/m4a
                    let p = try AudioHelpers.makeAudioPlayer(from: data, preferredExtension: "wav")
                    self.player = p
                    p.prepareToPlay()
                    p.play()
                } catch {
                    print("Audio decode/playback failed for '\(name)': \(error)")
                    // Fallback to TTS of the translation string
                    self.speakFallback(response.translation)
                }
            } else {
                print("No audio payload for object: \(name). Using TTS.")
                self.speakFallback(response.translation)
            }

            // Optional: log text for debugging/UI
            print("Translation: \(response.translation)")
            print("Fact: \(response.fact)")

        } catch {
            let msg = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
            print("Translation request failed for '\(name)': \(msg)")
            // On any failure, still try TTS of the original name to keep the UX responsive
            self.speakFallback(name)
        }
    }

    func stop() {
        player?.stop()
    }

    func resetDebounce() {
        playedNames.removeAll()
    }
}

