//
//  SnippetsLibraryListView.swift
//  SnippetsLibrary
//
//  Created by Krzysztof Łowiec on 08/09/2021.
//

import SwiftUI

struct SnippetsLibraryListView: View {
    
    // MARK: - Stored Properties
    
    @Binding internal var snippets: [Snippet]
    @Binding internal var selectedSnippetId: SnippetId?
    
    @State private var searchedText = ""
    @State var shouldShowRemoveAlert = false
    
    private(set) var onRemove: (_ snippetId: SnippetId?) -> Void
    
    // MARK: - Views
    
    var body: some View {
        VStack {
            SearchBar {
                searchedText = $0
            }
            .padding(.top, Layout.largePadding)
            .padding(.horizontal)
            
            List(
                snippets.filter { matchingSnippet($0) },
                selection: $selectedSnippetId
            ) {
                SnippetListItemView(snippet: $0)
                    .contextMenu {
                        Button("Delete") {
                            shouldShowRemoveAlert.toggle()
                        }
                    }
            }
        }
        .frame(minWidth: Layout.defaultWindowSize.width * 0.35)
        .background(
            VisualEffectView(
                material: .menu,
                blendingMode: .behindWindow
            )
        )
        .edgesIgnoringSafeArea(.top)
        .alert(isPresented: $shouldShowRemoveAlert) {
            Alert(
                title: Text("Confirm removing"),
                message: Text("You sure want to remove this snippet?"),
                primaryButton:
                    .destructive(
                        Text("Yes, remove"),
                        action: { onRemove(selectedSnippetId) }
                    ),
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - Methods
    
    private func matchingSnippet(_ snippet: Snippet) -> Bool {
        snippet.title.lowercased().contains(searchedText.lowercased()) ||
            snippet.summary.lowercased().contains(searchedText.lowercased()) ||
            searchedText.isEmpty
    }
    
}

struct SnippetsLibraryListView_Previews: PreviewProvider {
    static var previews: some View {
        SnippetsLibraryListView(snippets: .constant([mockedSnippets.first!]), selectedSnippetId: .constant(nil)) { _ in }
    }
}
