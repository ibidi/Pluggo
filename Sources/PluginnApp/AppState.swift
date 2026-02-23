import AppKit
import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var isAutoTranslateEnabled: Bool {
        didSet { defaults.set(isAutoTranslateEnabled, forKey: Keys.autoTranslate) }
    }
    @Published var isAutoPasteEnabled: Bool {
        didSet { defaults.set(isAutoPasteEnabled, forKey: Keys.autoPaste) }
    }
    @Published var sourceLanguage: SourceLanguage {
        didSet { defaults.set(sourceLanguage.rawValue, forKey: Keys.sourceLanguage) }
    }
    @Published var targetLanguage: TargetLanguage {
        didSet { defaults.set(targetLanguage.rawValue, forKey: Keys.targetLanguage) }
    }
    @Published var provider: TranslationProvider {
        didSet { defaults.set(provider.rawValue, forKey: Keys.provider) }
    }
    @Published var apiKey: String {
        didSet { defaults.set(apiKey, forKey: Keys.apiKey) }
    }
    @Published var openAIModel: String {
        didSet { defaults.set(openAIModel, forKey: Keys.openAIModel) }
    }
    @Published var groqAPIKey: String {
        didSet { defaults.set(groqAPIKey, forKey: Keys.groqAPIKey) }
    }
    @Published var groqModel: String {
        didSet { defaults.set(groqModel, forKey: Keys.groqModel) }
    }
    @Published var libreTranslateBaseURL: String {
        didSet { defaults.set(libreTranslateBaseURL, forKey: Keys.libreBaseURL) }
    }
    @Published var statusMessage: String?
    @Published private(set) var logs: [String] = []

    private let defaults = UserDefaults.standard
    private let translationService = TranslationService()
    private var clipboardMonitor: ClipboardMonitor!
    private var activeTranslationTask: Task<Void, Never>?
    private var lastTranslatedSource: String?

    init() {
        self.isAutoTranslateEnabled = defaults.object(forKey: Keys.autoTranslate) as? Bool ?? true
        self.isAutoPasteEnabled = defaults.object(forKey: Keys.autoPaste) as? Bool ?? false
        self.sourceLanguage = SourceLanguage(rawValue: defaults.string(forKey: Keys.sourceLanguage) ?? "") ?? .auto
        self.targetLanguage = TargetLanguage(rawValue: defaults.string(forKey: Keys.targetLanguage) ?? "") ?? .turkish
        self.provider = TranslationProvider(rawValue: defaults.string(forKey: Keys.provider) ?? "") ?? .groq
        self.apiKey = defaults.string(forKey: Keys.apiKey) ?? ""
        self.openAIModel = defaults.string(forKey: Keys.openAIModel) ?? "gpt-4o-mini"
        self.groqAPIKey = defaults.string(forKey: Keys.groqAPIKey) ?? ""
        self.groqModel = defaults.string(forKey: Keys.groqModel) ?? "llama-3.1-8b-instant"
        self.libreTranslateBaseURL = defaults.string(forKey: Keys.libreBaseURL) ?? "https://libretranslate.com"

        self.clipboardMonitor = ClipboardMonitor { [weak self] text in
            guard let self else { return }
            self.handleClipboardText(text)
        }

        self.clipboardMonitor.start()
        self.statusMessage = "Hazır. Metni kopyala, Pluggo çevirsin."
        log("Uygulama basladi.")
    }

    func translateCurrentClipboard() async {
        guard let text = NSPasteboard.general.string(forType: .string)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            statusMessage = "Panoda metin yok."
            log("Panoda metin yok.")
            return
        }
        await runTranslation(for: text, manualTrigger: true)
    }

    private func handleClipboardText(_ text: String) {
        guard isAutoTranslateEnabled else { return }
        guard text != lastTranslatedSource else { return }
        log("Yeni pano metni algilandi (\(min(text.count, 80)) karakter).")

        activeTranslationTask?.cancel()
        activeTranslationTask = Task { [weak self] in
            guard let self else { return }
            await self.runTranslation(for: text, manualTrigger: false)
        }
    }

    private func runTranslation(for text: String, manualTrigger: Bool) async {
        if text.count > 6000 {
            statusMessage = "Metin çok uzun (\(text.count))."
            log("Cevrilmedi: metin cok uzun (\(text.count)).")
            return
        }

        statusMessage = manualTrigger ? "Panodaki metin çevriliyor..." : "Kopyalanan metin çevriliyor..."
        log("Ceviri basladi. Provider=\(provider.rawValue), kaynak=\(sourceLanguage.rawValue), hedef=\(targetLanguage.rawValue).")
        let request = TranslationRequest(
            text: text,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            provider: provider,
            apiKey: apiKey,
            openAIModel: openAIModel,
            groqAPIKey: groqAPIKey,
            groqModel: groqModel,
            libreTranslateBaseURL: libreTranslateBaseURL
        )

        do {
            let translated = try await translationService.translate(request)
            guard !Task.isCancelled else { return }

            lastTranslatedSource = text
            writeToClipboard(translated)
            statusMessage = "Çeviri tamamlandı. Panoya yazıldı."
            log("Ceviri tamamlandi. Sonuc \(translated.count) karakter.")

            if isAutoPasteEnabled {
                PasteSimulator.pasteClipboardToFrontApp()
                statusMessage = "Çeviri tamamlandı ve yapıştırıldı."
                log("Otomatik yapistirma denendi (Accessibility izni gerekiyorsa calismaz).")
            }
        } catch {
            statusMessage = error.localizedDescription
            log("HATA: \(error.localizedDescription)")
        }
    }

    private func writeToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        clipboardMonitor.markSelfWritten(text)
    }

    func clearLogs() {
        logs.removeAll()
    }

    func copyLogsToClipboard() {
        let text = logs.reversed().joined(separator: "\n")
        guard !text.isEmpty else {
            statusMessage = "Kopyalanacak log yok."
            return
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        statusMessage = "Loglar panoya kopyalandi."
        log("Loglar panoya kopyalandi.")
    }

    private func log(_ message: String) {
        let stamp = Self.logDateFormatter.string(from: Date())
        logs.insert("[\(stamp)] \(message)", at: 0)
        if logs.count > 40 {
            logs.removeLast(logs.count - 40)
        }
    }

    private static let logDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    private enum Keys {
        static let autoTranslate = "autoTranslate"
        static let autoPaste = "autoPaste"
        static let sourceLanguage = "sourceLanguage"
        static let targetLanguage = "targetLanguage"
        static let provider = "provider"
        static let apiKey = "apiKey"
        static let openAIModel = "openAIModel"
        static let groqAPIKey = "groqAPIKey"
        static let groqModel = "groqModel"
        static let libreBaseURL = "libreTranslateBaseURL"
    }
}
