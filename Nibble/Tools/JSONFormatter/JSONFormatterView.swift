import SwiftUI

struct JSONFormatterView: View {
    @State private var input = ""
    @State private var output = ""
    @State private var highlightedOutput = AttributedString()
    @State private var errorMessage: String?
    @State private var copied = false
    @State private var indentation = JSONIndentation.twoSpaces

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("JSON Formatter")
                    .font(.title.bold())
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Picker("Indentation", selection: $indentation) {
                    ForEach(JSONIndentation.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .controlSize(.small)
                .fixedSize()
                .help("Used the next time you format JSON.")
            }

            GeometryReader { geometry in
                let sideBySide = geometry.size.width >= 820
                JSONSplitView(
                    isSideBySide: sideBySide,
                    input: inputPane
                        .padding(.trailing, sideBySide ? 12 : 0)
                        .padding(.bottom, sideBySide ? 0 : 12),
                    output: outputPane
                        .padding(.leading, sideBySide ? 12 : 0)
                        .padding(.top, sideBySide ? 0 : 12)
                )
            }
        }
        .padding(24)
        .navigationTitle("JSON Formatter")
        .onChange(of: input) {
            output = ""
            highlightedOutput = AttributedString()
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

    private var inputPane: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Input").font(.headline)
                Spacer()
                Button("Clear") { input = "" }
                    .disabled(input.isEmpty)
                    .keyboardShortcut(.delete, modifiers: [.command, .shift])
                    .help("Clear input (Shift-Command-Delete)")
                    .accessibilityIdentifier("clearJSON")
                Button("Format", action: format)
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .keyboardShortcut(.return, modifiers: .command)
                    .help("Format JSON (Command-Return)")
                    .accessibilityIdentifier("formatJSON")
            }
            .frame(minHeight: 28)

            JSONInputEditor(text: $input)
                .border(.separator)
                .frame(minHeight: 100)

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
                    .accessibilityIdentifier("jsonError")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var outputPane: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Formatted JSON").font(.headline)
                Spacer()
                Button(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc") {
                    copied = Clipboard.copy(output)
                }
                .disabled(output.isEmpty)
                .keyboardShortcut("c", modifiers: [.command, .shift])
                .help("Copy formatted JSON (Shift-Command-C)")
                .accessibilityIdentifier("copyJSON")
            }
            .frame(minHeight: 28)

            CodeOutputView(text: output, highlightedText: highlightedOutput,
                           placeholder: "Formatted JSON appears here.", outputIdentifier: "jsonOutput")

            if !output.isEmpty {
                Label("Valid JSON", systemImage: "checkmark.circle")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func format() {
        copied = false
        switch JSONFormatter.format(input, indentation: indentation) {
        case .success(let formatted):
            output = formatted
            highlightedOutput = JSONSyntaxHighlighter.highlight(formatted)
            errorMessage = nil
        case .failure(let error):
            output = ""
            highlightedOutput = AttributedString()
            errorMessage = error.localizedDescription
        }
    }
}
