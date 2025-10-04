import Foundation
import AVFoundation

enum AudioHelpersError: Error {
    case invalidBase64String
    case writeFailed
    case audioInitializationFailed(String)
}

extension AudioHelpersError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidBase64String:
            return "Invalid or undecodable base64 audio string."
        case .writeFailed:
            return "Failed to write audio data to a temporary file."
        case .audioInitializationFailed(let reason):
            return "Failed to initialize audio player: \(reason)"
        }
    }
}

struct AudioHelpersLegacy {
    /// Decodes an API-provided base64 audio string.
    /// - Behavior:
    ///   - Strips optional `data:audio/*;base64,` prefix
    ///   - Normalizes URL-safe base64 by replacing `-` with `+` and `_` with `/`
    ///   - Pads with `=` to a multiple of 4
    ///   - Returns decoded Data or throws on failure
    static func decodeBase64AudioString(_ input: String) throws -> Data {
        var s = input.trimmingCharacters(in: .whitespacesAndNewlines)

        // Strip any data URI prefix like: data:audio/wav;base64,XXXXX
        if s.lowercased().hasPrefix("data:") {
            if let commaIndex = s.firstIndex(of: ",") {
                s = String(s[s.index(after: commaIndex)...])
            }
        }

        // Remove whitespace/newlines in the payload
        s = s.components(separatedBy: .whitespacesAndNewlines).joined()

        // Normalize URL-safe base64
        s = s.replacingOccurrences(of: "-", with: "+")
             .replacingOccurrences(of: "_", with: "/")

        // Pad to a multiple of 4
        let remainder = s.count % 4
        if remainder != 0 {
            s.append(String(repeating: "=", count: 4 - remainder))
        }

        guard let data = Data(base64Encoded: s, options: [.ignoreUnknownCharacters]) else {
            throw AudioHelpersError.invalidBase64String
        }
        return data
    }

    /// Creates an AVAudioPlayer from audio `Data`.
    /// Attempts in-memory initialization first; if that fails, writes to a temp file
    /// with the given extension and initializes from file URL.
    /// This helper also configures the shared AVAudioSession for playback.
    static func makeAudioPlayer(from data: Data, preferredExtension: String = "wav") throws -> AVAudioPlayer {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback)
            try session.setActive(true)
        } catch {
            // Non-fatal: continue attempting to create the player
            print("Audio session configuration failed: \(error)")
        }

        // Try in-memory first
        if let p = try? AVAudioPlayer(data: data) {
            return p
        }

        // Fallback to temp file
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("api-audio-\(UUID().uuidString).\(preferredExtension)")
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw AudioHelpersError.writeFailed
        }

        do {
            let p = try AVAudioPlayer(contentsOf: fileURL)
            return p
        } catch {
            throw AudioHelpersError.audioInitializationFailed(String(describing: error))
        }
    }
}
