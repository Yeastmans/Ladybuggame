import CoreGraphics

/// Procedural undulating cave terrain using dual-octave sine waves.
/// Provides ground and ceiling height queries at any world X position.
class CaveTerrain {

    let baseGroundY: CGFloat
    let baseCeilingY: CGFloat
    private let amplitude: CGFloat = 20.0
    private let frequency: CGFloat = 0.008
    private let amplitude2: CGFloat = 8.0
    private let frequency2: CGFloat = 0.019

    private(set) var worldOffset: CGFloat = 0
    var transitionProgress: CGFloat = 0  // 0 = flat, 1 = full undulation

    init(baseGroundY: CGFloat, screenHeight: CGFloat) {
        self.baseGroundY = baseGroundY
        self.baseCeilingY = screenHeight * 0.82
    }

    /// Ground surface Y at a world X position.
    func groundY(atWorldX worldX: CGFloat) -> CGFloat {
        let wave1 = sin(worldX * frequency) * amplitude
        let wave2 = sin(worldX * frequency2 + 1.3) * amplitude2
        return baseGroundY + (wave1 + wave2) * transitionProgress
    }

    /// Ceiling surface Y at a world X position.
    func ceilingY(atWorldX worldX: CGFloat) -> CGFloat {
        let wave1 = sin(worldX * frequency * 0.7 + 2.0) * amplitude * 0.8
        let wave2 = sin(worldX * frequency2 * 0.9 + 3.5) * amplitude2
        return baseCeilingY + (wave1 + wave2) * transitionProgress
    }

    /// Ground Y for a screen-space X, accounting for current scroll offset.
    func groundY(atScreenX screenX: CGFloat) -> CGFloat {
        groundY(atWorldX: screenX + worldOffset)
    }

    /// Ceiling Y for a screen-space X, accounting for current scroll offset.
    func ceilingY(atScreenX screenX: CGFloat) -> CGFloat {
        ceilingY(atWorldX: screenX + worldOffset)
    }

    /// Advance the world offset by scroll delta each frame.
    func update(scrollDelta: CGFloat) {
        worldOffset += scrollDelta
    }

    /// Smoothly ramp transition progress toward target over ~600px of scrolling.
    func advanceTransition(delta: CGFloat, targetProgress: CGFloat) {
        let rate = delta / 600.0
        if targetProgress > transitionProgress {
            transitionProgress = min(targetProgress, transitionProgress + rate)
        } else {
            transitionProgress = max(targetProgress, transitionProgress - rate)
        }
    }

    /// Generate a CGPath for a ground tile filling from y=0 up to the undulating surface.
    func groundTilePath(tileLeft: CGFloat, tileWidth: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        let step: CGFloat = 5.0
        var x: CGFloat = 0
        while x <= tileWidth {
            let surfaceY = groundY(atWorldX: tileLeft + worldOffset + x)
            path.addLine(to: CGPoint(x: x, y: surfaceY))
            x += step
        }
        path.addLine(to: CGPoint(x: tileWidth, y: 0))
        path.closeSubpath()
        return path
    }

    /// Generate a CGPath for a ceiling tile filling from the ceiling surface to the top.
    func ceilingTilePath(tileLeft: CGFloat, tileWidth: CGFloat, tileHeight: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: tileHeight))
        let step: CGFloat = 5.0
        var x: CGFloat = 0
        while x <= tileWidth {
            let surfaceY = ceilingY(atWorldX: tileLeft + worldOffset + x)
            path.addLine(to: CGPoint(x: x, y: surfaceY))
            x += step
        }
        path.addLine(to: CGPoint(x: tileWidth, y: tileHeight))
        path.closeSubpath()
        return path
    }
}
