import Foundation

enum JSONFormatter {
    nonisolated static func format(_ input: String) -> Result<String, NSError> {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(NSError(
                domain: "JSONFormatter", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Enter JSON to format."]
            ))
        }

        do {
            let value = try JSONSerialization.jsonObject(with: Data(input.utf8), options: .fragmentsAllowed)
            let data = try JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted, .fragmentsAllowed])
            return .success(String(decoding: data, as: UTF8.self))
        } catch {
            let parserError = error as NSError
            let details = parserError.userInfo[NSDebugDescriptionErrorKey] as? String
                ?? parserError.localizedDescription
            return .failure(NSError(
                domain: "JSONFormatter", code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid JSON. \(details)"]
            ))
        }
    }
}
