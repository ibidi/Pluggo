import Foundation

struct TranslationRequest {
    let text: String
    let sourceLanguage: SourceLanguage
    let targetLanguage: TargetLanguage
    let provider: TranslationProvider
    let apiKey: String
    let openAIModel: String
    let groqAPIKey: String
    let groqModel: String
    let libreTranslateBaseURL: String
}

enum TranslationError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case badResponse(String)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key gerekli."
        case .invalidURL:
            return "Geçersiz URL."
        case .badResponse(let message):
            return "Çeviri hatası: \(message)"
        case .decodingFailed:
            return "Sunucu yanıtı çözümlenemedi."
        }
    }
}

struct TranslationService {
    func translate(_ request: TranslationRequest) async throws -> String {
        switch request.provider {
        case .openAI:
            return try await translateWithOpenAI(request)
        case .groq:
            return try await translateWithGroq(request)
        case .libreTranslate:
            return try await translateWithLibreTranslate(request)
        }
    }

    private func translateWithOpenAI(_ request: TranslationRequest) async throws -> String {
        let apiKey = request.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !apiKey.isEmpty else { throw TranslationError.missingAPIKey }

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw TranslationError.invalidURL
        }

        let sourceInstruction = sourceInstructionText(for: request.sourceLanguage)
        let systemPrompt = "You are a translation engine. \(sourceInstruction) Translate the user text into \(request.targetLanguage.label). Return only the translated text."
        let body = OpenAIChatCompletionRequest(
            model: request.openAIModel.isEmpty ? "gpt-4o-mini" : request.openAIModel,
            messages: [
                .init(role: "system", content: systemPrompt),
                .init(role: "user", content: request.text)
            ],
            temperature: 0.1
        )

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else {
            throw TranslationError.badResponse("No HTTP response")
        }

        guard (200..<300).contains(http.statusCode) else {
            let serverMessage = extractProviderErrorMessage(data: data, fallbackStatus: http.statusCode)
            throw TranslationError.badResponse(serverMessage)
        }

        let decoded = try JSONDecoder().decode(OpenAIChatCompletionResponse.self, from: data)
        guard let text = decoded.choices.first?.message.content?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            throw TranslationError.decodingFailed
        }

        return text
    }

    private func translateWithGroq(_ request: TranslationRequest) async throws -> String {
        let apiKey = request.groqAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !apiKey.isEmpty else { throw TranslationError.missingAPIKey }

        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            throw TranslationError.invalidURL
        }

        let sourceInstruction = sourceInstructionText(for: request.sourceLanguage)
        let systemPrompt = "You are a translation engine. \(sourceInstruction) Translate the user text into \(request.targetLanguage.label). Return only the translated text."
        let body = OpenAIChatCompletionRequest(
            model: request.groqModel.isEmpty ? "llama-3.1-8b-instant" : request.groqModel,
            messages: [
                .init(role: "system", content: systemPrompt),
                .init(role: "user", content: request.text)
            ],
            temperature: 0.1
        )

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else {
            throw TranslationError.badResponse("No HTTP response")
        }

        guard (200..<300).contains(http.statusCode) else {
            let serverMessage = extractProviderErrorMessage(data: data, fallbackStatus: http.statusCode)
            throw TranslationError.badResponse(serverMessage)
        }

        let decoded = try JSONDecoder().decode(OpenAIChatCompletionResponse.self, from: data)
        guard let text = decoded.choices.first?.message.content?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            throw TranslationError.decodingFailed
        }

        return text
    }

    private func translateWithLibreTranslate(_ request: TranslationRequest) async throws -> String {
        let base = request.libreTranslateBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let endpoint = base.isEmpty ? "https://libretranslate.com/translate" : "\(base)/translate"
        guard let url = URL(string: endpoint) else { throw TranslationError.invalidURL }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = LibreTranslateRequest(
            q: request.text,
            source: request.sourceLanguage.rawValue,
            target: request.targetLanguage.rawValue,
            format: "text",
            apiKey: nil
        )
        urlRequest.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else {
            throw TranslationError.badResponse("No HTTP response")
        }

        guard (200..<300).contains(http.statusCode) else {
            let serverMessage = extractProviderErrorMessage(data: data, fallbackStatus: http.statusCode)
            throw TranslationError.badResponse(serverMessage)
        }

        let decoded = try JSONDecoder().decode(LibreTranslateResponse.self, from: data)
        let translated = decoded.translatedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !translated.isEmpty else { throw TranslationError.decodingFailed }
        return translated
    }

    private func extractProviderErrorMessage(data: Data, fallbackStatus: Int) -> String {
        if let envelope = try? JSONDecoder().decode(ProviderErrorEnvelope.self, from: data),
           let error = envelope.error {
            if error.code == "insufficient_quota" {
                return "API kotasi yetersiz (insufficient_quota). Billing/kredi kontrol et."
            }
            if let message = error.message, !message.isEmpty {
                return message
            }
        }

        if let jsonString = String(data: data, encoding: .utf8), !jsonString.isEmpty {
            return jsonString
        }
        return "HTTP \(fallbackStatus)"
    }

    private func sourceInstructionText(for sourceLanguage: SourceLanguage) -> String {
        if sourceLanguage == .auto {
            return "Detect the source language automatically."
        }
        return "The source language is \(sourceLanguage.label)."
    }
}

private struct OpenAIChatCompletionRequest: Encodable {
    struct Message: Encodable {
        let role: String
        let content: String
    }

    let model: String
    let messages: [Message]
    let temperature: Double
}

private struct OpenAIChatCompletionResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let role: String?
            let content: String?
        }

        let index: Int?
        let message: Message
    }

    let choices: [Choice]
}

private struct LibreTranslateRequest: Encodable {
    let q: String
    let source: String
    let target: String
    let format: String
    let apiKey: String?

    enum CodingKeys: String, CodingKey {
        case q
        case source
        case target
        case format
        case apiKey = "api_key"
    }
}

private struct LibreTranslateResponse: Decodable {
    let translatedText: String
}

private struct ProviderErrorEnvelope: Decodable {
    struct ProviderError: Decodable {
        let message: String?
        let type: String?
        let param: String?
        let code: String?
    }

    let error: ProviderError?
}
