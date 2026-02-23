import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outputURL = root.appendingPathComponent("docs/assets/screenshot-main.png")

let width = 1600
let height = 980
let size = NSSize(width: width, height: height)
let rect = NSRect(origin: .zero, size: size)

guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: width,
    pixelsHigh: height,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
), let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
    fputs("Failed to create bitmap/context\n", stderr)
    exit(1)
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context
defer { NSGraphicsContext.restoreGraphicsState() }

let bgGradient = NSGradient(colors: [
    NSColor(calibratedRed: 0.95, green: 0.98, blue: 0.97, alpha: 1.0),
    NSColor(calibratedRed: 0.90, green: 0.94, blue: 0.99, alpha: 1.0)
])!
bgGradient.draw(in: rect, angle: -20)

// Decorative blobs
func blob(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ color: NSColor) {
    let p = NSBezierPath(ovalIn: NSRect(x: x, y: y, width: w, height: h))
    color.setFill()
    p.fill()
}

blob(1180, 700, 320, 220, NSColor.systemTeal.withAlphaComponent(0.10))
blob(80, 70, 360, 240, NSColor.systemBlue.withAlphaComponent(0.08))
blob(1020, 80, 420, 240, NSColor.systemMint.withAlphaComponent(0.08))

// Header text
let titleAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 46, weight: .bold),
    .foregroundColor: NSColor(calibratedWhite: 0.10, alpha: 1)
]
let subtitleAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 16, weight: .medium),
    .foregroundColor: NSColor(calibratedWhite: 0.28, alpha: 1)
]
NSAttributedString(string: "Pluggo", attributes: titleAttrs)
    .draw(at: NSPoint(x: 120, y: 840))
NSAttributedString(string: "Copy → translate → paste back", attributes: subtitleAttrs)
    .draw(at: NSPoint(x: 120, y: 812))

// Main app window mock
let windowRect = NSRect(x: 420, y: 140, width: 1060, height: 700)
let shadow = NSShadow()
shadow.shadowBlurRadius = 30
shadow.shadowOffset = NSSize(width: 0, height: -8)
shadow.shadowColor = NSColor.black.withAlphaComponent(0.15)
shadow.set()

let windowPath = NSBezierPath(roundedRect: windowRect, xRadius: 26, yRadius: 26)
NSColor.white.setFill()
windowPath.fill()
NSShadow().set()

// Window chrome
let headerBar = NSRect(x: windowRect.minX, y: windowRect.maxY - 56, width: windowRect.width, height: 56)
let headerPath = NSBezierPath(roundedRect: headerBar, xRadius: 26, yRadius: 26)
NSColor(calibratedRed: 0.965, green: 0.975, blue: 0.99, alpha: 1).setFill()
headerPath.fill()

func circle(_ center: NSPoint, _ radius: CGFloat, _ color: NSColor) {
    let p = NSBezierPath(ovalIn: NSRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    color.setFill()
    p.fill()
}
circle(NSPoint(x: windowRect.minX + 24, y: windowRect.maxY - 28), 6, NSColor.systemRed.withAlphaComponent(0.9))
circle(NSPoint(x: windowRect.minX + 44, y: windowRect.maxY - 28), 6, NSColor.systemYellow.withAlphaComponent(0.9))
circle(NSPoint(x: windowRect.minX + 64, y: windowRect.maxY - 28), 6, NSColor.systemGreen.withAlphaComponent(0.9))

let headerTextAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 17, weight: .semibold),
    .foregroundColor: NSColor(calibratedWhite: 0.16, alpha: 1)
]
NSAttributedString(string: "Pluggo", attributes: headerTextAttrs)
    .draw(at: NSPoint(x: windowRect.midX - 30, y: windowRect.maxY - 35))

func roundedCard(_ r: NSRect, _ color: NSColor = NSColor(calibratedWhite: 0.97, alpha: 1)) {
    let p = NSBezierPath(roundedRect: r, xRadius: 18, yRadius: 18)
    color.setFill()
    p.fill()
}

// Left control column
let leftX = windowRect.minX + 24
let topY = windowRect.maxY - 86

let heroCard = NSRect(x: leftX, y: topY - 110, width: 320, height: 110)
let heroGrad = NSGradient(colors: [
    NSColor(calibratedRed: 0.07, green: 0.32, blue: 0.26, alpha: 1),
    NSColor(calibratedRed: 0.09, green: 0.18, blue: 0.33, alpha: 1)
])!
let heroCardPath = NSBezierPath(roundedRect: heroCard, xRadius: 20, yRadius: 20)
heroGrad.draw(in: heroCardPath, angle: -30)

let whiteTitle: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 18, weight: .bold),
    .foregroundColor: NSColor.white
]
let whiteSub: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 12, weight: .medium),
    .foregroundColor: NSColor.white.withAlphaComponent(0.85)
]
NSAttributedString(string: "Pluggo", attributes: whiteTitle).draw(at: NSPoint(x: heroCard.minX + 14, y: heroCard.maxY - 34))
NSAttributedString(string: "🌐 Auto -> 🇹🇷  •  Provider: Groq", attributes: whiteSub)
    .draw(at: NSPoint(x: heroCard.minX + 14, y: heroCard.maxY - 56))

let controlCard = NSRect(x: leftX, y: heroCard.minY - 126, width: 320, height: 112)
roundedCard(controlCard)
let labelAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 13, weight: .semibold),
    .foregroundColor: NSColor(calibratedWhite: 0.28, alpha: 1)
]
let smallAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 12, weight: .regular),
    .foregroundColor: NSColor(calibratedWhite: 0.35, alpha: 1)
]
NSAttributedString(string: "⚙️  Controls", attributes: labelAttrs)
    .draw(at: NSPoint(x: controlCard.minX + 14, y: controlCard.maxY - 28))
