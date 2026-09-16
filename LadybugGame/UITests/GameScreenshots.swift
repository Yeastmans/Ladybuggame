import XCTest

final class GameScreenshots: XCTestCase {
    @MainActor
    func testScreensAtLandscapePhoneSize() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication()
        for screen in ["menu", "map", "settings", "collection", "shop", "tutorial", "meadow", "night", "space"] {
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
