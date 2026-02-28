#!/usr/bin/env swift

import AppKit
import Foundation

struct IconSlot {
    let filename: String
    let pixelSize: Int
}

enum IconGenerationError: Error {
    case invalidOutputPath
    case bitmapCreationFailed(Int)
    case pngEncodingFailed(String)
}

struct IconRenderer {
    func writeIconSet(to directory: URL) throws {
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: directory.path) {
            try fileManager.removeItem(at: directory)
        }

        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

        for slot in Self.slots {
            let pngData = try renderPNG(size: slot.pixelSize)
            let destination = directory.appendingPathComponent(slot.filename)
            try pngData.write(to: destination)
        }
    }

    private func renderPNG(size: Int) throws -> Data {
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: size,
            pixelsHigh: size,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            throw IconGenerationError.bitmapCreationFailed(size)
        }

        bitmap.size = NSSize(width: size, height: size)

        guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
            throw IconGenerationError.bitmapCreationFailed(size)
        }

        let rect = CGRect(origin: .zero, size: CGSize(width: size, height: size))

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context

        drawIcon(in: rect)

        context.flushGraphics()
        NSGraphicsContext.restoreGraphicsState()

        guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw IconGenerationError.pngEncodingFailed("Failed to encode \(size)x\(size) PNG")
        }

        return pngData
    }

    private func drawIcon(in rect: CGRect) {
        NSColor.clear.setFill()
        rect.fill()

        drawBackground(in: rect)
        drawClipboard(in: rect)
    }

    private func drawBackground(in rect: CGRect) {
        let backgroundRect = rect.insetBy(dx: rect.width * 0.08, dy: rect.height * 0.08)
        let backgroundPath = NSBezierPath(
            roundedRect: backgroundRect,
            xRadius: rect.width * 0.22,
            yRadius: rect.height * 0.22
        )

        let shadow = NSShadow()
        shadow.shadowColor = NSColor(calibratedWhite: 0.0, alpha: 0.22)
        shadow.shadowBlurRadius = rect.width * 0.05
        shadow.shadowOffset = NSSize(width: 0, height: -rect.height * 0.015)
        shadow.set()

        let gradient = NSGradient(
            colors: [
                NSColor(calibratedRed: 0.18, green: 0.69, blue: 0.88, alpha: 1.0),
                NSColor(calibratedRed: 0.09, green: 0.56, blue: 0.78, alpha: 1.0),
                NSColor(calibratedRed: 0.05, green: 0.40, blue: 0.65, alpha: 1.0),
            ]
        )
        gradient?.draw(in: backgroundPath, angle: 90)

        NSGraphicsContext.current?.saveGraphicsState()
        backgroundPath.addClip()

        let glowRect = CGRect(
            x: rect.width * 0.55,
            y: rect.height * 0.48,
            width: rect.width * 0.42,
            height: rect.height * 0.42
        )
        let glowPath = NSBezierPath(ovalIn: glowRect)
        NSColor(calibratedRed: 0.93, green: 0.98, blue: 1.0, alpha: 0.18).setFill()
        glowPath.fill()

        let highlightRect = CGRect(
            x: rect.width * 0.16,
            y: rect.height * 0.66,
            width: rect.width * 0.54,
            height: rect.height * 0.16
        )
        let highlightPath = NSBezierPath(
            roundedRect: highlightRect,
            xRadius: rect.height * 0.08,
            yRadius: rect.height * 0.08
        )
        NSColor(calibratedWhite: 1.0, alpha: 0.12).setFill()
        highlightPath.fill()

        NSGraphicsContext.current?.restoreGraphicsState()
    }

    private func drawClipboard(in rect: CGRect) {
        let boardRect = CGRect(
            x: rect.width * 0.24,
            y: rect.height * 0.18,
            width: rect.width * 0.52,
            height: rect.height * 0.62
        )

        let boardShadow = NSShadow()
        boardShadow.shadowColor = NSColor(calibratedWhite: 0.0, alpha: 0.18)
        boardShadow.shadowBlurRadius = rect.width * 0.035
        boardShadow.shadowOffset = NSSize(width: 0, height: -rect.height * 0.012)
        boardShadow.set()

        let boardPath = NSBezierPath(
            roundedRect: boardRect,
            xRadius: rect.width * 0.06,
            yRadius: rect.width * 0.06
        )
        NSColor(calibratedRed: 0.98, green: 0.99, blue: 1.0, alpha: 1.0).setFill()
        boardPath.fill()

        NSColor(calibratedRed: 0.80, green: 0.86, blue: 0.91, alpha: 1.0).setStroke()
        boardPath.lineWidth = rect.width * 0.008
        boardPath.stroke()

        drawClip(in: rect, boardRect: boardRect)
        drawPathMarkings(in: rect, boardRect: boardRect)
    }

    private func drawClip(in rect: CGRect, boardRect: CGRect) {
        let clipRect = CGRect(
            x: boardRect.minX + boardRect.width * 0.24,
            y: boardRect.maxY - rect.height * 0.04,
            width: boardRect.width * 0.52,
            height: rect.height * 0.12
        )

        let clipPath = NSBezierPath(
            roundedRect: clipRect,
            xRadius: rect.width * 0.05,
            yRadius: rect.width * 0.05
        )

        let clipGradient = NSGradient(
            colors: [
                NSColor(calibratedRed: 0.26, green: 0.78, blue: 0.56, alpha: 1.0),
                NSColor(calibratedRed: 0.15, green: 0.63, blue: 0.46, alpha: 1.0),
            ]
        )
        clipGradient?.draw(in: clipPath, angle: 90)

        let notchRect = CGRect(
            x: clipRect.minX + clipRect.width * 0.22,
            y: clipRect.minY + clipRect.height * 0.28,
            width: clipRect.width * 0.56,
            height: clipRect.height * 0.44
        )
        let notchPath = NSBezierPath(
            roundedRect: notchRect,
            xRadius: rect.width * 0.025,
            yRadius: rect.width * 0.025
        )
        NSColor(calibratedRed: 0.10, green: 0.46, blue: 0.37, alpha: 0.28).setFill()
        notchPath.fill()
    }

    private func drawPathMarkings(in rect: CGRect, boardRect: CGRect) {
        let contentRect = boardRect.insetBy(dx: boardRect.width * 0.14, dy: boardRect.height * 0.14)

        let lineColor = NSColor(calibratedRed: 0.20, green: 0.37, blue: 0.48, alpha: 0.22)
        for offset in [0.72, 0.20] {
            let lineRect = CGRect(
                x: contentRect.minX,
                y: contentRect.minY + contentRect.height * offset,
                width: contentRect.width * 0.72,
                height: rect.height * 0.035
            )
            let linePath = NSBezierPath(
                roundedRect: lineRect,
                xRadius: rect.height * 0.018,
                yRadius: rect.height * 0.018
            )
            lineColor.setFill()
            linePath.fill()
        }

        let routePath = NSBezierPath()
        routePath.move(to: CGPoint(x: contentRect.minX + contentRect.width * 0.08, y: contentRect.minY + contentRect.height * 0.58))
        routePath.line(to: CGPoint(x: contentRect.minX + contentRect.width * 0.44, y: contentRect.minY + contentRect.height * 0.58))
        routePath.line(to: CGPoint(x: contentRect.minX + contentRect.width * 0.44, y: contentRect.minY + contentRect.height * 0.38))
        routePath.line(to: CGPoint(x: contentRect.minX + contentRect.width * 0.82, y: contentRect.minY + contentRect.height * 0.38))
        NSColor(calibratedRed: 0.06, green: 0.30, blue: 0.45, alpha: 0.92).setStroke()
        routePath.lineWidth = rect.width * 0.036
        routePath.lineCapStyle = .round
        routePath.lineJoinStyle = .round
        routePath.stroke()

        for point in [
            CGPoint(x: contentRect.minX + contentRect.width * 0.08, y: contentRect.minY + contentRect.height * 0.58),
            CGPoint(x: contentRect.minX + contentRect.width * 0.44, y: contentRect.minY + contentRect.height * 0.38),
            CGPoint(x: contentRect.minX + contentRect.width * 0.82, y: contentRect.minY + contentRect.height * 0.38),
        ] {
            let nodeRect = CGRect(
                x: point.x - rect.width * 0.032,
                y: point.y - rect.width * 0.032,
                width: rect.width * 0.064,
                height: rect.width * 0.064
            )
            let nodePath = NSBezierPath(ovalIn: nodeRect)
            NSColor(calibratedRed: 0.25, green: 0.76, blue: 0.57, alpha: 1.0).setFill()
            nodePath.fill()
        }

        let slashPath = NSBezierPath()
        slashPath.move(to: CGPoint(x: contentRect.minX + contentRect.width * 0.64, y: contentRect.minY + contentRect.height * 0.80))
        slashPath.line(to: CGPoint(x: contentRect.minX + contentRect.width * 0.52, y: contentRect.minY + contentRect.height * 0.64))
        NSColor(calibratedRed: 0.95, green: 0.63, blue: 0.20, alpha: 1.0).setStroke()
        slashPath.lineWidth = rect.width * 0.04
        slashPath.lineCapStyle = .round
        slashPath.stroke()
    }

    private static let slots: [IconSlot] = [
        IconSlot(filename: "icon_16x16.png", pixelSize: 16),
        IconSlot(filename: "icon_16x16@2x.png", pixelSize: 32),
        IconSlot(filename: "icon_32x32.png", pixelSize: 32),
        IconSlot(filename: "icon_32x32@2x.png", pixelSize: 64),
        IconSlot(filename: "icon_128x128.png", pixelSize: 128),
        IconSlot(filename: "icon_128x128@2x.png", pixelSize: 256),
        IconSlot(filename: "icon_256x256.png", pixelSize: 256),
        IconSlot(filename: "icon_256x256@2x.png", pixelSize: 512),
        IconSlot(filename: "icon_512x512.png", pixelSize: 512),
        IconSlot(filename: "icon_512x512@2x.png", pixelSize: 1024),
    ]
}

func iconsetOutputURL() throws -> URL {
    let scriptURL = URL(fileURLWithPath: CommandLine.arguments[0]).standardizedFileURL
    let scriptDirectory = scriptURL.deletingLastPathComponent().deletingLastPathComponent()

    if CommandLine.arguments.count > 1 {
        return URL(fileURLWithPath: CommandLine.arguments[1], relativeTo: scriptDirectory).standardizedFileURL
    }

    return scriptDirectory.appendingPathComponent("Assets/AppIcon.iconset")
}

do {
    let outputURL = try iconsetOutputURL()
    try IconRenderer().writeIconSet(to: outputURL)
    print("Generated iconset at \(outputURL.path)")
} catch {
    fputs("Icon generation failed: \(error)\n", stderr)
    exit(1)
}
