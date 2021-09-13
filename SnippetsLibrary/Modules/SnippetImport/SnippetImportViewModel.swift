//
//  SnippetImportViewModel.swift
//  SnippetsLibrary
//
//  Created by Krzysztof Łowiec on 12/09/2021.
//

import SwiftUI
import Combine

final class SnippetImportViewModel: ObservableObject {
    
    // MARK: - Stored Properties
    
    @Published internal var snippet: Snippet?
    @Binding internal var activeAppView: ActiveAppView?
    
    private let snippetsParserService: SnippetsParserService
    
    internal var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        snippetsParserService: SnippetsParserService = DIContainer.snippetsParserService,
        activeAppView: Binding<ActiveAppView?>
    ) {
        self.snippetsParserService = snippetsParserService
        self._activeAppView = activeAppView
    }
    
    // MARK: - Methods
    
    internal func createSnippet(_ snippet: Snippet) {
        snippetsParserService.createSnippet(snippet)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.activeAppView = .snippetsLibrary(snippet)
                case let .failure(error):
                    // Unable to load
                    debugPrint(error.localizedDescription)
                }
            }
            .store(in: &self.cancellables)
    }
    
}
