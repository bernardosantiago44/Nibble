import AppKit
import SwiftUI

// SwiftUI's TextEditor does not expose macOS smart-quote substitution controls.
struct JSONInputEditor: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        guard let editor = scrollView.documentView as? NSTextView else { return scrollView }
        editor.delegate = context.coordinator
        editor.isRichText = false
        editor.allowsUndo = true
        editor.isAutomaticQuoteSubstitutionEnabled = false
        editor.isAutomaticDashSubstitutionEnabled = false
        editor.isAutomaticTextReplacementEnabled = false
        editor.isAutomaticSpellingCorrectionEnabled = false
        editor.isContinuousSpellCheckingEnabled = false
        editor.isAutomaticLinkDetectionEnabled = false
        editor.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        editor.textColor = .textColor
        editor.backgroundColor = .textBackgroundColor
        editor.textContainerInset = NSSize(width: 8, height: 8)
        editor.setAccessibilityLabel("JSON input")
        editor.setAccessibilityIdentifier("jsonInput")
        editor.string = text
        scrollView.verticalRulerView = JSONLineNumberRuler(scrollView: scrollView, editor: editor)
        scrollView.hasVerticalRuler = true
        scrollView.rulersVisible = true
        (scrollView.verticalRulerView as? JSONLineNumberRuler)?.refresh()
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        context.coordinator.text = $text
        guard let editor = scrollView.documentView as? NSTextView, editor.string != text else { return }
        editor.string = text
        (scrollView.verticalRulerView as? JSONLineNumberRuler)?.refresh()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let editor = notification.object as? NSTextView else { return }
            text.wrappedValue = editor.string
            (editor.enclosingScrollView?.verticalRulerView as? JSONLineNumberRuler)?.refresh()
        }
    }
}
