import XCTest

final class GameScreenshots: XCTestCase {
    @MainActor
    func testMenuTutorialAndPauseNavigation() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "-FlightSchoolCompletedV1", "NO"]
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
        let resume = app.buttons["▶  Resume Run"]
        XCTAssertTrue(resume.waitForExistence(timeout: 5))
        app.buttons["Back to Menu"].tap()
        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 5))
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.buttons["Practice flying"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testScreensAtLandscapePhoneSize() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication()
        let screens = ["menu", "map", "settings", "collection", "shop", "hat-preview", "tutorial", "stage-clear", "game-over", "pause"]
            + (0..<16).map { "biome-\($0)" }
        for screen in screens {
            app.launchArguments = ["--ui-testing", "--preview-screen", screen]
            app.launch()
            XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
            // A short animation settle before capturing actual SpriteKit output.
            let settled = expectation(description: "scene rendered")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { settled.fulfill() }
            wait(for: [settled], timeout: 4)
            let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            attachment.name = screen
            attachment.lifetime = .keepAlways
            add(attachment)
            app.terminate()
        }
    }
}
