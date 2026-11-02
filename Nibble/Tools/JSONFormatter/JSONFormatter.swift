import Foundation

enum JSONFormatter {
    nonisolated static func format(_ input: String, indentation: JSONIndentation = .twoSpaces) -> Result<String, NSError> {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(NSError(
                domain: "JSONFormatter", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Enter JSON to format."]
            ))
        }

        do {
            // Strings are matched first so their digits, escapes, and punctuation stay untouched.
            let expression = try NSRegularExpression(
                pattern: #""(?:[^"\\]|\\.)*"|(?<number>-?(?:0|[1-9][0-9]*)(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?)|(?<whitespace>[ \t\r\n\uFEFF]+)|."#,
                options: .dotMatchesLineSeparators
            )
            let source = input as NSString
            let tokens = expression.matches(in: input, range: NSRange(location: 0, length: source.length)).map {
                (text: source.substring(with: $0.range),
                 isNumber: $0.range(withName: "number").location != NSNotFound,
                 isWhitespace: $0.range(withName: "whitespace").location != NSNotFound)
            }

            // Validate structure with Foundation without restricting numbers to its numeric
            // range. Boolean placeholders cannot turn malformed numbers or numeric keys valid.
            let validationInput = tokens.map { $0.isNumber ? "true" : $0.text }.joined()
            do {
                _ = try JSONSerialization.jsonObject(with: Data(validationInput.utf8), options: .fragmentsAllowed)
            } catch {
                // Prefer the original parser error so any line/column refers to the input,
                // not to the differently sized number placeholders used for validation.
                do {
                    _ = try JSONSerialization.jsonObject(with: Data(input.utf8), options: .fragmentsAllowed)
                } catch {
                    throw error
                }
                throw error
            }
            let content = tokens.filter { !$0.isWhitespace }.map(\.text)
            return .success(prettyPrinted(content, indentation: indentation.whitespace))
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

    nonisolated private static func prettyPrinted(_ tokens: [String], indentation: String) -> String {
        var output = ""
        var depth = 0
        var previous: String?
        for (index, token) in tokens.enumerated() {
            let next = index + 1 < tokens.count ? tokens[index + 1] : nil
            switch token {
            case "{", "[":
                output += token
                let closing = token == "{" ? "}" : "]"
                if next != closing {
                    depth += 1
                    output += "\n" + String(repeating: indentation, count: depth)
                }
            case "}", "]":
                let opening = token == "}" ? "{" : "["
                if previous != opening {
                    depth -= 1
                    output += "\n" + String(repeating: indentation, count: depth)
                }
                output += token
            case ",":
                // Foundation accepts trailing commas; retain its existing normalization.
                if next == "}" || next == "]" { continue }
                output += ",\n" + String(repeating: indentation, count: depth)
            case ":":
                output += ": "
            default:
                output += token
            }
            previous = token
        }
        return output
    }
}
