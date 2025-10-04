import Foundation

struct TranslationResponse: Decodable {
    let fact: String
    let translation: String
}

extension TranslationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingName:
            return "Missing required value."
        case .badURL:
            return "Failed to form a valid request."
        case .badHTTPStatus(let code) where (500...599).contains(code):
            return "The translation service is temporarily unavailable. Please try again."
        case .badHTTPStatus(let code):
            return "The server returned an unexpected status: \(code)."
        case .emptyData:
            return "The server responded with no data."
        case .decodingFailed(_):
            return "Received an unexpected response from the server."
        }
    }
}

enum TranslationError: Error {
    case missingName
    case badURL
    case badHTTPStatus(Int)
    case emptyData
    case decodingFailed(Error)
}

struct TranslationService {
    static func translate(text: String, maxRetries: Int = 3) async throws -> TranslationResponse {
        var comps = URLComponents(string: "https://lingua-spatial-gemini-api.onrender.com/translate-fact")
        comps?.queryItems = [URLQueryItem(name: "text", value: text)]
        guard let url = comps?.url else { throw TranslationError.badURL }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        for attempt in 0...maxRetries {
            let (data, resp) = try await URLSession.shared.data(for: req)

            if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                if let body = String(data: data, encoding: .utf8), !body.isEmpty {
                    print("TranslationService non-2xx (\(http.statusCode)) body:", body)
                }

                if (500...599).contains(http.statusCode), attempt < maxRetries {
                    let delaySeconds = pow(2.0, Double(attempt)) * 0.5
                    try? await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
                    continue
                }

                throw TranslationError.badHTTPStatus(http.statusCode)
            }

            guard !data.isEmpty else { throw TranslationError.emptyData }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(TranslationResponse.self, from: data)
                print(response.fact)
                return response
            } catch {
                throw TranslationError.decodingFailed(error)
            }
        }

        throw TranslationError.emptyData
    }
}
