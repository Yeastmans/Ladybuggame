#if DEBUG && targetEnvironment(simulator)
import SpriteKit

/// Simulator-only contact sheet of the real generated textures, not mock artwork.
final class ArtReviewScene: GameScreenScene {
    override func rebuild() {
        removeAllChildren()
        backgroundColor = GameUITheme.ink
        let area = safeContentFrame
        label("Creature art · actual game textures", at: CGPoint(x: area.midX, y: area.maxY-20), fontSize: 23)
        let size = CGSize(width: 96, height: 96)
        let entries: [(String, SKTexture)] = [
            ("Walk", TextureGenerator.generateLadybugTexture(size:size)),
            ("Flight", TextureGenerator.generateLadybugFlyFrames(size:size)[0]),
            ("Blink", TextureGenerator.generateLadybugBlinkTexture(size:size)),
            ("Aphid", TextureGenerator.generateAphidTexture(size:size,color:.green)),
            ("Fruit fly", TextureGenerator.generateFruitFlyFrames(size:size,color:.blue)[0]),
            ("Beetle", TextureGenerator.generateFoodCreature(size:size,style:.beetle,body:.systemTeal,accent:.systemYellow)),
            ("Snail", TextureGenerator.generateFoodCreature(size:size,style:.snail,body:.systemOrange,accent:.systemYellow)),
            ("Bee", TextureGenerator.generateFoodCreature(size:size,style:.bee,body:.systemYellow,accent:.brown)),
            ("Moth", TextureGenerator.generateFoodCreature(size:size,style:.moth,body:.systemPurple,accent:.systemPink)),
            ("Frog", TextureGenerator.generateFrogTexture(size:size)),
        ]
        let cellW = (area.width-32)/5
        let cellH = (area.height-65)/2
        for (index,entry) in entries.enumerated() {
            let position = CGPoint(x:area.midX+CGFloat(index%5-2)*(cellW+6),y:area.maxY-55-cellH/2-CGFloat(index/5)*cellH)
            let panel = GameUITheme.makePanel(size:CGSize(width:cellW,height:cellH-9),cornerRadius:14,fillColor:SKColor(red:0.17,green:0.22,blue:0.27,alpha:1))
            panel.position=position; addChild(panel)
            let sprite = SKSpriteNode(texture:entry.1)
            let side = min(cellW-12,cellH-35)
            sprite.size=CGSize(width:side,height:side)
            sprite.position=CGPoint(x:0,y:8); panel.addChild(sprite)
            label(entry.0,at:CGPoint(x:0,y:-cellH/2+18),fontSize:12,parent:panel)
        }
    }
}
#endif
