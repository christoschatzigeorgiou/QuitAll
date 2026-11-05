#!/usr/bin/env swift
// Erzeugt AppIcon.icns: usage: make-icon.swift <output.icns>
import AppKit

func render(_ px: Int) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let s = CGFloat(px)
    let inset = s * 0.098
    let rect = NSRect(x: inset, y: inset, width: s - 2 * inset, height: s - 2 * inset)
    let path = NSBezierPath(roundedRect: rect, xRadius: rect.width * 0.225, yRadius: rect.width * 0.225)

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.35)
    shadow.shadowBlurRadius = s * 0.02
    shadow.shadowOffset = NSSize(width: 0, height: -s * 0.012)
    shadow.set()
    NSColor.black.setFill()
    path.fill()
    NSGraphicsContext.restoreGraphicsState()

    NSGradient(colors: [NSColor(red: 1.0, green: 0.42, blue: 0.36, alpha: 1),
                        NSColor(red: 0.75, green: 0.10, blue: 0.30, alpha: 1)])!
        .draw(in: path, angle: -90)

    // Power-Symbol
    let c = NSPoint(x: s / 2, y: s / 2 - s * 0.01)
    let r = s * 0.20
    let lw = s * 0.06
    NSColor.white.setStroke()
    let arc = NSBezierPath()
    arc.appendArc(withCenter: c, radius: r, startAngle: 120, endAngle: 60, clockwise: false)
    arc.lineWidth = lw
    arc.lineCapStyle = .round
    arc.stroke()
    let bar = NSBezierPath()
    bar.move(to: NSPoint(x: c.x, y: c.y + r * 0.15))
    bar.line(to: NSPoint(x: c.x, y: c.y + r * 1.25))
    bar.lineWidth = lw
    bar.lineCapStyle = .round
    bar.stroke()

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

let out = CommandLine.arguments[1]
let dir = out + ".iconset"
try? FileManager.default.removeItem(atPath: dir)
try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
for base in [16, 32, 128, 256, 512] {
    try render(base).write(to: URL(fileURLWithPath: "\(dir)/icon_\(base)x\(base).png"))
    try render(base * 2).write(to: URL(fileURLWithPath: "\(dir)/icon_\(base)x\(base)@2x.png"))
}
let p = Process()
p.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
p.arguments = ["-c", "icns", dir, "-o", out]
try p.run(); p.waitUntilExit()
try? FileManager.default.removeItem(atPath: dir)
