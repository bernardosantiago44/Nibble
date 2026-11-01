enum ToolDestination: String, CaseIterable, Identifiable {
    case jsonFormatter
    case uuidGenerator

    var id: Self { self }

    var title: String {
        switch self {
        case .jsonFormatter: "JSON Formatter"
        case .uuidGenerator: "UUID Generator"
        }
    }

    var description: String {
        switch self {
        case .jsonFormatter: "Format and validate JSON."
        case .uuidGenerator: "Generate random or time-ordered UUIDs, one or in a batch."
        }
    }

    var symbol: String {
        switch self {
        case .jsonFormatter: "curlybraces"
        case .uuidGenerator: "number"
        }
    }
}
