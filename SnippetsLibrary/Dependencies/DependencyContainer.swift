//
//  DependencyContainer.swift
//  SnippetsLibrary
//
//  Created by Krzysztof Łowiec on 12/09/2021.
//

import Foundation

let DIContainer = DependencyContainer.shared

final class DependencyContainer {
    
    // MARK: - Services
    
    lazy var snippetsParserService: SnippetsParserService = SnippetsParserServiceImpl()
    
    // MARK: - Shared
    
    static let shared = DependencyContainer()
    
}
