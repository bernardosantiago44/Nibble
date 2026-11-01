import Foundation
import XCTest
@testable import Nibble

final class JSONFormatterTests: XCTestCase {
    func testFormatsNestedObjectWithoutChangingValues() throws {
        let input = #"{"name":"Nibble","nested":{"enabled":true,"values":[1,null,"text"]}}"#
        let output = try JSONFormatter.format(input).get()
        try assertEquivalent(input, output)
        XCTAssertTrue(output.contains("\n  \""), "Objects use two-space indentation.")
    }

    func testFormatsArrayWithoutChangingValues() throws {
        let input = #"[1,{"name":"Nibble"},false,null]"#
        let output = try JSONFormatter.format(input).get()
        try assertEquivalent(input, output)
        XCTAssertTrue(output.contains("\n"))
    }

    func testUsesConventionalColonSpacingWithoutChangingStrings() throws {
        let input = #"{"hello":"world","text":"keep \"quoted\" : text","nested":{"x":1}}"#
        let output = try JSONFormatter.format(input).get()
        XCTAssertTrue(output.contains(#""hello": "world""#))
        XCTAssertTrue(output.contains(#""x": 1"#))
        try assertEquivalent(input, output)
    }

    func testAcceptsTopLevelScalars() throws {
        for input in [#""hello""#, "42", "true", "null"] {
            try assertEquivalent(input, JSONFormatter.format(input).get())
        }
    }

    func testRejectsEmptyInputWithUsefulError() {
        for input in ["", " \n\t"] {
            guard case .failure(let error) = JSONFormatter.format(input) else {
                return XCTFail("Empty input must not produce output.")
            }
            XCTAssertTrue(error.localizedDescription.contains("Enter JSON"))
        }
    }

    func testRejectsMalformedJSONWithUsefulError() {
        for input in [#"{"name":}"#, "[1,", "true false"] {
            guard case .failure(let error) = JSONFormatter.format(input) else {
                return XCTFail("Malformed JSON must not produce output.")
            }
            XCTAssertFalse(error.localizedDescription.isEmpty)
        }
    }

    private func assertEquivalent(_ input: String, _ output: String) throws {
        let original = try JSONSerialization.jsonObject(with: Data(input.utf8), options: .fragmentsAllowed)
        let formatted = try JSONSerialization.jsonObject(with: Data(output.utf8), options: .fragmentsAllowed)
        XCTAssertEqual(
            try JSONSerialization.data(withJSONObject: original, options: [.fragmentsAllowed, .sortedKeys]),
            try JSONSerialization.data(withJSONObject: formatted, options: [.fragmentsAllowed, .sortedKeys])
        )
    }
}
