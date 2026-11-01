import SwiftUI

struct ContentView: View {
    @State private var selectedTool: ToolDestination?

    var body: some View {
        Group {
            switch selectedTool {
            case .jsonFormatter:
                JSONFormatterView()
            case .uuidGenerator:
                UUIDGeneratorView()
            case nil:
                ToolGalleryView { selectedTool = $0 }
            }
        }
        .toolbar {
            if selectedTool != nil {
                ToolbarItem(placement: .navigation) {
                    Button("Developer", systemImage: "chevron.left") {
                        selectedTool = nil
                    }
                    .help("Return to the tool gallery")
                    .keyboardShortcut("[", modifiers: .command)
                }
            }
        }
        .frame(minWidth: 640, minHeight: 520)
    }
}

#Preview {
    ContentView()
}
