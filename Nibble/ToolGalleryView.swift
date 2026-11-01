import SwiftUI

struct ToolGalleryView: View {
    let openJSONFormatter: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Developer")
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 240, maximum: 300))], alignment: .leading) {
                    Button(action: openJSONFormatter) {
                        VStack(alignment: .leading, spacing: 12) {
                            Image(systemName: "curlybraces")
                                .font(.largeTitle)
                                .foregroundStyle(.tint)
                                .frame(maxWidth: .infinity, minHeight: 100)
                                .background(.quaternary, in: .rect(cornerRadius: 10))
                                .accessibilityHidden(true)
                            Text("JSON Formatter")
                                .font(.headline)
                            Text("Format and validate JSON.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("JSON Formatter")
                    .accessibilityHint("Format and validate JSON.")
                    .accessibilityIdentifier("jsonFormatterCard")
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Nibble")
    }
}
