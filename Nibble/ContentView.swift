//
//  ContentView.swift
//  Nibble
//
//  Created by Bernardo Santiago Marin on 31/10/26.
//

import SwiftUI

struct ContentView: View {
    @State private var showsJSONFormatter = false

    var body: some View {
        Group {
            if showsJSONFormatter {
                JSONFormatterView()
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            Button("Developer", systemImage: "chevron.left") {
                                showsJSONFormatter = false
                            }
                            .help("Return to the tool gallery")
                            .keyboardShortcut("[", modifiers: .command)
                        }
                    }
            } else {
                ToolGalleryView {
                    showsJSONFormatter = true
                }
            }
        }
        .frame(minWidth: 640, minHeight: 520)
    }
}

#Preview {
    ContentView()
}
