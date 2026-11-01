enum UUIDVersion: String, CaseIterable, Identifiable {
    case v4
    case v7

    var id: Self { self }

    var title: String {
        switch self {
        case .v4: "v4 · Random"
        case .v7: "v7 · Time ordered"
        }
    }
}
