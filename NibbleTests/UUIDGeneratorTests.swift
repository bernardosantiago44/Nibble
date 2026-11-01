import Foundation
import XCTest
@testable import Nibble

final class UUIDGeneratorTests: XCTestCase {
    func testDefaultsToOneV4() throws {
        let values = try UUIDGenerator.generate()
        XCTAssertEqual(values.count, 1)
        try assertLayout(values, version: 4)
    }

    func testGeneratesValidBatchesForBothVersions() throws {
        for version in UUIDVersion.allCases {
            for count in [3, 1000] {
                let values = try UUIDGenerator.generate(version: version, count: count)
                XCTAssertEqual(values.count, count)
                try assertLayout(values, version: version == .v4 ? 4 : 7)
            }
        }
    }

    func testRejectsInvalidCounts() {
        for version in UUIDVersion.allCases {
            for count in [-1, 0, 1001, Int.max] {
                XCTAssertThrowsError(try UUIDGenerator.generate(version: version, count: count))
            }
        }
    }

    func testV7TimestampAndBitLayout() throws {
        let value = try UUIDGenerator.version7(timestampMilliseconds: 0x0123456789AB,
                                               randomBytes: Array(repeating: 0xFF, count: 16))
        XCTAssertEqual(value.uuidString, "01234567-89AB-7FFF-BFFF-FFFFFFFFFFFF")
        let zero = try UUIDGenerator.version7(timestampMilliseconds: 0, randomBytes: Array(repeating: 0, count: 16))
        XCTAssertEqual(zero.uuidString, "00000000-0000-7000-8000-000000000000")
        XCTAssertThrowsError(try UUIDGenerator.version7(timestampMilliseconds: 1 << 48,
                                                       randomBytes: Array(repeating: 0, count: 16)))
        XCTAssertThrowsError(try UUIDGenerator.version7(timestampMilliseconds: 0, randomBytes: []))
    }

    func testCopyAllUsesOneCompleteUUIDPerLine() throws {
        let first = try XCTUnwrap(UUID(uuidString: "01234567-89AB-7FFF-BFFF-FFFFFFFFFFFF"))
        let second = try XCTUnwrap(UUID(uuidString: "00000000-0000-4000-8000-000000000000"))
        XCTAssertEqual(UUIDGenerator.outputText(for: [first, second]),
                       "01234567-89ab-7fff-bfff-ffffffffffff\n00000000-0000-4000-8000-000000000000")
        XCTAssertEqual(UUIDGenerator.outputText(for: []), "")
        let uppercase = UUIDGenerator.outputText(for: [first, second], lowercased: false)
        XCTAssertEqual(uppercase, "01234567-89AB-7FFF-BFFF-FFFFFFFFFFFF\n00000000-0000-4000-8000-000000000000")
        XCTAssertEqual(uppercase.split(separator: "\n").compactMap { UUID(uuidString: String($0)) }, [first, second])
        XCTAssertEqual(UUIDGenerator.outputText(for: [], lowercased: false), "")
    }

    private func assertLayout(_ values: [UUID], version: UInt8) throws {
        for value in values {
            XCTAssertEqual(UUID(uuidString: value.uuidString), value)
            XCTAssertEqual(value.uuidString.count, 36)
            let bytes = withUnsafeBytes(of: value.uuid) { Array($0) }
            XCTAssertEqual(bytes[6] >> 4, version)
            XCTAssertEqual(bytes[8] & 0xC0, 0x80)
        }
    }
}
