import AVFoundation

enum AudioDecodeError: Error {
    case invalidBase64
    case playerInitFailed
}

enum AudioHelpers {
    static func decodeBase64AudioString(_ s: String) throws -> Data {
        let payload: Substring = {
            if let comma = s.firstIndex(of: ","),
               s[..<comma].lowercased().contains("base64") {
                return s[s.index(after: comma)...]
            } else {
                return Substring(s)
            }
        }()

        var normalized = payload
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let remainder = normalized.count % 4
        if remainder > 0 {
            normalized.append(String(repeating: "=", count: 4 - remainder))
        }

        guard let data = Data(base64Encoded: normalized, options: [.ignoreUnknownCharacters]) else {
            throw AudioDecodeError.invalidBase64
        }
        return data
    }

    static func makeAudioPlayer(from data: Data, preferredExtension: String? = nil) throws -> AVAudioPlayer {
        do {
            return try AVAudioPlayer(data: data)
        } catch {
            let ext = preferredExtension ?? "wav"
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(ext)
            try data.write(to: url, options: .atomic)
            return try AVAudioPlayer(contentsOf: url)
        }
    }
}
