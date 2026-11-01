import AppKit
import SwiftUI
import XCTest
@testable import Nibble

@MainActor
final class JSONSplitViewTests: XCTestCase {
    func testOrientationChangesPreserveEditingSession() throws {
        var text = (1...100).map { "line \($0)" }.joined(separator: "\n")
        let input = JSONInputEditor(text: Binding(get: { text }, set: { text = $0 }))
        let host = NSHostingView(rootView: JSONSplitView(isSideBySide: true, input: input, output: Text("Result")))
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
                              styleMask: [.titled, .resizable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = host
        window.makeKeyAndOrderFront(nil)
        defer { window.close() }
        host.layoutSubtreeIfNeeded()

        let editor = try XCTUnwrap(descendant(NSTextView.self, in: host))
        let split = try XCTUnwrap(descendant(NSSplitView.self, in: host))
        XCTAssertTrue(split.isVertical)
        window.makeFirstResponder(editor)
        editor.insertText("edited ", replacementRange: NSRange(location: 0, length: 0))
        editor.breakUndoCoalescing()
        editor.setSelectedRange(NSRange(location: 10, length: 4))
        editor.enclosingScrollView?.contentView.scroll(to: NSPoint(x: 0, y: 120))
        let undoManager = try XCTUnwrap(editor.undoManager)
        XCTAssertEqual(editor.enclosingScrollView?.contentView.bounds.origin.y ?? 0, 120, accuracy: 1)

        for sideBySide in [false, true, false] {
            host.rootView = JSONSplitView(isSideBySide: sideBySide, input: input, output: Text("Result"))
            host.layoutSubtreeIfNeeded()
            XCTAssertEqual(split.isVertical, sideBySide)
            XCTAssertTrue(descendant(NSTextView.self, in: host) === editor)
            XCTAssertEqual(editor.selectedRange(), NSRange(location: 10, length: 4))
            XCTAssertTrue(window.firstResponder === editor)
            XCTAssertTrue(editor.undoManager === undoManager)
            XCTAssertTrue(undoManager.canUndo)
            XCTAssertEqual(editor.enclosingScrollView?.contentView.bounds.origin.y ?? 0, 120, accuracy: 1)
            split.setPosition(sideBySide ? 400 : 260, ofDividerAt: 0)
            let firstPaneLength = sideBySide ? split.arrangedSubviews[0].frame.width : split.arrangedSubviews[0].frame.height
            XCTAssertEqual(firstPaneLength, sideBySide ? 400 : 260, accuracy: 1)
            XCTAssertGreaterThan(split.arrangedSubviews[0].frame.height, 0)
            XCTAssertGreaterThan(split.arrangedSubviews[1].frame.height, 0)
        }
        undoManager.undo()
        XCTAssertFalse(editor.string.hasPrefix("edited "))
    }

    private func descendant<T: NSView>(_ type: T.Type, in view: NSView) -> T? {
        if let match = view as? T { return match }
        return view.subviews.lazy.compactMap { self.descendant(type, in: $0) }.first
    }
}
