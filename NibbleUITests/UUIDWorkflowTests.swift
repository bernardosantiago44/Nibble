import XCTest

final class UUIDWorkflowTests: XCTestCase {
    @MainActor
    func testBatchOutputPersistsAcrossVersionsAndUpdatesCase() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.click()
        search.typeText("no-such-tool")
        XCTAssertTrue(app.staticTexts["No matching tools"].waitForExistence(timeout: 5))
        search.typeKey("a", modifierFlags: .command)
        search.typeText("time-ordered")
        let card = app.buttons["uuidGeneratorCard"]
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["jsonFormatterCard"].exists)
        card.click()
        app.radioButtons["v7 · Time ordered"].click()
        let count = app.textFields["uuidCount"]
        count.click()
        count.typeKey("a", modifierFlags: .command)
        count.typeText("3")
        app.buttons["generateUUIDs"].click()
        XCTAssertTrue(app.staticTexts["3 UUIDs"].waitForExistence(timeout: 5))
        let output = app.staticTexts["uuidOutput"]
        XCTAssertTrue(output.waitForExistence(timeout: 5))
        let original = output.value as? String ?? output.label
        XCTAssertEqual(original.split(separator: "\n").count, 3)
        XCTAssertEqual(original, original.lowercased())
        XCTAssertTrue(app.buttons["copyAllUUIDs"].isEnabled)

        app.radioButtons["v4 · Random"].click()
        XCTAssertEqual(output.value as? String ?? output.label, original)
        XCTAssertTrue(app.staticTexts["Generated v7"].exists)
        XCTAssertTrue(app.buttons["copyAllUUIDs"].isEnabled)
        app.checkBoxes["lowercaseUUIDs"].click()
        XCTAssertEqual(output.value as? String ?? output.label, original.uppercased())
        app.radioButtons["v7 · Time ordered"].click()
        XCTAssertEqual(output.value as? String ?? output.label, original.uppercased())
        app.checkBoxes["lowercaseUUIDs"].click()
        XCTAssertEqual(output.value as? String ?? output.label, original)
        app.radioButtons["v4 · Random"].click()
        app.buttons["generateUUIDs"].click()
        XCTAssertTrue(app.buttons["copyAllUUIDs"].isEnabled)
        XCTAssertTrue(app.staticTexts["Generated v4"].exists)
        let regenerated = output.value as? String ?? output.label
        XCTAssertTrue(regenerated.split(separator: "\n").allSatisfy { $0.count == 36 && $0.dropFirst(14).first == "4" })
        output.click()
        app.typeKey("a", modifierFlags: .command)
        app.typeKey("c", modifierFlags: .command)

        count.click()
        count.typeKey("a", modifierFlags: .command)
        count.typeText("0")
        app.buttons["generateUUIDs"].click()
        XCTAssertTrue(app.staticTexts["uuidError"].waitForExistence(timeout: 5))
        XCTAssertFalse(output.exists)
        XCTAssertFalse(app.buttons["copyAllUUIDs"].isEnabled)

        app.typeKey("[", modifierFlags: .command)
        app.buttons["jsonFormatterCard"].click()
        let jsonInput = app.textViews["jsonInput"]
        XCTAssertTrue(jsonInput.waitForExistence(timeout: 5))
        jsonInput.click()
        jsonInput.typeKey("v", modifierFlags: .command)
        XCTAssertEqual(jsonInput.value as? String, regenerated, "Select All copies UUID text without line numbers.")
    }
}
