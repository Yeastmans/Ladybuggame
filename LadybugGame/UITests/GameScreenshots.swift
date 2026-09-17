import XCTest

final class GameScreenshots: XCTestCase {
    @MainActor
    func testMenuTutorialAndPauseNavigation() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "-FlightSchoolCompletedV1", "NO",
                               "-SettingsRelativeDrag", "NO", "-SettingsControlOffset", "60"]
        app.launch()
        let play = app.buttons["Let's play"]
        XCTAssertTrue(play.waitForExistence(timeout: 15))
        play.tap()
        let skip = app.buttons["Skip"]
        XCTAssertTrue(skip.waitForExistence(timeout: 10))
        skip.tap()
        let pause = app.buttons["Pause game"]
        XCTAssertTrue(pause.waitForExistence(timeout: 10))
        pause.tap()
        let resume = app.buttons["Resume run"]
        XCTAssertTrue(resume.waitForExistence(timeout: 5))
        resume.tap()
        XCUIDevice.shared.press(.home)
        app.activate()
        XCTAssertTrue(resume.waitForExistence(timeout: 10), "Returning to the app must leave the run safely paused")
        app.buttons["Back to Menu"].tap()
        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 5))
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.buttons["Practice flying"].waitForExistence(timeout: 5))
        XCUIDevice.shared.orientation = .landscapeRight
        let rotated = expectation(description: "orientation animation settled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { rotated.fulfill() }
        wait(for: [rotated], timeout: 4)
        XCTAssertGreaterThan(app.windows.firstMatch.frame.width, app.windows.firstMatch.frame.height)
        XCTAssertTrue(app.buttons["Practice flying"].isHittable)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "settings-landscape-right"
        attachment.lifetime = .keepAlways
        add(attachment)
        app.buttons["Control: Follow finger"].tap()
        XCTAssertTrue(app.buttons["Finger offset: 60 pt"].waitForExistence(timeout: 5))
        let controls = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        controls.name = "finger-offset-controls"
        controls.lifetime = .keepAlways
        add(controls)
        app.buttons["Back"].tap()
        XCTAssertTrue(app.buttons["Practice flying"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testScreensAtLandscapePhoneSize() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication()
        let screens = ["menu", "map", "settings", "collection", "shop", "hat-preview", "tutorial", "stage-clear", "game-over", "pause", "art-gallery"]
            + (0..<16).map { "biome-\($0)" } + ["boss-1", "boss-2", "boss-3"]
        for screen in screens {
            app.launchArguments = ["--ui-testing", "--preview-screen", screen]
            app.launch()
            XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
            // A short animation settle before capturing actual SpriteKit output.
            let settled = expectation(description: "scene rendered")
            let delay: TimeInterval = screen.hasPrefix("boss-") ? 10 : 2
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { settled.fulfill() }
            wait(for: [settled], timeout: delay + 3)
            let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            attachment.name = screen
            attachment.lifetime = .keepAlways
            add(attachment)
            app.terminate()
        }
    }
}
