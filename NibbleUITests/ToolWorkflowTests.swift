import XCTest

final class ToolWorkflowTests: XCTestCase {
    @MainActor
    func testJSONFormattingAndErrorClearsOutput() {
        continueAfterFailure = false
        let app = XCUIApplication()
        // Add launch arguments to optimize UI tests and reduce priority inversions
        app.launchArguments += ["-UITests", "1", "-UIAnimationsDisabled", "YES"]
        // Optionally reduce logging noise during tests
        app.launchEnvironment["OS_ACTIVITY_MODE"] = "disable"
        app.launch()
        // Ensure the app is idle and the first UI control is present before interacting
        let formatterCard = app.buttons["jsonFormatterCard"]
        XCTAssertTrue(formatterCard.waitForExistence(timeout: 5))
        formatterCard.click()

        let input = app.textViews["jsonInput"]
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.click()
        input.typeText(#"{"name":"Nibble","values":[1,true]}"#)
        app.buttons["formatJSON"].click()

        let output = app.staticTexts["jsonOutput"]
        XCTAssertTrue(output.waitForExistence(timeout: 5))
        XCTAssertTrue((output.value as? String ?? output.label).contains("Nibble"))
        XCTAssertTrue(app.buttons["copyJSON"].isEnabled)
        XCTAssertTrue(app.staticTexts["Formatted JSON"].exists)
        XCTAssertTrue((output.value as? String ?? output.label).contains(#""name": "Nibble""#))

        input.click()
        input.typeKey("a", modifierFlags: .command)
        input.typeText(#"{"name":}"#)
        app.buttons["formatJSON"].click()

        XCTAssertTrue(app.staticTexts["jsonError"].waitForExistence(timeout: 5))
        XCTAssertFalse(output.exists)
        XCTAssertFalse(app.buttons["copyJSON"].isEnabled)

        app.buttons["clearJSON"].click()
        XCTAssertEqual(input.value as? String, "")
        XCTAssertFalse(app.staticTexts["jsonError"].exists)
    }
}
