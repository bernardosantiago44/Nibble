import SwiftUI

struct JSONFormatterView: View {
    @State private var input = ""
    @State private var output = ""
    @State private var errorMessage: String?
    @State private var copied = false
    @FocusState private var inputIsFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("JSON Formatter")
                .font(.title.bold())
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: 8) {
                Text("Input").font(.headline)
                JSONInputEditor(text: $input)
                    .focused($inputIsFocused)
                    .accessibilityLabel("JSON input")
                    .accessibilityIdentifier("jsonInput")
                    .border(.separator)
                    .frame(minHeight: 140)
            }

            HStack(spacing: 12) {
                Button("Format", action: format)
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: .command)
                    .accessibilityIdentifier("formatJSON")
                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                        .textSelection(.enabled)
                        .accessibilityIdentifier("jsonError")
                }
            }

            HStack {
                Text("Result").font(.headline)
                Spacer()
                Button(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc") {
                    copied = JSONClipboard.copy(output)
                }
                .disabled(output.isEmpty)
                .accessibilityIdentifier("copyJSON")
            }

            ScrollView([.horizontal, .vertical]) {
                if output.isEmpty {
                    Text("Formatted JSON appears here.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                } else {
                    Text(output)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .accessibilityIdentifier("jsonOutput")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .frame(minHeight: 140)
            .background(.background)
            .border(.separator)
        }
        .padding(24)
        .navigationTitle("JSON Formatter")
        .defaultFocus($inputIsFocused, true)
        .onChange(of: input) {
            output = ""
            errorMessage = nil
            copied = false
        }
        .task(id: copied) {
            guard copied else { return }
            do {
                try await Task.sleep(for: .seconds(2))
                copied = false
            } catch {
                // A new input or navigation cancels the brief confirmation.
            }
        }
    }

    private func format() {
        copied = false
        switch JSONFormatter.format(input) {
        case .success(let formatted):
            output = formatted
            errorMessage = nil
        case .failure(let error):
            output = ""
            errorMessage = error.localizedDescription
        }
    }
}
