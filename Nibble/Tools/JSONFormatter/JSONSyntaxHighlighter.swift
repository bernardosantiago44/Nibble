import SwiftUI

enum JSONSyntaxHighlighter {
    private static let tokens = try? NSRegularExpression(
        pattern: #"("(?:[^"\\]|\\.)*")(?=\s*:)|("(?:[^"\\]|\\.)*")|(-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)|\b(true|false)\b|\b(null)\b"#
    )

    static func highlight(_ json: String) -> AttributedString {
        var highlighted = AttributedString(json)
        guard let tokens else { return highlighted }
        let colors: [Color] = [.blue, .green, .orange, .purple, .secondary]
        for match in tokens.matches(in: json, range: NSRange(json.startIndex..., in: json)) {
            guard let stringRange = Range(match.range, in: json),
                  let range = Range(stringRange, in: highlighted) else { continue }
            for group in 1...5 where match.range(at: group).location != NSNotFound {
                highlighted[range].foregroundColor = colors[group - 1]
            }
        }
        return highlighted
    }
}
