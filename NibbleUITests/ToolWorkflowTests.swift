import XCTest

final class ToolWorkflowTests: XCTestCase {
    @MainActor
    func testJSONFormattingAndErrorClearsOutput() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        app.buttons["jsonFormatterCard"].click()

        let input = app.textViews["jsonInput"]
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.click()
        input.typeText(#"{"name":"Nibble","values":[1,true]}"#)
        app.buttons["formatJSON"].click()

        let output = app.staticTexts["jsonOutput"]
        XCTAssertTrue(output.waitForExistence(timeout: 5))
        XCTAssertTrue((output.value as? String ?? output.label).contains("Nibble"))
        XCTAssertTrue(app.buttons["copyJSON"].isEnabled)

        input.click()
        input.typeKey("a", modifierFlags: .command)
        input.typeText(#"{"name":}"#)
        app.buttons["formatJSON"].click()

        XCTAssertTrue(app.staticTexts["jsonError"].waitForExistence(timeout: 5))
        XCTAssertFalse(output.exists)
        XCTAssertFalse(app.buttons["copyJSON"].isEnabled)
    }
}