NSAttributedString(string: "✓ Auto translate clipboard", attributes: smallAttrs)
    .draw(at: NSPoint(x: controlCard.minX + 14, y: controlCard.maxY - 54))
NSAttributedString(string: "✓ Auto paste translation", attributes: smallAttrs)
    .draw(at: NSPoint(x: controlCard.minX + 14, y: controlCard.maxY - 76))

let langCard = NSRect(x: leftX, y: controlCard.minY - 146, width: 320, height: 132)
roundedCard(langCard)
NSAttributedString(string: "🌐  Languages", attributes: labelAttrs)
    .draw(at: NSPoint(x: langCard.minX + 14, y: langCard.maxY - 28))

func field(_ rect: NSRect, _ text: String) {
    let p = NSBezierPath(roundedRect: rect, xRadius: 12, yRadius: 12)
    NSColor(calibratedWhite: 0.93, alpha: 1).setFill()
    p.fill()
    NSAttributedString(string: text, attributes: smallAttrs)
        .draw(at: NSPoint(x: rect.minX + 10, y: rect.minY + 9))
}

field(NSRect(x: langCard.minX + 14, y: langCard.maxY - 66, width: 292, height: 34), "🌐 Auto Detect")
field(NSRect(x: langCard.minX + 14, y: langCard.maxY - 106, width: 292, height: 34), "🇹🇷 Turkish (TR)")

// Right side workspace panels
let rightX = leftX + 344
let rightW = windowRect.maxX - rightX - 24

let previewCard = NSRect(x: rightX, y: topY - 250, width: rightW, height: 250)
roundedCard(previewCard, NSColor(calibratedWhite: 0.985, alpha: 1))
NSAttributedString(string: "📋 → 🌐 → ↩︎", attributes: [
    .font: NSFont.systemFont(ofSize: 16, weight: .semibold),
    .foregroundColor: NSColor(calibratedWhite: 0.16, alpha: 1)
]).draw(at: NSPoint(x: previewCard.minX + 16, y: previewCard.maxY - 34))

let flowTexts = [
    "1. Copy text in Slack / Mail / WhatsApp",
    "2. Pluggo detects new clipboard content",
    "3. Groq translates to selected target language",
    "4. Result is written back to clipboard",
    "5. Optional auto-paste sends it back to active app"
]
for (idx, t) in flowTexts.enumerated() {
    NSAttributedString(string: t, attributes: smallAttrs)
        .draw(at: NSPoint(x: previewCard.minX + 18, y: previewCard.maxY - 66 - CGFloat(idx) * 28))
}

let chip1 = NSRect(x: previewCard.minX + 18, y: previewCard.minY + 20, width: 136, height: 28)
let chip2 = NSRect(x: previewCard.minX + 162, y: previewCard.minY + 20, width: 150, height: 28)
for (r, c, t) in [(chip1, NSColor.systemTeal.withAlphaComponent(0.15), "Provider: Groq"),
                  (chip2, NSColor.systemBlue.withAlphaComponent(0.12), "Source: Auto")] {
    let p = NSBezierPath(roundedRect: r, xRadius: 14, yRadius: 14)
    c.setFill()
    p.fill()
    NSAttributedString(string: t, attributes: [
        .font: NSFont.systemFont(ofSize: 11, weight: .semibold),
        .foregroundColor: NSColor(calibratedWhite: 0.2, alpha: 1)
    ]).draw(at: NSPoint(x: r.minX + 12, y: r.minY + 8))
}

let logCard = NSRect(x: rightX, y: previewCard.minY - 210, width: rightW, height: 190)
roundedCard(logCard)
NSAttributedString(string: "Log / Hata", attributes: labelAttrs)
    .draw(at: NSPoint(x: logCard.minX + 16, y: logCard.maxY - 30))

let logs = [
    "[09:44:54] Ceviri basladi. Provider=groq, kaynak=auto, hedef=tr.",
    "[09:44:54] Ceviri tamamlandi. Sonuc 16 karakter.",
    "[09:44:54] Otomatik yapistirma denendi."
]
for (i, line) in logs.enumerated() {
    let rowRect = NSRect(x: logCard.minX + 14, y: logCard.maxY - 66 - CGFloat(i) * 38, width: logCard.width - 28, height: 30)
    let row = NSBezierPath(roundedRect: rowRect, xRadius: 10, yRadius: 10)
    NSColor(calibratedWhite: 0.94, alpha: 1).setFill()
    row.fill()
    NSAttributedString(string: line, attributes: [
        .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular),
        .foregroundColor: NSColor(calibratedWhite: 0.24, alpha: 1)
    ]).draw(at: NSPoint(x: rowRect.minX + 8, y: rowRect.minY + 8))
}

NSAttributedString(string: "📋  ⌘C  →  🌐  →  ⌘V  •  🟢 OSS", attributes: [
    .font: NSFont.systemFont(ofSize: 15, weight: .semibold),
    .foregroundColor: NSColor(calibratedWhite: 0.22, alpha: 1)
]).draw(at: NSPoint(x: 120, y: 132))

guard let png = bitmap.representation(using: .png, properties: [:]) else {
    fputs("Failed to encode PNG\n", stderr)
    exit(1)
}
try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
try png.write(to: outputURL)
print("Generated \(outputURL.path)")
