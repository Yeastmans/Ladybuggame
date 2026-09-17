import XCTest
import SpriteKit
@testable import LadybugGame

final class GamePolishTests: XCTestCase {
    @MainActor
    func testAdventureUnlocksAndBestStarsSurviveReplayAndReopen() throws {
        let suite = "LadybugCampaignTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let progress = CampaignProgressStore(defaults: defaults)
        let first = CampaignStage.all[0]
        XCTAssertTrue(progress.isUnlocked(0))
        XCTAssertFalse(progress.isUnlocked(1))
        let clear = progress.completeStage(first, score: first.masteryScore, distance: first.targetDistance, hitsTaken: 1, livesRemaining: 2)
        XCTAssertEqual(clear.stars, 3)
        XCTAssertTrue(clear.isFirstClear)
        XCTAssertTrue(progress.isUnlocked(1))
        let replay = progress.completeStage(first, score: 10, distance: first.targetDistance, hitsTaken: 3, livesRemaining: 1)
        XCTAssertEqual(replay.stars, 1)
        XCTAssertFalse(replay.isFirstClear)
        XCTAssertEqual(replay.previousBestStars, 3)
        let reopened = CampaignProgressStore(defaults: defaults)
        XCTAssertEqual(reopened.record(for: 0).bestStars, 3)
        XCTAssertEqual(reopened.record(for: 0).bestScore, first.masteryScore)
        XCTAssertEqual(reopened.continueStageID, 1)
        XCTAssertFalse(reopened.isUnlocked(2))
    }

    @MainActor
    func testLegacyWalletMigrationAndRepeatedDelivery() throws {
        let suite = "LadybugWalletTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(125, forKey: "GemstoneCount")
        defaults.set(["hat_cap"], forKey: "OwnedShopItems")
        defaults.set(["17"], forKey: "GrantedStoreTransactionIDs")
        let wallet = PlayerWallet(defaults: defaults)
        XCTAssertEqual(wallet.gems, 125)
        XCTAssertEqual(wallet.ownedItems, ["hat_cap"])
        XCTAssertFalse(wallet.grantStoreGems(50, transactionID: 17))
        XCTAssertTrue(wallet.grantStoreGems(50, transactionID: 18))
        XCTAssertEqual(wallet.gems, 175)
        let reopened = PlayerWallet(defaults: defaults)
        XCTAssertEqual(reopened.gems, 175)
        XCTAssertFalse(reopened.grantStoreGems(50, transactionID: 18))
        XCTAssertTrue(reopened.unlockCosmetic("hat_leaf", price: 25))
        XCTAssertTrue(reopened.unlockCosmetic("hat_leaf", price: 25))
        XCTAssertEqual(reopened.gems, 150)
        let saved = PlayerWallet(defaults: defaults)
        XCTAssertEqual(saved.gems, 150)
        XCTAssertTrue(saved.ownedItems.contains("hat_leaf"))
        XCTAssertFalse(saved.unlockCosmetic("too_expensive", price: 151))
        XCTAssertFalse(saved.spendGems(-1))
        XCTAssertEqual(saved.gems, 150)
    }

    @MainActor
    func testFlightMatchesAcrossRefreshRatesAndReleaseLands() {
        func trajectory(fps: Int) -> [CGFloat] {
            let dimensions = CGSize(width: 48, height: 48)
            let texture = TextureGenerator.generateLadybugTexture(size: dimensions)
            let bug = Ladybug(walkTexture: texture, blinkTexture: texture, flyFrames: [texture])
            bug.position.y = 72
            var samples: [CGFloat] = []
            for frame in 0..<(fps * 5) {
                bug.targetY = frame < fps * 2 ? 220 : nil
                bug.updatePhysics(dt: 1 / Double(fps), groundY: 72, ceilingY: 300)
                if (frame + 1).isMultiple(of: fps) { samples.append(bug.position.y) }
            }
            XCTAssertTrue(bug.isOnGround)
            return samples
        }
        let sixty = trajectory(fps: 60)
        for fps in [30, 120] {
            let samples = trajectory(fps: fps)
            for (a, b) in zip(samples, sixty) { XCTAssertEqual(a, b, accuracy: 0.75) }
        }
    }

