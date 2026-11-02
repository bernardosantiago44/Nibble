import Foundation
import XCTest
@testable import Nibble

final class JSONFormatterTests: XCTestCase {
    func testPreservesExactNumericLiteralsAcrossIndentationChoices() throws {
        let input = "[8.95,22.99,19.95,0.123456789012345678901234567890123456789,9007199254740993,12345678901234567890123456789012345678901234567890,-0,-0.0000,1.2300,1.2300E+04,1e400,1e-400]"
        for indentation in JSONIndentation.allCases {
            let output = try JSONFormatter.format(input, indentation: indentation).get()
            XCTAssertEqual(output.filter { !$0.isWhitespace }, input)
        }
        for number in ["8.95", "22.99", "19.95", "-0.00", "1.2300E+04", "1e400", "1e-400"] {
            XCTAssertEqual(try JSONFormatter.format(number).get(), number)
        }
    }

    func testPreservesNumbersBesideEscapedStringsAndEmptyContainers() throws {
        let input = #"{"price":8.95,"description":"8.95, \"price\": 22.99, [ ] { } \\ \n \t","items":[{},[],{"price":19.95}]}"#
        let output = try JSONFormatter.format(input).get()
        XCTAssertTrue(output.contains(#""price": 8.95"#))
        XCTAssertTrue(output.contains(#""price": 19.95"#))
        XCTAssertTrue(output.contains(#""description": "8.95, \"price\": 22.99, [ ] { } \\ \n \t""#))
        XCTAssertTrue(output.contains("{}"))
        XCTAssertTrue(output.contains("[]"))
        try assertEquivalent(input, output)
    }

    func testRejectsMalformedNumberSyntax() {
        for input in ["01", "-01", ".5", "1.", "1.2.3", "1e+", "--1", "-", "١", "NaN", "Infinity", "{1:2}", "[1 2]"] {
            guard case .failure = JSONFormatter.format(input) else {
                return XCTFail("Malformed numeric syntax must be rejected: \(input)")
            }
        }
    }

    func testNormalizesAcceptedTrailingCommasWithoutRoundingNumbers() throws {
        let output = try JSONFormatter.format(#"{"prices":[8.95,22.99,],}"#).get()
        XCTAssertEqual(output.filter { !$0.isWhitespace }, #"{"prices":[8.95,22.99]}"#)
    }

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

    func testIndentationChoicesApplyAtEveryNestingLevel() throws {
        let input = #"{"items":[{"enabled":true,"value":null}]}"#
        for (indentation, unit) in [(JSONIndentation.twoSpaces, "  "), (.fourSpaces, "    "), (.tabs, "\t")] {
            let output = try JSONFormatter.format(input, indentation: indentation).get()
            try assertEquivalent(input, output)
            let lines = output.components(separatedBy: "\n")
            XCTAssertTrue(lines.contains(unit + #""items": ["#))
            XCTAssertTrue(lines.contains(String(repeating: unit, count: 2) + "{"))
            XCTAssertTrue(lines.contains { $0.hasPrefix(String(repeating: unit, count: 3) + #""enabled": true"#) })
            XCTAssertTrue(lines.contains(String(repeating: unit, count: 2) + "}"))
            XCTAssertTrue(lines.contains(unit + "]"))
            XCTAssertEqual(lines.first, "{")
            XCTAssertEqual(lines.last, "}")
        }
    }

    func testIndentationPreservesStringWhitespaceEscapesAndScalars() throws {
        let input = #"["  leading spaces", "line\n  next", "\tindent", {"  key": "quote\" : value"}]"#
        for indentation in JSONIndentation.allCases {
            try assertEquivalent(input, JSONFormatter.format(input, indentation: indentation).get())
            for scalar in [#""  text\n\t""#, "42", "false", "null"] {
                try assertEquivalent(scalar, JSONFormatter.format(scalar, indentation: indentation).get())
            }
        }
    }

    func testDefaultIndentationRemainsTwoSpaces() throws {
        let input = #"{"nested":{"value":1}}"#
        XCTAssertEqual(try JSONFormatter.format(input).get(),
                       try JSONFormatter.format(input, indentation: .twoSpaces).get())
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

    func testSortsNestedKeysWhilePreservingArraysAndLiteralValues() throws {
        let input = #"{"z":[{"z":1.2300E+04,"a":"keep \"z\": [2,1]"},3,2,1],"a":{"z":null,"a":false},"n":-0.0000}"#
        let expected = #"{"a":{"a":false,"z":null},"n":-0.0000,"z":[{"a":"keep \"z\": [2,1]","z":1.2300E+04},3,2,1]}"#
        for indentation in JSONIndentation.allCases {
            XCTAssertEqual(try JSONFormatter.format(input, indentation: indentation, sortKeys: true).get(),
                           try JSONFormatter.format(expected, indentation: indentation).get())
        }
    }

    func testSortingIsOptIn() throws {
        let input = #"{"z":1,"a":{"z":2,"a":3}}"#
        XCTAssertEqual(try JSONFormatter.format(input).get(),
                       try JSONFormatter.format(input, sortKeys: false).get())
        XCTAssertEqual(try JSONFormatter.format(input).get().filter { !$0.isWhitespace }, input)
    }

    func testSortUsesDecodedKeysAndPreservesDuplicateKeys() throws {
        let input = #"{"z":[],"\u0061":1,"a":2,"b":{}}"#
        let expected = #"{"\u0061":1,"a":2,"b":{},"z":[]}"#
        XCTAssertEqual(try JSONFormatter.format(input, sortKeys: true).get(),
                       try JSONFormatter.format(expected).get())
    }

    func testSortingHandlesScalarsEmptyContainersAndTrailingCommas() throws {
        for input in ["null", "true", "1e400", #""text""#, "{}", "[]", #"[{"z":1,"a":2,},]"#] {
            let output = try JSONFormatter.format(input, sortKeys: true).get()
            XCTAssertEqual(try JSONFormatter.format(output, sortKeys: true).get(), output)
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
