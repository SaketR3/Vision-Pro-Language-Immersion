import Foundation

enum TranslationError: Error {
    case missingName
    case badURL
    case badHTTPStatus(Int)
    case emptyData
}

struct TranslationService {
    static func translate(text: String) async throws -> String {
        var comps = URLComponents(string: "https://lingua-spatial-gemini-api.onrender.com/translate")
        comps?.queryItems = [URLQueryItem(name: "text", value: text)]
        guard let url = comps?.url else { throw TranslationError.badURL }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        let (data, resp) = try await URLSession.shared.data(for: req)
        if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw TranslationError.badHTTPStatus(http.statusCode)
        }
        guard !data.isEmpty else { throw TranslationError.emptyData }
        // If your API returns plain text, decode as String; if JSON, parse here instead.
        return String(decoding: data, as: UTF8.self)
    }
}
