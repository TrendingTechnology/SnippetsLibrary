//
//  StartViewModel.swift
//  SnippetsLibrary
//
//  Created by Krzysztof Łowiec on 07/09/2021.
//

import SwiftUI

final class StartViewModel: ObservableObject {
    
    // MARK: - Stored Properties
    
    @Published private(set) var recentSnippets: [Snippet] = mockedSnippets
    @Published private(set) var hasSnippets = false
    
    @Binding internal var activeAppView: ActiveAppView?
    @Binding internal var activeAppSheet: AppSheet?
    
    // MARK: - Initialization
    
    init(
        activeAppView: Binding<ActiveAppView?>,
        activeAppSheet: Binding<AppSheet?>
    ) {
        self._activeAppView = activeAppView
        self._activeAppSheet = activeAppSheet
        
        checkForSnippets()
    }
    
    // MARK: - Methods
    
    internal func closeView() {
        NSApplication.shared.keyWindow?.close()
    }
    
    private func checkForSnippets() {
        // TO-DO: Check for available snippets
        // Below flag only for testing purpose
        hasSnippets = true
    }
    
}
