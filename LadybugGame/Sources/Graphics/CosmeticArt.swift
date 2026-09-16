import SpriteKit
import UIKit

/// One renderer for the menu, dressing room, and player: every sold hat is visible.
@MainActor
enum CosmeticArt {
    static func hatTexture(id: String, size: CGSize) -> SKTexture {
        switch id {
        case "hat_tophat": return TextureGenerator.generateTopHatTexture(size: size)
        case "hat_cap": return TextureGenerator.generateCapTexture(size: size)
        case "hat_crown": return TextureGenerator.generateCrownTexture(size: size)
        case "hat_flower": return TextureGenerator.generateFlowerHatTexture(size: size)
        default: break
        }
        let image = UIGraphicsImageRenderer(size: size).image { renderer in
            let c = renderer.cgContext
            c.scaleBy(x: size.width / 32, y: size.height / 26)
            c.setLineWidth(1.5)
            c.setLineJoin(.round)
            c.setStrokeColor(UIColor(red: 0.12, green: 0.08, blue: 0.18, alpha: 1).cgColor)
            func ellipse(_ rect: CGRect, _ color: UIColor) {
                c.setFillColor(color.cgColor); c.fillEllipse(in: rect); c.strokeEllipse(in: rect)
            }
            func polygon(_ points: [CGPoint], _ color: UIColor) {
                guard let first = points.first else { return }
                c.beginPath(); c.move(to: first)
                points.dropFirst().forEach { c.addLine(to: $0) }
                c.closePath(); c.setFillColor(color.cgColor); c.drawPath(using: .fillStroke)
            }
            let gold = UIColor(red: 1, green: 0.78, blue: 0.22, alpha: 1)
            switch id {
            case "hat_wizard", "hat_party":
                let color: UIColor = id == "hat_wizard" ? .systemIndigo : .systemPink
                polygon([CGPoint(x: 4, y: 22), CGPoint(x: 17, y: 2), CGPoint(x: 28, y: 22)], color)
                ellipse(CGRect(x: 1, y: 20, width: 30, height: 4), color)
                ellipse(CGRect(x: 14, y: 11, width: 4, height: 4), gold)
            case "hat_pirate":
                polygon([CGPoint(x: 1, y: 21), CGPoint(x: 4, y: 7), CGPoint(x: 16, y: 12), CGPoint(x: 28, y: 7), CGPoint(x: 31, y: 21)], .darkGray)
                ellipse(CGRect(x: 12, y: 13, width: 8, height: 6), .white)
            case "hat_chef":
                c.setFillColor(UIColor.white.cgColor); c.fill(CGRect(x: 8, y: 10, width: 17, height: 13))
                for x in [4, 11, 18] { ellipse(CGRect(x: CGFloat(x), y: 3, width: 11, height: 12), .white) }
            case "hat_cowboy":
                ellipse(CGRect(x: 2, y: 18, width: 28, height: 6), .brown)
                polygon([CGPoint(x: 8, y: 19), CGPoint(x: 9, y: 5), CGPoint(x: 16, y: 9), CGPoint(x: 23, y: 5), CGPoint(x: 25, y: 19)], .systemBrown)
            case "hat_beanie":
                ellipse(CGRect(x: 5, y: 5, width: 23, height: 18), .systemTeal)
                ellipse(CGRect(x: 12, y: 1, width: 9, height: 8), .systemPink)
            case "hat_halo":
                c.setStrokeColor(gold.cgColor); c.setLineWidth(3)
                c.strokeEllipse(in: CGRect(x: 4, y: 5, width: 24, height: 7))
            case "hat_horns":
                polygon([CGPoint(x: 3, y: 22), CGPoint(x: 3, y: 3), CGPoint(x: 13, y: 22)], .systemRed)
                polygon([CGPoint(x: 19, y: 22), CGPoint(x: 29, y: 3), CGPoint(x: 29, y: 22)], .systemRed)
            case "hat_bow":
                polygon([CGPoint(x: 3, y: 5), CGPoint(x: 16, y: 13), CGPoint(x: 3, y: 22)], .systemPink)
                polygon([CGPoint(x: 29, y: 5), CGPoint(x: 16, y: 13), CGPoint(x: 29, y: 22)], .systemPink)
                ellipse(CGRect(x: 12, y: 10, width: 8, height: 8), .systemRed)
            case "hat_mushroom":
                c.setFillColor(UIColor.systemYellow.cgColor); c.fill(CGRect(x: 12, y: 12, width: 8, height: 12))
                ellipse(CGRect(x: 2, y: 3, width: 28, height: 15), .systemRed)
                for x in [7, 16, 23] { ellipse(CGRect(x: CGFloat(x), y: 7, width: 4, height: 4), .white) }
            case "hat_leaf":
                c.saveGState(); c.translateBy(x: 16, y: 13); c.rotate(by: -0.45)
                ellipse(CGRect(x: -12, y: -6, width: 25, height: 12), .systemGreen)
                c.move(to: CGPoint(x: -10, y: 0)); c.addLine(to: CGPoint(x: 13, y: 0)); c.strokePath(); c.restoreGState()
            case "hat_gem":
                polygon([CGPoint(x: 5, y: 9), CGPoint(x: 11, y: 2), CGPoint(x: 23, y: 2), CGPoint(x: 29, y: 9), CGPoint(x: 17, y: 24)], .systemCyan)
                polygon([CGPoint(x: 11, y: 3), CGPoint(x: 16, y: 9), CGPoint(x: 7, y: 9)], .white)
            default: break
            }
        }
        return SKTexture(image: image)
    }

    static func preview(item: ShopScene.ShopItem? = nil, size: CGFloat = 86) -> SKNode {
        func selected(_ tab: ShopScene.Tab, fallback: String?) -> ShopScene.ShopItem? {
            if let item, item.tab == tab { return item }
            return ShopScene.allItems.first { $0.id == fallback }
        }
        let body = selected(.colors, fallback: ShopScene.equippedColor)?.color
        let spots = selected(.spots, fallback: ShopScene.equippedSpots)?.color
        let hatID = selected(.hats, fallback: ShopScene.equippedHat)?.id
        let dimensions = CGSize(width: size, height: size)
        let texture: SKTexture
        if item?.tab == .wings {
            let color = selected(.wings, fallback: ShopScene.equippedWings)?.color
            texture = TextureGenerator.generateLadybugFlyFrames(size: dimensions, bodyColor: body,
                hideAntennae: hatID != nil, wingColor: color, spotColor: spots)[0]
        } else {
            texture = TextureGenerator.generateLadybugTexture(size: dimensions, bodyColor: body,
                hideAntennae: hatID != nil, spotColor: spots)
        }
        let node = SKSpriteNode(texture: texture)
        if let hatID {
            let hat = SKSpriteNode(texture: hatTexture(id: hatID, size: CGSize(width: size * 0.42, height: size * 0.34)))
            hat.position = CGPoint(x: size * 0.33, y: size * 0.21)
            hat.zPosition = 3
            node.addChild(hat)
        }
        if let color = selected(.shoes, fallback: ShopScene.equippedShoes)?.color {
            for offset in [CGFloat(-0.23), -0.08, 0.08] {
                let shoe = SKShapeNode(ellipseOf: CGSize(width: size * 0.13, height: size * 0.08))
                shoe.fillColor = color; shoe.strokeColor = .clear
                shoe.position = CGPoint(x: size * offset, y: -size * 0.43)
                node.addChild(shoe)
            }
        }
        return node
    }
}
