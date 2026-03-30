#!/usr/bin/env swift
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let size = 1024
let w = CGFloat(size)
let h = CGFloat(size)

let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8,
                          bytesPerRow: size * 4, space: colorSpace,
                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    print("Failed to create context")
    exit(1)
}

// === Background — soft green gradient ===
let bgColors: [CGFloat] = [
    0.35, 0.68, 0.25, 1.0,  // top green
    0.28, 0.55, 0.18, 1.0,  // bottom green
]
if let gradient = CGGradient(colorSpace: colorSpace, colorComponents: bgColors, locations: [0, 1], count: 2) {
    ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: h), end: CGPoint(x: 0, y: 0), options: [])
}

// Subtle radial highlight behind ladybug
let hlColors: [CGFloat] = [
    0.45, 0.78, 0.35, 0.4,
    0.35, 0.68, 0.25, 0.0,
]
if let hl = CGGradient(colorSpace: colorSpace, colorComponents: hlColors, locations: [0, 1], count: 2) {
    ctx.drawRadialGradient(hl, startCenter: CGPoint(x: w * 0.48, y: h * 0.52), startRadius: 0,
                           endCenter: CGPoint(x: w * 0.48, y: h * 0.52), endRadius: w * 0.45, options: [])
}

// === Ladybug body (red dome, side view) ===
let bodyRect = CGRect(x: w * 0.12, y: h * 0.22, width: w * 0.58, height: h * 0.52)
ctx.setFillColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 1.0)
ctx.fillEllipse(in: bodyRect)
// Body outline
ctx.setStrokeColor(red: 0.55, green: 0.05, blue: 0.05, alpha: 1.0)
ctx.setLineWidth(w * 0.02)
ctx.strokeEllipse(in: bodyRect)

// Spots
ctx.setFillColor(red: 0.10, green: 0.05, blue: 0.05, alpha: 1.0)
ctx.fillEllipse(in: CGRect(x: w * 0.22, y: h * 0.30, width: w * 0.12, height: w * 0.12))
ctx.fillEllipse(in: CGRect(x: w * 0.42, y: h * 0.28, width: w * 0.14, height: w * 0.14))
ctx.fillEllipse(in: CGRect(x: w * 0.34, y: h * 0.48, width: w * 0.10, height: w * 0.10))
ctx.fillEllipse(in: CGRect(x: w * 0.54, y: h * 0.38, width: w * 0.11, height: w * 0.11))
ctx.fillEllipse(in: CGRect(x: w * 0.58, y: h * 0.52, width: w * 0.07, height: w * 0.07))
ctx.fillEllipse(in: CGRect(x: w * 0.18, y: h * 0.48, width: w * 0.08, height: w * 0.08))

// Body shine
ctx.setFillColor(red: 1.0, green: 0.40, blue: 0.35, alpha: 0.15)
ctx.fillEllipse(in: CGRect(x: w * 0.20, y: h * 0.26, width: w * 0.25, height: h * 0.18))

// === Head (black circle) ===
let headR = w * 0.14
let headCX = w * 0.78
let headCY = h * 0.48
ctx.setFillColor(red: 0.10, green: 0.08, blue: 0.08, alpha: 1.0)
ctx.fillEllipse(in: CGRect(x: headCX - headR, y: headCY - headR, width: headR * 2, height: headR * 2))

// === Antennae ===
ctx.setStrokeColor(red: 0.10, green: 0.08, blue: 0.08, alpha: 1.0)
ctx.setLineWidth(w * 0.018)
ctx.setLineCap(.round)
// Front antenna
ctx.move(to: CGPoint(x: headCX + headR * 0.2, y: headCY + headR * 0.6))
ctx.addQuadCurve(to: CGPoint(x: w * 0.92, y: h * 0.78), control: CGPoint(x: w * 0.88, y: h * 0.68))
ctx.strokePath()
// Back antenna
ctx.move(to: CGPoint(x: headCX + headR * 0.1, y: headCY + headR * 0.3))
ctx.addQuadCurve(to: CGPoint(x: w * 0.88, y: h * 0.72), control: CGPoint(x: w * 0.86, y: h * 0.62))
ctx.strokePath()
// Tips
ctx.setFillColor(red: 0.10, green: 0.08, blue: 0.08, alpha: 1.0)
ctx.fillEllipse(in: CGRect(x: w * 0.91, y: h * 0.77, width: w * 0.025, height: w * 0.025))
ctx.fillEllipse(in: CGRect(x: w * 0.87, y: h * 0.71, width: w * 0.02, height: w * 0.02))

// === Eye (big, friendly) ===
let eyeR = headR * 0.55
ctx.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
ctx.fillEllipse(in: CGRect(x: headCX + headR * 0.15, y: headCY - eyeR * 0.1, width: eyeR, height: eyeR))
// Pupil
ctx.setFillColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
ctx.fillEllipse(in: CGRect(x: headCX + headR * 0.35, y: headCY + eyeR * 0.1, width: eyeR * 0.5, height: eyeR * 0.5))
// Shine
ctx.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
ctx.fillEllipse(in: CGRect(x: headCX + headR * 0.25, y: headCY + eyeR * 0.35, width: eyeR * 0.22, height: eyeR * 0.22))

// === Cheek blush ===
ctx.setFillColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 0.25)
ctx.fillEllipse(in: CGRect(x: headCX - headR * 0.2, y: headCY - headR * 0.5, width: headR * 0.7, height: headR * 0.35))

// === Legs ===
ctx.setStrokeColor(red: 0.10, green: 0.08, blue: 0.08, alpha: 1.0)
ctx.setLineWidth(w * 0.015)
for lx in [0.22, 0.38, 0.55] as [CGFloat] {
    ctx.move(to: CGPoint(x: w * lx, y: h * 0.25))
    ctx.addLine(to: CGPoint(x: w * (lx - 0.02), y: h * 0.12))
    ctx.addLine(to: CGPoint(x: w * (lx + 0.02), y: h * 0.06))
    ctx.strokePath()
}

// === Save PNG ===
guard let image = ctx.makeImage() else {
    print("Failed to create image")
    exit(1)
}

let outputDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
let outputPath = "\(outputDir)/AppIcon.png"
let url = URL(fileURLWithPath: outputPath)

guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    print("Failed to create destination")
    exit(1)
}
CGImageDestinationAddImage(dest, image, nil)
guard CGImageDestinationFinalize(dest) else {
    print("Failed to write PNG")
    exit(1)
}
print("Generated \(outputPath) (\(size)x\(size))")
