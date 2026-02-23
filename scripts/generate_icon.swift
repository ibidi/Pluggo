import AppKit
import Foundation

guard CommandLine.arguments.count >= 3 else {
    fputs("Usage: swift scripts/generate_icon.swift <output.png> <size>\n", stderr)
    exit(1)
}

let outputPath = CommandLine.arguments[1]
let sizeValue = Double(CommandLine.arguments[2]) ?? 1024
let size = NSSize(width: sizeValue, height: sizeValue)
let rect = NSRect(origin: .zero, size: size)

guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(size.width),
    pixelsHigh: Int(size.height),
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    fputs("Failed to create bitmap context\n", stderr)
    exit(1)
}

guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
    fputs("Failed to create NSGraphicsContext\n", stderr)
    exit(1)
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context
defer {
    NSGraphicsContext.restoreGraphicsState()
}

NSGraphicsContext.current?.imageInterpolation = .high

let backgroundPath = NSBezierPath(roundedRect: rect.insetBy(dx: size.width * 0.04, dy: size.height * 0.04),
                                  xRadius: size.width * 0.23,
                                  yRadius: size.height * 0.23)

let gradient = NSGradient(colors: [
    NSColor(calibratedRed: 0.04, green: 0.56, blue: 0.43, alpha: 1.0),
    NSColor(calibratedRed: 0.08, green: 0.26, blue: 0.55, alpha: 1.0)
])!
gradient.draw(in: backgroundPath, angle: -35)

// Soft top highlight for depth.
let highlightRect = NSRect(x: rect.minX + size.width * 0.09,
                           y: rect.midY,
                           width: size.width * 0.82,
                           height: size.height * 0.34)
let highlightPath = NSBezierPath(roundedRect: highlightRect,
                                 xRadius: size.width * 0.12,
                                 yRadius: size.height * 0.12)
NSColor.white.withAlphaComponent(0.10).setFill()
highlightPath.fill()

let symbolConfig = NSImage.SymbolConfiguration(pointSize: size.width * 0.50, weight: .regular)
let symbolName = "globe.badge.chevron.backward"
let symbol = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Pluggo icon")?
    .withSymbolConfiguration(symbolConfig)

if let symbol {
    let symbolSize = NSSize(width: size.width * 0.56, height: size.height * 0.56)
    let symbolRect = NSRect(
        x: (size.width - symbolSize.width) / 2,
        y: (size.height - symbolSize.height) / 2 - size.height * 0.01,
        width: symbolSize.width,
        height: symbolSize.height
    )

    NSColor.white.withAlphaComponent(0.93).set()
    symbol.draw(in: symbolRect, from: .zero, operation: .sourceOver, fraction: 1.0)
}

// Small accent sparkle.
let sparkleConfig = NSImage.SymbolConfiguration(pointSize: size.width * 0.13, weight: .bold)
let sparkle = NSImage(systemSymbolName: "sparkles", accessibilityDescription: nil)?
    .withSymbolConfiguration(sparkleConfig)
if let sparkle {
    let sparkleRect = NSRect(
        x: size.width * 0.67,
        y: size.height * 0.70,
        width: size.width * 0.14,
        height: size.height * 0.14
    )
    NSColor.white.set()
    sparkle.draw(in: sparkleRect, from: .zero, operation: .sourceOver, fraction: 0.95)
}

guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
    fputs("Failed to create PNG data\n", stderr)
    exit(1)
}

let outputURL = URL(fileURLWithPath: outputPath)
try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(),
                                        withIntermediateDirectories: true)
try pngData.write(to: outputURL)
