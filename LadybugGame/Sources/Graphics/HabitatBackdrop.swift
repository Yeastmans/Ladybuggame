import SpriteKit
import UIKit

/// Quiet habitat silhouettes fill the opening view and scroll below all gameplay.
/// Each layer is flattened once into a generated texture, then wraps as two tiles.
@MainActor
enum HabitatBackdrop {
    static func install(in scene: SKScene, biome: Biome, groundY: CGFloat) {
        // Flat terrain gets a quiet illustrated cross-section, never a collider.
        if biome != .space && biome != .cave {
            let dimensions = CGSize(width: scene.size.width, height: groundY + 10)
            let texture = groundTexture(biome: biome, size: dimensions)
            addTiles(texture, in: scene, size: dimensions, y: 0, speed: 1, z: 0.2, alpha: 1)
        }
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
                sprite.alpha = depth == 0 ? 0.15 : 0.23
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
        format.scale = 2
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
            // Composite opacity once per layer, so overlapping leaves form a solid silhouette.
            c.setFillColor(palette.cgColor)
            c.setStrokeColor(palette.cgColor)
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
                    let treeH = biome == .jungle || biome == .swamp ? h : h * 0.70
                    let crownY = floor - treeH
                    c.setLineCap(.round)
                    c.setLineWidth(biome == .jungle ? 9 : 6)
                    c.move(to: CGPoint(x: x + 6, y: floor))
                    c.addQuadCurve(to: CGPoint(x: x, y: crownY), control: CGPoint(x: x - 9, y: floor - treeH * 0.5))
                    c.strokePath()
                    for side in [-1, 1] as [CGFloat] {
                        c.setLineWidth(3)
                        c.move(to: CGPoint(x: x + 1, y: crownY + treeH * 0.38))
                        c.addQuadCurve(to: CGPoint(x: x + side * w * 0.4, y: crownY + treeH * 0.05),
                                      control: CGPoint(x: x + side * 14, y: crownY + treeH * 0.22))
                        c.strokePath()
                    }
                    if biome == .jungle {
                        for frond in 0..<7 {
                            let angle = CGFloat(frond) * .pi / 6
                            leaf(in: c, from: CGPoint(x: x, y: crownY + 14),
                                 to: CGPoint(x: x + cos(angle) * w * 0.68, y: crownY + 10 - sin(angle) * w * 0.43), width: 14)
                        }
                    } else {
                        let crown = CGMutablePath()
                        // Scalloped, asymmetric crowns rather than a row of circles.
                        crown.move(to: CGPoint(x: x-w*0.6, y: crownY+12))
                        crown.addCurve(to: CGPoint(x:x-w*0.25,y:crownY-w*0.25), control1:CGPoint(x:x-w*0.72,y:crownY-12),control2:CGPoint(x:x-w*0.4,y:crownY-w*0.35))
                        crown.addCurve(to: CGPoint(x:x+w*0.28,y:crownY-w*0.24), control1:CGPoint(x:x-w*0.12,y:crownY-w*0.58),control2:CGPoint(x:x+w*0.24,y:crownY-w*0.52))
                        crown.addCurve(to: CGPoint(x:x+w*0.61,y:crownY+16), control1:CGPoint(x:x+w*0.59,y:crownY-w*0.35),control2:CGPoint(x:x+w*0.75,y:crownY+1))
                        crown.addCurve(to: CGPoint(x:x-w*0.6,y:crownY+12), control1:CGPoint(x:x+w*0.35,y:crownY+w*0.32),control2:CGPoint(x:x-w*0.36,y:crownY+w*0.30))
                        crown.closeSubpath(); c.addPath(crown); c.fillPath()
                    }
                    if biome == .swamp {
                        c.setLineWidth(2)
                        for hanging in -2...2 {
                            let xx = x + CGFloat(hanging) * 12
                            c.move(to: CGPoint(x: xx, y: crownY+15))
                            c.addQuadCurve(to: CGPoint(x:xx+5,y:crownY+48+CGFloat(abs(hanging))*5), control:CGPoint(x:xx-8,y:crownY+35))
                            c.strokePath()
                        }
                    }
                case .desert:
                    c.beginPath(); c.move(to: CGPoint(x: x - spacing, y: floor))
                    c.addQuadCurve(to: CGPoint(x: x + spacing, y: floor), control: CGPoint(x: x, y: floor - h * 0.8))
                    c.closePath(); c.fillPath()
                case .snow, .volcano:
                    polygon([CGPoint(x: x - w, y: floor), CGPoint(x: x, y: floor - h), CGPoint(x: x + w, y: floor)])
                    c.saveGState()
                    c.setFillColor((biome == .snow ? UIColor.white : UIColor(red: 0.96, green: 0.40, blue: 0.17, alpha: 1)).withAlphaComponent(0.65).cgColor)
                    polygon([CGPoint(x:x,y:floor-h),CGPoint(x:x+w*0.26,y:floor-h*0.74),CGPoint(x:x+w*0.08,y:floor-h*0.81),CGPoint(x:x-w*0.05,y:floor-h*0.68),CGPoint(x:x-w*0.28,y:floor-h*0.72)])
                    c.restoreGState()
                case .ruins:
                    c.fill(CGRect(x: x - w / 2, y: floor - h, width: w * 0.18, height: h))
                    c.fill(CGRect(x: x + w * 0.32, y: floor - h, width: w * 0.18, height: h))
                    c.fill(CGRect(x: x - w * 0.60, y: floor - h, width: w * 1.2, height: 13))
                    c.fill(CGRect(x: x - w * 0.57, y: floor - 10, width: w * 1.14, height: 10))
                case .mushroom:
                    c.fill(CGRect(x: x - 7, y: floor - h * 0.75, width: 14, height: h * 0.75))
                    c.beginPath(); c.move(to: CGPoint(x:x-w*0.65,y:floor-h*0.64))
                    c.addCurve(to: CGPoint(x:x+w*0.65,y:floor-h*0.64), control1: CGPoint(x:x-w*0.55,y:floor-h*1.13), control2:CGPoint(x:x+w*0.42,y:floor-h*1.2))
                    c.addQuadCurve(to: CGPoint(x:x-w*0.65,y:floor-h*0.64),control:CGPoint(x:x,y:floor-h*0.48)); c.fillPath()
                    c.saveGState(); c.setFillColor(UIColor(white: 1, alpha: 0.3).cgColor)
                    for spot in -1...1 { c.fillEllipse(in: CGRect(x:x+CGFloat(spot)*w*0.27-4,y:floor-h*0.85+CGFloat(abs(spot))*8,width:8,height:5)) }
                    c.restoreGState()
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

    private static func addTiles(_ texture: SKTexture, in scene: SKScene, size: CGSize,
                                 y: CGFloat, speed: Double, z: CGFloat, alpha: CGFloat) {
        for tile in 0..<2 {
            let sprite = SKSpriteNode(texture: texture, size: CGSize(width: size.width + 1, height: size.height))
            sprite.anchorPoint = .zero
            sprite.position = CGPoint(x: CGFloat(tile) * size.width, y: y)
            sprite.zPosition = z; sprite.alpha = alpha
            sprite.name = "habitatBackdrop"
            sprite.userData = ["speed": speed, "period": Double(size.width)]
            scene.addChild(sprite)
        }
    }

    private static func leaf(in c: CGContext, from a: CGPoint, to b: CGPoint, width: CGFloat) {
        let dx = b.x-a.x, dy = b.y-a.y
        let length = max(1, hypot(dx,dy))
        let nx = -dy / length * width, ny = dx / length * width
        let mid = CGPoint(x:(a.x+b.x)/2, y:(a.y+b.y)/2)
        c.move(to:a)
        c.addQuadCurve(to:b, control:CGPoint(x:mid.x+nx,y:mid.y+ny))
        c.addQuadCurve(to:a, control:CGPoint(x:mid.x-nx*0.45,y:mid.y-ny*0.45))
        c.closePath(); c.fillPath()
    }

    private static func groundTexture(biome: Biome, size: CGSize) -> SKTexture {
        let format = UIGraphicsImageRendererFormat(); format.scale = 2
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            let c = context.cgContext
            let top: CGFloat = 10
            let base = biome.groundColor
            let bottom = IllustrationPaint.tint(base, toward: biome.dirtColor, amount: 0.72)
            c.saveGState(); c.clip(to: CGRect(x:0,y:top,width:size.width,height:size.height-top))
            let colors = [base.cgColor,bottom.cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),colors:colors,locations:[0,1]) {
                c.drawLinearGradient(gradient,start:CGPoint(x:0,y:top),end:CGPoint(x:0,y:size.height),options:[])
            }
            // Deterministic placement avoids generating a new pattern each visit.
            for i in 0..<70 {
                let x = CGFloat((i*137+Int(biome.rawValue)*17)%997)/997*size.width
                let y = top+12+CGFloat((i*43)%89)/89*max(1,size.height-top-20)
                c.setFillColor((i.isMultiple(of:3) ? UIColor.white : biome.dirtColor).withAlphaComponent(i.isMultiple(of:3) ? 0.09 : 0.23).cgColor)
                c.fillEllipse(in:CGRect(x:x,y:y,width:CGFloat(2+i%5),height:CGFloat(1+i%2)))
            }
            c.restoreGState()
            let grassy: Bool
            switch biome { case .meadowDay,.meadowNight,.jungle,.swamp,.city,.mushroom: grassy=true; default: grassy=false }
            if grassy {
                c.setFillColor(IllustrationPaint.tint(base,toward:.black,amount:0.18).cgColor)
                for i in 0..<Int(size.width/9) {
                    let x = CGFloat(i)*9+3
                    leaf(in:c,from:CGPoint(x:x,y:top+3),to:CGPoint(x:x-3,y:top-CGFloat(3+i%5)),width:2)
                    leaf(in:c,from:CGPoint(x:x,y:top+3),to:CGPoint(x:x+4,y:top-CGFloat(2+i%4)),width:1.5)
                }
            } else {
                c.setStrokeColor(IllustrationPaint.tint(base,toward:.white,amount:0.22).cgColor)
                c.setLineWidth(2)
                c.move(to:CGPoint(x:0,y:top+1)); c.addLine(to:CGPoint(x:size.width,y:top+1)); c.strokePath()
                if biome == .desert || biome == .mars || biome == .underwater {
                    c.setStrokeColor(biome.dirtColor.withAlphaComponent(0.24).cgColor); c.setLineWidth(1)
                    for i in 0..<12 {
                        let x=CGFloat(i)*size.width/12
                        let y=top+20+CGFloat(i%3)*12
                        c.move(to:CGPoint(x:x,y:y)); c.addQuadCurve(to:CGPoint(x:x+32,y:y),control:CGPoint(x:x+15,y:y-5)); c.strokePath()
                    }
                }
            }
        }
        return SKTexture(image:image)
    }
}
