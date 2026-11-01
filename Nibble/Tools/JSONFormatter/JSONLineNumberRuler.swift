import AppKit

final class JSONLineNumberRuler: NSRulerView {
    private var lineStarts = [0]
    private let numberFont = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)

    override var isFlipped: Bool { true }

    init(scrollView: NSScrollView, editor: NSTextView) {
        super.init(scrollView: scrollView, orientation: .verticalRuler)
        clientView = editor
        ruleThickness = 36
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    func refresh() {
        guard let editor = clientView as? NSTextView else { return }
        let text = editor.string as NSString
        lineStarts = [0]
        var position = 0
        while position < text.length {
            let end = NSMaxRange(text.lineRange(for: NSRange(location: position, length: 0)))
            guard end > position else { break }
            if end < text.length || text.character(at: end - 1) == 10 || text.character(at: end - 1) == 13 {
                lineStarts.append(end)
            }
            position = end
        }
        let width = (String(lineStarts.count) as NSString).size(withAttributes: [.font: numberFont]).width
        ruleThickness = max(36, width + 16)
        needsDisplay = true
    }

    override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let editor = clientView as? NSTextView,
              let scrollView,
              let layout = editor.layoutManager,
              let container = editor.textContainer else { return }
        NSGraphicsContext.saveGraphicsState()
        defer { NSGraphicsContext.restoreGraphicsState() }
        // AppKit rulers can extend beyond the editor's scrolling viewport.
        let visibleRect = convert(scrollView.contentView.bounds, from: scrollView.contentView)
        NSBezierPath(rect: NSRect(x: bounds.minX, y: visibleRect.minY,
                                 width: bounds.width, height: visibleRect.height)).addClip()
        NSColor.windowBackgroundColor.setFill()
        bounds.fill()
        layout.ensureLayout(for: container)
        let origin = convert(editor.textContainerOrigin, from: editor)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: numberFont, .foregroundColor: NSColor.secondaryLabelColor
        ]
        for (index, location) in lineStarts.enumerated() {
            let lineRect: NSRect
            if location < (editor.textStorage?.length ?? 0) {
                let glyph = layout.glyphIndexForCharacter(at: location)
                lineRect = layout.lineFragmentRect(forGlyphAt: glyph, effectiveRange: nil)
            } else {
                lineRect = layout.extraLineFragmentRect
            }
            let y = origin.y + lineRect.minY
            guard y + lineRect.height >= rect.minY, y <= rect.maxY else { continue }
            let number = String(index + 1) as NSString
            let size = number.size(withAttributes: attributes)
            number.draw(at: NSPoint(x: ruleThickness - size.width - 8, y: y), withAttributes: attributes)
        }
    }
}
