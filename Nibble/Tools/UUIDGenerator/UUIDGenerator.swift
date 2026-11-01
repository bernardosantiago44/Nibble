import Foundation
import Security

enum UUIDGenerator {
    nonisolated static func generate(version: UUIDVersion = .v4, count: Int = 1) throws -> [UUID] {
        guard (1...1000).contains(count) else {
            throw error("Enter a count from 1 to 1,000.")
        }
        return try (0..<count).map { _ in
            switch version {
            case .v4:
                return UUID()
            case .v7:
                let milliseconds = Date().timeIntervalSince1970 * 1000
                guard milliseconds >= 0, milliseconds < Double(1 << 48) else {
                    throw error("The current date is outside the supported UUID v7 range.")
                }
                var bytes = [UInt8](repeating: 0, count: 16)
                let status = bytes.withUnsafeMutableBytes { buffer in
                    guard let address = buffer.baseAddress else { return errSecParam }
                    return SecRandomCopyBytes(kSecRandomDefault, buffer.count, address)
                }
                guard status == errSecSuccess else {
                    throw error("Secure random generation failed. Try again.")
                }
                return try version7(timestampMilliseconds: UInt64(milliseconds), randomBytes: bytes)
            }
        }
    }

    nonisolated static func version7(timestampMilliseconds: UInt64, randomBytes: [UInt8]) throws -> UUID {
        guard timestampMilliseconds < 1 << 48, randomBytes.count == 16 else {
            throw error("UUID v7 requires a 48-bit timestamp and 16 random bytes.")
        }
        var bytes = randomBytes
        // RFC 9562 §5.7: big-endian Unix milliseconds, version 7, and RFC variant 10.
        for index in 0..<6 {
            bytes[index] = UInt8(truncatingIfNeeded: timestampMilliseconds >> ((5 - index) * 8))
        }
        bytes[6] = (bytes[6] & 0x0F) | 0x70
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return UUID(uuid: (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
                           bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]))
    }

    nonisolated static func outputText(for values: [UUID], lowercased: Bool = true) -> String {
        values.map { lowercased ? $0.uuidString.lowercased() : $0.uuidString }.joined(separator: "\n")
    }

    nonisolated private static func error(_ message: String) -> NSError {
        NSError(domain: "UUIDGenerator", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
