import SwiftUI
import XCTest
@testable import Nibble

@MainActor
final class JSONSyntaxHighlighterTests: XCTestCase {
    func testHighlightsTokenKindsWithoutChangingText() {
        let json = #"{"key": "text", "number": -12.5e+2, "bool": true, "empty": null}"#
        let highlighted = JSONSyntaxHighlighter.highlight(json)
        XCTAssertEqual(String(highlighted.characters), json)
        let runs = Array(highlighted.runs)
        for token in [#""key""#, #""text""#, "-12.5e+2", "true", "null"] {
            let run = runs.first { String(highlighted[$0.range].characters) == token }
            XCTAssertNotNil(run?.foregroundColor, "Missing highlighting for \(token)")
        }
        let colors = runs.compactMap(\.foregroundColor)
        XCTAssertEqual(Set(colors).count, 5)
    }

    func testEscapedQuotesUnicodeAndKeywordsInsideStringsStayStrings() {
        let json = #"{"🦊": "a \"quote\" true 42 null", "flag": false}"#
        let highlighted = JSONSyntaxHighlighter.highlight(json)
        XCTAssertEqual(String(highlighted.characters), json)
        let stringRuns = highlighted.runs.filter {
            String(highlighted[$0.range].characters) == #""a \"quote\" true 42 null""#
        }
        XCTAssertEqual(stringRuns.count, 1)
        XCTAssertNotNil(stringRuns.first?.foregroundColor)
    }
}
