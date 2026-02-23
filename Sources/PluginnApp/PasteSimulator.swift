import AppKit
import ApplicationServices
import Foundation

enum PasteSimulator {
    static func pasteClipboardToFrontApp() {
        guard AXIsProcessTrusted() else { return }
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }

        let keyVDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        keyVDown?.flags = .maskCommand
        let keyVUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyVUp?.flags = .maskCommand

        keyVDown?.post(tap: .cghidEventTap)
        keyVUp?.post(tap: .cghidEventTap)
    }
}
