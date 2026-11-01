import AppKit
import SwiftUI

// Keep the hosting views in place when the split changes orientation so the
// native editor retains its selection, scrolling, first responder, and undo stack.
struct JSONSplitView<Input: View, Output: View>: NSViewRepresentable {
    let isSideBySide: Bool
    let input: Input
    let output: Output

    func makeCoordinator() -> Coordinator {
        Coordinator(input: input, output: output)
    }

    func makeNSView(context: Context) -> NSSplitView {
        let split = NSSplitView()
        split.isVertical = isSideBySide
        split.dividerStyle = .thin
        split.delegate = context.coordinator
        split.addArrangedSubview(context.coordinator.inputHost)
        split.addArrangedSubview(context.coordinator.outputHost)
        return split
    }

    func updateNSView(_ split: NSSplitView, context: Context) {
        let changesOrientation = split.isVertical != isSideBySide
        let scrollPositions = changesOrientation ? context.coordinator.scrollPositions(in: split) : []
        context.coordinator.inputHost.rootView = input
        context.coordinator.outputHost.rootView = output
        guard changesOrientation else { return }
        split.isVertical = isSideBySide
        split.adjustSubviews()
        let length = isSideBySide ? split.bounds.width : split.bounds.height
        split.setPosition((length - split.dividerThickness) / 2, ofDividerAt: 0)
        split.layoutSubtreeIfNeeded()
        for (scrollView, origin) in scrollPositions {
            scrollView.contentView.scroll(to: origin)
            scrollView.reflectScrolledClipView(scrollView.contentView)
        }
    }

    final class Coordinator: NSObject, NSSplitViewDelegate {
        let inputHost: NSHostingView<Input>
        let outputHost: NSHostingView<Output>

        init(input: Input, output: Output) {
            inputHost = NSHostingView(rootView: input)
            outputHost = NSHostingView(rootView: output)
            super.init()
            // The split owns pane sizing; changing error text must not impose
            // a new intrinsic height and push the other pane out of the window.
            inputHost.sizingOptions = []
            outputHost.sizingOptions = []
        }

        func splitView(_ splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat,
                       ofSubviewAt dividerIndex: Int) -> CGFloat {
            proposedMinimumPosition + minimumPaneSize(in: splitView)
        }

        func splitView(_ splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat,
                       ofSubviewAt dividerIndex: Int) -> CGFloat {
            proposedMaximumPosition - minimumPaneSize(in: splitView)
        }

        private func minimumPaneSize(in split: NSSplitView) -> CGFloat {
            let length = split.isVertical ? split.bounds.width : split.bounds.height
            return min(split.isVertical ? 340 : 180, max(0, (length - split.dividerThickness) / 2))
        }

        func scrollPositions(in view: NSView) -> [(NSScrollView, NSPoint)] {
            if let scrollView = view as? NSScrollView {
                return [(scrollView, scrollView.contentView.bounds.origin)]
            }
            return view.subviews.flatMap { scrollPositions(in: $0) }
        }
    }
}
