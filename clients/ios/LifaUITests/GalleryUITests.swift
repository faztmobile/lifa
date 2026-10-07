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
        // The label includes the description ("Pause while I travel, Up to 180 days").
        let toggle = app.switches.matching(NSPredicate(format: "label BEGINSWITH %@", "Pause while I travel")).firstMatch
        for _ in 0..<20 where !(toggle.exists && toggle.isHittable) { app.swipeUp() }
        XCTAssertEqual(toggle.value as? String, "0")
        toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap() // the switch itself, at the trailing edge
        XCTAssertEqual(toggle.value as? String, "1")
    }

    /// Screenshots of the whole gallery, scrolling until the last disclosure is on screen.
    private func capturePages(_ app: XCUIApplication, _ name: String, maxPages: Int = 40) {
        let last = app.staticTexts["Education only. Lifa does not recommend financial products."]
        for i in 0..<maxPages {
            attachScreenshot(app, "gallery-\(name)-\(String(format: "%02d", i))")
            if last.exists && last.isHittable { break }
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
