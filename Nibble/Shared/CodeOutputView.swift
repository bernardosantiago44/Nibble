import SwiftUI

struct CodeOutputView: View {
    let text: String
    let highlightedText: AttributedString?
    let placeholder: String
    let outputIdentifier: String
    @State private var scrollOffset: CGFloat = 0

    init(text: String, highlightedText: AttributedString? = nil, placeholder: String, outputIdentifier: String) {
        self.text = text
        self.highlightedText = highlightedText
        self.placeholder = placeholder
        self.outputIdentifier = outputIdentifier
    }

    private var lineCount: Int {
        text.isEmpty ? 1 : text.reduce(1) { $1 == "\n" ? $0 + 1 : $0 }
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(String(lineCount))
                .hidden()
                .overlay(alignment: .topTrailing) {
                    Text((1...lineCount).map(String.init).joined(separator: "\n"))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                        .fixedSize()
                        .offset(y: -scrollOffset)
                }
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.top, 8)
                .frame(minWidth: 36, maxHeight: .infinity, alignment: .topTrailing)
                .clipped()
                .background(.quaternary.opacity(0.3))
                .accessibilityHidden(true)

            GeometryReader { geometry in
                ScrollView([.horizontal, .vertical]) {
                    Group {
                        if text.isEmpty {
                            Text(placeholder)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(highlightedText ?? AttributedString(text))
                                .font(.system(.body, design: .monospaced))
                                .textSelection(.enabled)
                                .accessibilityIdentifier(outputIdentifier)
                        }
                    }
                    .padding(8)
                    .frame(minWidth: geometry.size.width, minHeight: geometry.size.height, alignment: .topLeading)
                }
                .onScrollGeometryChange(for: CGFloat.self) { $0.contentOffset.y } action: { _, offset in
                    scrollOffset = offset
                }
            }
        }
        .frame(minHeight: 100)
        .background(.background)
        .border(.separator)
    }
}
