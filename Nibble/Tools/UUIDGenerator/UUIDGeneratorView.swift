import SwiftUI

struct UUIDGeneratorView: View {
    @State private var version = UUIDVersion.v4
    @State private var count = "1"
    @State private var values: [UUID] = []
    @State private var errorMessage: String?
    @State private var copiedAll = false
    @State private var lowercased = true
    @State private var generatedVersion: UUIDVersion?

    private var outputText: String {
        UUIDGenerator.outputText(for: values, lowercased: lowercased)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("UUID Generator")
                .font(.title.bold())
                .accessibilityAddTraits(.isHeader)

            Picker("Version", selection: $version) {
                ForEach(UUIDVersion.allCases) { version in
                    Text(version.title).tag(version)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 360)
            .accessibilityIdentifier("uuidVersion")

            HStack(spacing: 12) {
                Text("Count")
                TextField("Count", text: $count)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 90)
                    .accessibilityLabel("UUID count")
                    .accessibilityIdentifier("uuidCount")
                    .onSubmit(generate)
                Text("1–1,000")
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Generate", action: generate)
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: .command)
                    .accessibilityIdentifier("generateUUIDs")
            }

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(errorMessage)
                    .accessibilityIdentifier("uuidError")
            }

            HStack {
                Text(values.count == 1 ? "1 UUID" : "\(values.count) UUIDs")
                    .font(.headline)
                if let generatedVersion {
                    Text("Generated \(generatedVersion.rawValue)")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Toggle("Lowercase", isOn: $lowercased)
                    .toggleStyle(.checkbox)
                    .accessibilityIdentifier("lowercaseUUIDs")
                Button(copiedAll ? "Copied" : "Copy All", systemImage: copiedAll ? "checkmark" : "doc.on.doc") {
                    copiedAll = Clipboard.copy(outputText)
                }
                .disabled(values.isEmpty)
                .keyboardShortcut("c", modifiers: [.command, .shift])
                .accessibilityIdentifier("copyAllUUIDs")
            }

            CodeOutputView(text: outputText, placeholder: "Generated UUIDs appear here.", outputIdentifier: "uuidOutput")
        }
        .padding(24)
        .navigationTitle("UUID Generator")
        .onChange(of: version) {
            errorMessage = nil
            copiedAll = false
        }
        .onChange(of: lowercased) { copiedAll = false }
        .onChange(of: count, clearResults)
        .task(id: copiedAll) {
            guard copiedAll else { return }
            do {
                try await Task.sleep(for: .seconds(2))
                copiedAll = false
            } catch {
                // A new selection or navigation cancels the brief confirmation.
            }
        }
    }

    private func clearResults() {
        values = []
        generatedVersion = nil
        errorMessage = nil
        copiedAll = false
    }

    private func generate() {
        clearResults()
        guard let count = Int(count.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            errorMessage = "Enter a whole number from 1 to 1,000."
            return
        }
        do {
            values = try UUIDGenerator.generate(version: version, count: count)
            generatedVersion = version
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
