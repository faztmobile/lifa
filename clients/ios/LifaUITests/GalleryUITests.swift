import XCTest

/// XCUITest for the gallery (step 2): launches, renders in dark mode and at the largest accessibility text size,
/// passes Xcode's built-in accessibility audit, and toggles a switch.
final class GalleryUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    func testLaunchesAndPassesAccessibilityAudit() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Lifa design system"].waitForExistence(timeout: 10))
        try app.performAccessibilityAudit() // contrast, hit regions, Dynamic Type, labels (iOS 17+)
        attachScreenshot(app, "gallery-light")
    }

    func testDarkModeAndLargestText() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-LifaForceDark", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Lifa design system"].waitForExistence(timeout: 10))
        try app.performAccessibilityAudit(for: [.dynamicType, .textClipped, .contrast])
        attachScreenshot(app, "gallery-dark-axxxl")
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

    private func attachScreenshot(_ app: XCUIApplication, _ name: String) {
        let a = XCTAttachment(screenshot: app.screenshot())
        a.name = name
        a.lifetime = .keepAlways
        add(a)
    }
}