    @MainActor
    func testFingerOffsetFlightRelativeAnchorAndScreenEdges() {
        let texture = TextureGenerator.generateLadybugTexture(size: CGSize(width: 48, height: 48))
        let bug = Ladybug(walkTexture: texture, blinkTexture: texture, flyFrames: [texture])
        bug.position.y = 72
        bug.targetY = FlightControls.targetY(fingerY: 130, startFingerY: 130, startBugY: 72,
                                            relative: false, offset: 60)
        for _ in 0..<300 { bug.updatePhysics(dt: 1 / 60, groundY: 72, ceilingY: 300) }
        XCTAssertEqual(bug.position.y, 190, accuracy: 1)
        // A touch near the top still keeps the bug inside the playable ceiling.
        bug.targetY = FlightControls.targetY(fingerY: 295, startFingerY: 295, startBugY: bug.position.y,
                                            relative: false, offset: 80)
        for _ in 0..<120 { bug.updatePhysics(dt: 1 / 60, groundY: 72, ceilingY: 300) }
        XCTAssertEqual(bug.position.y, 300, accuracy: 0.1)
        bug.targetY = nil
        for _ in 0..<180 { bug.updatePhysics(dt: 1 / 60, groundY: 72, ceilingY: 300) }
        XCTAssertTrue(bug.isOnGround, "Releasing must still land with finger offset enabled")
        // Relative input starts at the bug, even when the finger touches far away.
        XCTAssertEqual(FlightControls.targetY(fingerY: 30, startFingerY: 30, startBugY: 200,
                                              relative: true, offset: 60), 200)
        XCTAssertEqual(FlightControls.targetY(fingerY: 60, startFingerY: 30, startBugY: 200,
                                              relative: true, offset: 60), 230)
        XCTAssertEqual(FlightControls.targetY(fingerY: 130, startFingerY: 0, startBugY: 72,
                                              relative: false, offset: 0), 130)
    }

    @MainActor
    func testSpaceNeverLandsAndShelterPreventsTakeoff() {
        let texture = TextureGenerator.generateLadybugTexture(size: CGSize(width: 48, height: 48))
        let bug = Ladybug(walkTexture: texture, blinkTexture: texture, flyFrames: [texture])
        bug.position.y = 48
        bug.isInsideLog = true
        bug.targetY = 240
        bug.updatePhysics(dt: 0.1, groundY: 48, ceilingY: 280)
        XCTAssertTrue(bug.isOnGround)
        bug.isInsideLog = false
        bug.targetY = nil
        for _ in 0..<600 {
            bug.updatePhysics(dt: 1 / 60, groundY: 24, ceilingY: 280, allowsLanding: false, gravityScale: 0.18)
        }
        XCTAssertFalse(bug.isOnGround)
        XCTAssertGreaterThanOrEqual(bug.position.y, 24)
    }

    func testPacingPreservesEndlessAndProvidesRecovery() {
        XCTAssertEqual(EncounterPacing.enemyTimeScale(distance: 500, targetDistance: nil), 1)
        XCTAssertLessThan(EncounterPacing.enemyTimeScale(distance: 400, targetDistance: 11000), 1)
        XCTAssertLessThan(EncounterPacing.enemyTimeScale(distance: 2400, targetDistance: 11000), 1)
        XCTAssertEqual(EncounterPacing.enemyTimeScale(distance: 5500, targetDistance: 11000), 1)
    }

    @MainActor
    func testEveryOutfitCanRenderAndAllScenesFit() throws {
        for item in ShopScene.allItems {
            let preview = CosmeticArt.preview(item: item)
            XCTAssertFalse(preview.calculateAccumulatedFrame().isEmpty, item.id)
        }
        // Concrete button bounds; screenshots remain a separate visual gate.
        for dimensions in [CGSize(width: 568, height: 320), CGSize(width: 852, height: 393)] {
            for scene in [MenuScene(size: dimensions), SettingsScene(size: dimensions),
                          ShopScene(size: dimensions), BugopediaScene(size: dimensions)] as [GameScreenScene] {
                scene.rebuild()
                for controlsPage in [false, true] {
                    if controlsPage {
                        guard let settings = scene as? SettingsScene else { continue }
                        settings.activate("control")
                    }
                    scene.enumerateChildNodes(withName: "//*") { node, _ in
                        guard node.userData?["action"] != nil else { return }
                        let center = node.parent!.convert(node.position, to: scene)
                        XCTAssertTrue(scene.frame.contains(center), "\(type(of: scene)): \(node.name ?? "button")")
                        for point in [CGPoint(x: node.frame.minX, y: node.frame.minY), CGPoint(x: node.frame.maxX, y: node.frame.maxY)] {
                            let converted = node.parent!.convert(point, to: scene)
                            XCTAssertTrue(scene.frame.contains(converted), "Button outside scene: \(node.name ?? "button")")
                        }
                    }
                }
            }
        }
    }
}
