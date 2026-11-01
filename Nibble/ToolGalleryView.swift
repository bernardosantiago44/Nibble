import SwiftUI

struct ToolGalleryView: View {
    let openTool: (ToolDestination) -> Void
    @State private var search = ""

    private var matchingTools: [ToolDestination] {
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
        return ToolDestination.allCases.filter {
            query.isEmpty || $0.title.localizedCaseInsensitiveContains(query)
                || $0.description.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Developer")
                        .font(.largeTitle.bold())
                        .accessibilityAddTraits(.isHeader)

                    if matchingTools.isEmpty {
                        ContentUnavailableView("No matching tools", systemImage: "magnifyingglass",
                                               description: Text("Try a different name or description."))
                            .frame(maxWidth: .infinity, minHeight: 180)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 240, maximum: 300))], alignment: .leading) {
                            ForEach(matchingTools) { tool in
                                Button { openTool(tool) } label: {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Image(systemName: tool.symbol)
                                            .font(.largeTitle)
                                            .foregroundStyle(.tint)
                                            .frame(maxWidth: .infinity, minHeight: 100)
                                            .background(.quaternary, in: .rect(cornerRadius: 10))
                                            .accessibilityHidden(true)
                                        Text(tool.title)
                                            .font(.headline)
                                        Text(tool.description)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .frame(minHeight: 34, alignment: .topLeading)
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.bordered)
                                .accessibilityLabel(tool.title)
                                .accessibilityHint(tool.description)
                                .accessibilityIdentifier(tool.rawValue + "Card")
                            }
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Nibble")
            .searchable(text: $search, prompt: "Search tools")
        }
    }
}
