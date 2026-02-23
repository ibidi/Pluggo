import SwiftUI

@main
struct PluginnApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra("Pluggo", systemImage: "globe.badge.chevron.backward") {
            ContentView()
                .environmentObject(appState)
                .frame(width: 410)
        }
        .menuBarExtraStyle(.window)
    }
}

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isLogsExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerCard
            behaviorCard
            languageCard
            providerCard
            actionRow
            statusCard
            logsCard
        }
        .padding(12)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var headerCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.07, green: 0.32, blue: 0.26),
                            Color(red: 0.09, green: 0.18, blue: 0.33)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("Pluggo")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    CapsuleTag(text: appState.provider.label, icon: providerIcon(appState.provider))
                }

                HStack(spacing: 8) {
                    LanguageChip(
                        title: "Kaynak",
                        value: "\(appState.sourceLanguage.flag) \(appState.sourceLanguage.rawValue.uppercased())"
                    )
                    LanguageChip(
                        title: "Hedef",
                        value: "\(appState.targetLanguage.flag) \(appState.targetLanguage.rawValue.uppercased())"
                    )
                }
            }
            .padding(10)
        }
        .frame(height: 96)
    }

    private var behaviorCard: some View {
        CardBox(title: "Davranış", icon: "switch.2") {
            VStack(alignment: .leading, spacing: 10) {
                Toggle("Panoyu otomatik çevir", isOn: $appState.isAutoTranslateEnabled)
                Toggle("Çevirince otomatik yapıştır", isOn: $appState.isAutoPasteEnabled)
            }
        }
    }

    private var languageCard: some View {
        CardBox(title: "Diller", icon: "globe") {
            HStack(alignment: .top, spacing: 8) {
                pickerField(
                    title: "Kaynak Dil",
                    accent: appState.sourceLanguage.flag
                ) {
                    Picker(
                        selection: $appState.sourceLanguage,
                        label: Text("\(appState.sourceLanguage.flag) \(appState.sourceLanguage.label)")
                    ) {
                        ForEach(SourceLanguage.allCases) { language in
                            Text("\(language.flag) \(language.label)").tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)

                pickerField(
                    title: "Hedef Dil",
                    accent: appState.targetLanguage.flag
                ) {
                    Picker(
                        selection: $appState.targetLanguage,
                        label: Text("\(appState.targetLanguage.flag) \(appState.targetLanguage.label)")
                    ) {
                        ForEach(TargetLanguage.allCases) { language in
                            Text("\(language.flag) \(language.label)").tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
    }

    private var providerCard: some View {
        CardBox(title: "Sağlayıcı", icon: "bolt.horizontal.circle") {
            VStack(alignment: .leading, spacing: 10) {
                pickerField(title: "Çeviri Servisi", accent: providerIcon(appState.provider)) {
                    Picker(
                        selection: $appState.provider,
                        label: Text("\(providerIcon(appState.provider)) \(appState.provider.label)")
                    ) {
                        ForEach(TranslationProvider.allCases) { provider in
                            Text("\(providerIcon(provider)) \(provider.label)").tag(provider)
                        }
                    }
                    .pickerStyle(.menu)
                }

                if appState.provider == .openAI {
                    HStack(alignment: .top, spacing: 8) {
                        textFieldBox(title: "OpenAI API Key", icon: "🔑", text: $appState.apiKey)
                        textFieldBox(title: "Model", icon: "🧠", text: $appState.openAIModel)
                    }
                } else if appState.provider == .groq {
                    HStack(alignment: .top, spacing: 8) {
                        textFieldBox(title: "Groq API Key", icon: "🔑", text: $appState.groqAPIKey)
                        textFieldBox(title: "Groq Model", icon: "⚡", text: $appState.groqModel)
                    }
                } else {
                    textFieldBox(title: "LibreTranslate Base URL", icon: "🔗", text: $appState.libreTranslateBaseURL)
                }
            }
        }
    }

    private var actionRow: some View {
        HStack(spacing: 8) {
            Button {
                Task {
                    await appState.translateCurrentClipboard()
                }
            } label: {
                Label("Panodakini Çevir", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.12, green: 0.48, blue: 0.37))
            .keyboardShortcut("t", modifiers: [.command, .option])

            Button("Çıkış") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.bordered)
        }
    }

    private var statusCard: some View {
        CardBox(title: "Durum", icon: "info.circle") {
            Text(appState.statusMessage ?? "Hazır.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
        }
    }

    private var logsCard: some View {
        CardBox(title: "Log / Hata", icon: "doc.text.magnifyingglass") {
            VStack(alignment: .leading, spacing: 8) {
                DisclosureGroup(isExpanded: $isLogsExpanded) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Button("Kopyala") {
                                appState.copyLogsToClipboard()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)

                            Button("Temizle") {
                                appState.clearLogs()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)

                            Spacer()
                        }

                        ScrollView {
                            VStack(alignment: .leading, spacing: 6) {
                                if appState.logs.isEmpty {
                                    Text("Henüz log yok.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(8)
                                        .background(logRowBackground)
                                } else {
                                    ForEach(Array(appState.logs.enumerated()), id: \.offset) { _, line in
                                        Text(line)
                                            .font(.system(size: 11, weight: .regular, design: .monospaced))
                                            .textSelection(.enabled)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 6)
                                            .background(logRowBackground)
                                    }
                                }
                            }
                        }
                        .frame(height: 90)
                    }
                    .padding(.top, 6)
                } label: {
                    HStack(spacing: 6) {
                        Text(isLogsExpanded ? "Logları Gizle" : "Logları Göster")
                            .font(.caption)
                        Spacer()
                        Text("\(appState.logs.count)")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func pickerField<Content: View>(title: String, accent: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text(accent)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                content()
                    .labelsHidden()
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
        }
    }

    private func textFieldBox(title: String, icon: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text(icon)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            TextField(title, text: text)
                .textFieldStyle(.roundedBorder)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func providerIcon(_ provider: TranslationProvider) -> String {
        switch provider {
        case .openAI:
            return "◎"
        case .groq:
            return "⚡"
        case .libreTranslate:
            return "↔︎"
        }
    }

    private var logRowBackground: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color(nsColor: .controlBackgroundColor))
    }
}

private struct CardBox<Content: View>: View {
    let title: String
    let icon: String
    let content: () -> Content

    init(title: String, icon: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            content()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(nsColor: .underPageBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}

private struct CapsuleTag: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(spacing: 5) {
            Text(icon)
            Text(text)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.white.opacity(0.16))
        .clipShape(Capsule())
    }
}

private struct LanguageChip: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
