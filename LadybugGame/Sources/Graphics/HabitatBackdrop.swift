import SpriteKit
import UIKit

/// Quiet habitat silhouettes fill the opening view and scroll below all gameplay.
/// Each layer is flattened once into a generated texture, then wraps as two tiles.
@MainActor
enum HabitatBackdrop {
    static func install(in scene: SKScene, biome: Biome, groundY: CGFloat) {
        guard biome != .space && biome != .mars && biome != .underwater else { return }
        let height = scene.size.height * 0.48
        let dimensions = CGSize(width: scene.size.width, height: height)
        for depth in 0..<2 {
            let texture = silhouette(biome: biome, size: dimensions, depth: depth)
            for tile in 0..<2 {
                let sprite = SKSpriteNode(texture: texture, size: CGSize(width: dimensions.width + 1, height: height))
                sprite.anchorPoint = .zero
                sprite.position = CGPoint(x: CGFloat(tile) * dimensions.width, y: groundY - 4)
                sprite.zPosition = -0.65 + CGFloat(depth) * 0.025
                sprite.name = "habitatBackdrop"
                sprite.userData = ["speed": depth == 0 ? 0.12 : 0.22, "period": Double(dimensions.width)]
                scene.addChild(sprite)
            }
        }
    }

    static func scroll(in scene: SKScene, delta: CGFloat) {
        scene.enumerateChildNodes(withName: "habitatBackdrop") { node, _ in
            let speed = (node.userData?["speed"] as? Double) ?? 0.15
            let width = CGFloat((node.userData?["period"] as? Double) ?? Double(scene.size.width))
            node.position.x -= delta * CGFloat(speed)
            if node.position.x <= -width { node.position.x += width * 2 }
        }
    }

    private static func silhouette(biome: Biome, size: CGSize, depth: Int) -> SKTexture {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: size, format: format).image { renderer in
            let c = renderer.cgContext
            let palette: UIColor
            switch biome {
            case .meadowDay, .jungle, .swamp: palette = UIColor(red: 0.10, green: 0.29, blue: 0.22, alpha: 1)
            case .meadowNight, .cave: palette = UIColor(red: 0.40, green: 0.46, blue: 0.65, alpha: 1)
            case .snow: palette = UIColor(red: 0.36, green: 0.48, blue: 0.66, alpha: 1)
            case .desert, .ruins: palette = UIColor(red: 0.40, green: 0.27, blue: 0.24, alpha: 1)
            case .volcano: palette = UIColor(red: 0.24, green: 0.12, blue: 0.24, alpha: 1)
            case .cloud: palette = .white
            case .mushroom: palette = UIColor(red: 0.62, green: 0.42, blue: 0.68, alpha: 1)
            case .crystal: palette = UIColor(red: 0.49, green: 0.60, blue: 0.85, alpha: 1)
            default: palette = UIColor(red: 0.20, green: 0.40, blue: 0.36, alpha: 1)
            }
            c.setFillColor(palette.withAlphaComponent(depth == 0 ? 0.15 : 0.23).cgColor)
            c.setStrokeColor(palette.withAlphaComponent(depth == 0 ? 0.15 : 0.23).cgColor)
            let floor = size.height
            func polygon(_ points: [CGPoint]) {
                guard let first = points.first else { return }
                c.beginPath(); c.move(to: first)
                for point in points.dropFirst() { c.addLine(to: point) }
                c.closePath(); c.fillPath()
            }
            let count = biome == .city ? 10 : 6
            for index in 0..<count {
                let spacing = size.width / CGFloat(count)
                let x = (CGFloat(index) + 0.35 + CGFloat(depth) * 0.18) * spacing
                let h = size.height * (0.38 + CGFloat((index * 7 + depth * 3) % 5) * 0.10)
                let w = spacing * 0.72
                switch biome {
                case .meadowDay, .meadowNight, .jungle, .swamp:
                    let treeH = biome == .jungle || biome == .swamp ? h : h * 0.58
                    c.fill(CGRect(x: x - 5, y: floor - treeH, width: 10, height: treeH))
                    for puff in -1...1 {
                        c.fillEllipse(in: CGRect(x: x - w / 2 + CGFloat(puff) * w * 0.22,
                            y: floor - treeH - w * 0.18 + CGFloat(abs(puff)) * 9, width: w, height: w * 0.65))
                    }
                case .desert:
                    c.beginPath(); c.move(to: CGPoint(x: x - spacing, y: floor))
                    c.addQuadCurve(to: CGPoint(x: x + spacing, y: floor), control: CGPoint(x: x, y: floor - h * 0.8))
                    c.closePath(); c.fillPath()
                case .snow, .volcano:
                    polygon([CGPoint(x: x - w, y: floor), CGPoint(x: x, y: floor - h), CGPoint(x: x + w, y: floor)])
                case .ruins:
                    c.fill(CGRect(x: x - w / 2, y: floor - h, width: w * 0.18, height: h))
                    c.fill(CGRect(x: x + w * 0.32, y: floor - h, width: w * 0.18, height: h))
                    c.fill(CGRect(x: x - w * 0.60, y: floor - h, width: w * 1.2, height: 13))
                    c.fill(CGRect(x: x - w * 0.57, y: floor - 10, width: w * 1.14, height: 10))
                case .mushroom:
                    c.fill(CGRect(x: x - 7, y: floor - h * 0.75, width: 14, height: h * 0.75))
                    c.fillEllipse(in: CGRect(x: x - w * 0.62, y: floor - h, width: w * 1.24, height: h * 0.43))
                case .crystal, .cave:
                    polygon([CGPoint(x: x - w / 2, y: floor), CGPoint(x: x - w * 0.32, y: floor - h * 0.75),
                             CGPoint(x: x, y: floor - h), CGPoint(x: x + w * 0.24, y: floor - h * 0.72), CGPoint(x: x + w / 2, y: floor)])
                    c.saveGState(); c.setFillColor(UIColor(white: 1, alpha: 0.035).cgColor)
                    polygon([CGPoint(x: x, y: floor), CGPoint(x: x, y: floor - h), CGPoint(x: x + w * 0.24, y: floor - h * 0.72)])
                    c.restoreGState()
                case .cloud:
                    for puff in 0..<3 {
                        c.fillEllipse(in: CGRect(x: x - w / 2 + CGFloat(puff) * 25,
                            y: floor - h * 0.40 - CGFloat(puff % 2) * 13, width: w * 0.7, height: h * 0.45))
                    }
                case .city:
                    c.fill(CGRect(x: x - 8, y: floor - h * 0.55, width: 16, height: h * 0.55))
                    polygon([CGPoint(x: x - 8, y: floor - h * 0.55), CGPoint(x: x, y: floor - h * 0.55 - 9), CGPoint(x: x + 8, y: floor - h * 0.55)])
                    c.fill(CGRect(x: x - spacing / 2, y: floor - 20, width: spacing + 1, height: 8))
                default: break
                }
            }
        }
        return SKTexture(image: image)
    }
}
