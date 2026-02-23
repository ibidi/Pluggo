import Foundation

enum SourceLanguage: String, CaseIterable, Identifiable, Codable {
    case auto = "auto"
    case turkish = "tr"
    case english = "en"
    case german = "de"
    case french = "fr"
    case spanish = "es"
    case italian = "it"
    case arabic = "ar"
    case russian = "ru"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .auto: return "Auto Detect"
        case .turkish: return "Turkish (TR)"
        case .english: return "English (EN)"
        case .german: return "German (DE)"
        case .french: return "French (FR)"
        case .spanish: return "Spanish (ES)"
        case .italian: return "Italian (IT)"
        case .arabic: return "Arabic (AR)"
        case .russian: return "Russian (RU)"
        }
    }

    var flag: String {
        switch self {
        case .auto: return "🌐"
        case .turkish: return "🇹🇷"
        case .english: return "🇺🇸"
        case .german: return "🇩🇪"
        case .french: return "🇫🇷"
        case .spanish: return "🇪🇸"
        case .italian: return "🇮🇹"
        case .arabic: return "🇸🇦"
        case .russian: return "🇷🇺"
        }
    }
}

enum TargetLanguage: String, CaseIterable, Identifiable, Codable {
    case turkish = "tr"
    case english = "en"
    case german = "de"
    case french = "fr"
    case spanish = "es"
    case italian = "it"
    case arabic = "ar"
    case russian = "ru"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .turkish: return "Turkish (TR)"
        case .english: return "English (EN)"
        case .german: return "German (DE)"
        case .french: return "French (FR)"
        case .spanish: return "Spanish (ES)"
        case .italian: return "Italian (IT)"
        case .arabic: return "Arabic (AR)"
        case .russian: return "Russian (RU)"
        }
    }

    var flag: String {
        switch self {
        case .turkish: return "🇹🇷"
        case .english: return "🇺🇸"
        case .german: return "🇩🇪"
        case .french: return "🇫🇷"
        case .spanish: return "🇪🇸"
        case .italian: return "🇮🇹"
        case .arabic: return "🇸🇦"
        case .russian: return "🇷🇺"
        }
    }
}

enum TranslationProvider: String, CaseIterable, Identifiable {
    case openAI
    case groq
    case libreTranslate

    var id: String { rawValue }

    var label: String {
        switch self {
        case .openAI:
            return "OpenAI"
        case .groq:
            return "Groq"
        case .libreTranslate:
            return "LibreTranslate"
        }
    }
}
