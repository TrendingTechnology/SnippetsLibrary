//
//  SnippetsLibraryViewModel.swift
//  SnippetsLibrary
//
//  Created by Krzysztof Łowiec on 08/09/2021.
//

import SwiftUI
import Combine

final class SnippetsLibraryViewModel: ObservableObject {
    
    // MARK: - Stored Properties

    @Published internal var snippets: [Snippet] = mockedSnippets
    @Published internal var selectedSnippetId: SnippetId?
    
    private let snippetsParserService: SnippetsParserService
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(snippetsParserService: SnippetsParserService = DIContainer.snippetsParserService) {
        self.snippetsParserService = snippetsParserService
        
        observeSnippets()
    }
    
    // MARK: Methods

    internal func onRemove(_ snippetId: SnippetId?) {
        guard
            let snippetId = snippetId,
            let snippet = snippets.first(where: { $0.id == snippetId })
        else { return }
        
        removeSnippet(snippet)
    }
    
    private func observeSnippets() {
        snippetsParserService.snippets
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: return
                case let .failure(error):
                    debugPrint("Error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] in
                self?.snippets = $0
            }
            .store(in: &cancellables)
    }
    
    private func removeSnippet(_ snippet: Snippet) {
        snippetsParserService.removeSnippet(snippet)
            .sink { completion in
                switch completion {
                case .finished: return
                case let .failure(error):
                    debugPrint("Error: \(error.localizedDescription)")
                }
            }
            .store(in: &cancellables)
    }

}
