import AppKit
import Foundation

@MainActor
final class ClipboardMonitor {
    private let pasteboard = NSPasteboard.general
    private var timer: Timer?
    private var lastChangeCount: Int
    private var lastSelfWrittenValue: String?
    private let onStringChange: (String) -> Void

    init(onStringChange: @escaping (String) -> Void) {
        self.lastChangeCount = pasteboard.changeCount
        self.onStringChange = onStringChange
    }

    func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.poll()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func markSelfWritten(_ value: String) {
        lastSelfWrittenValue = value
    }

    private func poll() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        guard let value = pasteboard.string(forType: .string)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            return
        }

        if value == lastSelfWrittenValue {
            lastSelfWrittenValue = nil
            return
        }

        onStringChange(value)
    }
}
