//
//  SnippetsLibraryView.swift
//  SnippetsLibrary
//
//  Created by Krzysztof Łowiec on 08/09/2021.
//

import SwiftUI
import Combine

struct SnippetsLibraryView: View {
    
    // MARK: - Stored Properties
    
    @ObservedObject private(set) var viewModel: SnippetsLibraryViewModel
    
    @Binding internal var activeSheet: AppSheet?
    
    // MARK: - Views
    
    var body: some View {
        HSplitView {
            SnippetsLibraryListView(
                snippets: $viewModel.snippets,
                selectedSnippetId: $viewModel.selectedSnippetId
            ) {
                viewModel.onRemove($0)
            }
            
            SnippetsLibraryPreviewView(
                snippets: $viewModel.snippets,
                selectedSnippetId: $viewModel.selectedSnippetId,
                activeSheet: $activeSheet
            )
        }
        .frame(
            minWidth: Layout.defaultWindowSize.width,
            maxWidth: .infinity,
            minHeight: Layout.defaultWindowSize.height,
            maxHeight: .infinity
        )
        .sheet(item: $activeSheet) {
            switch $0 {
            case let .snippetDetails(snippet, type):
                SnippetDetailsView(
                    viewModel: SnippetDetailsViewModel(
                        snippet: snippet,
                        type: type,
                        activeAppView: .constant(nil)
                    )
                )
            }
        }
    }

}

struct SnippetsLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        SnippetsLibraryView(viewModel: SnippetsLibraryViewModel(), activeSheet: .constant(nil))
    }
}
