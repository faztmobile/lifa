import XCTest

/// XCUITest for the gallery (step 2): launches, renders in dark mode and at the largest accessibility text size,
/// passes Xcode's built-in accessibility audit, and toggles a switch.
final class GalleryUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    func testLaunchesAndPassesAccessibilityAudit() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Lifa design system"].waitForExistence(timeout: 10))
        capturePages(app, "light")
        app.terminate()
        app.launch()
        try app.performAccessibilityAudit() // contrast, hit regions, Dynamic Type, labels (iOS 17+)
    }

    func testDarkModeAndLargestText() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-LifaForceDark", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Lifa design system"].waitForExistence(timeout: 10))
        capturePages(app, "dark-axxxl")
        app.terminate()
        app.launch()
        try app.performAccessibilityAudit(for: [.dynamicType, .textClipped, .contrast])
    }

    func testDarkModeScreenshots() {
        let app = XCUIApplication()
        app.launchArguments += ["-LifaForceDark"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Lifa design system"].waitForExistence(timeout: 10))
        capturePages(app, "dark")
    }

    func testToggleRowSwitchesOn() {
        let app = XCUIApplication()
        app.launch()
        let toggle = app.switches["Pause while I travel"]
        for _ in 0..<12 where !toggle.isHittable { app.swipeUp() }
        XCTAssertEqual(toggle.value as? String, "0")
        toggle.tap()
        XCTAssertEqual(toggle.value as? String, "1")
    }

    /// Screenshots of the whole gallery, one per screen height.
    private func capturePages(_ app: XCUIApplication, _ name: String, pages: Int = 10) {
        for i in 0..<pages {
            attachScreenshot(app, "gallery-\(name)-\(String(format: "%02d", i))")
            app.swipeUp(velocity: .slow)
        }
    }

    private func attachScreenshot(_ app: XCUIApplication, _ name: String) {
        let a = XCTAttachment(screenshot: app.screenshot())
        a.name = name
        a.lifetime = .keepAlways
        add(a)
    }
}
