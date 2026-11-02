enum JSONIndentation: String, CaseIterable, Identifiable, Sendable {
    case twoSpaces
    case fourSpaces
    case tabs

    var id: Self { self }

    var title: String {
        switch self {
        case .twoSpaces: "2 spaces"
        case .fourSpaces: "4 spaces"
        case .tabs: "Tabs"
        }
    }

    nonisolated var whitespace: String {
        switch self {
        case .twoSpaces: "  "
        case .fourSpaces: "    "
        case .tabs: "\t"
        }
    }
}
