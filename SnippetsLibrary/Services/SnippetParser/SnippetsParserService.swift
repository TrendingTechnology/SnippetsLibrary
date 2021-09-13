//
//  SnippetsParserService.swift
//  SnippetsLibrary
//
//  Created by Krzysztof Łowiec on 12/09/2021.
//

import Foundation
import Combine

protocol SnippetsParserService {
    func createSnippet(_ snippet: Snippet) -> AnyPublisher<Void, SnippetsParserServiceError>
    func removeSnippet(_ snippet: Snippet) -> AnyPublisher<Void, SnippetsParserServiceError>
    
    var snippets: Published<[Snippet]>.Publisher { get }
}

final class SnippetsParserServiceImpl: SnippetsParserService {
    
    // MARK: - Stored Properties
    
    @Published var snippetsValue = [Snippet]()
    internal var snippets: Published<[Snippet]>.Publisher { $snippetsValue }
    
    private let fileManager = FileManager.default
    
    private var snippetsDirectoryURL: URL? {
        let directoryURLs = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )
        
        guard let directoryURL = directoryURLs.first else {
            return nil
        }
        
        let directory = directoryURL.appendingPathComponent("CodeSnippets")
        
        guard !fileManager.fileExists(atPath: directory.path) else {
            return directory
        }
        
        do {
            try fileManager.createDirectory(
                at: directoryURL.appendingPathComponent("CodeSnippets"),
                withIntermediateDirectories: false,
                attributes: nil
            )
        } catch {
            debugPrint(SnippetsParserServiceError.unableToCreateDirectory)
        }
        
        return directory
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        initialize()
    }
    
    // MARK: - Methods
    
    func createSnippet(_ snippet: Snippet) -> AnyPublisher<Void, SnippetsParserServiceError> {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        guard let snippetsDirectoryURL = self.snippetsDirectoryURL else {
            return Fail(error: .unableToFindSnippetsDirectory)
                .eraseToAnyPublisher()
        }
        
        return Future<Void, SnippetsParserServiceError> { promise in
            do {
                let plistSnippet = SnippetPlist(from: snippet)
                let data = try encoder.encode(plistSnippet)
                let filename = snippetsDirectoryURL.appendingPathComponent("\(snippet.id).codesnippet")
                try data.write(to: filename, options: [])
                self.snippetsValue.append(snippet)
                promise(.success(()))
            } catch {
                promise(.failure(.unableToSaveSnippet))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func removeSnippet(_ snippet: Snippet) -> AnyPublisher<Void, SnippetsParserServiceError> {
        guard let snippetsDirectoryURL = self.snippetsDirectoryURL else {
            return Fail(error: .unableToFindSnippetsDirectory)
                .eraseToAnyPublisher()
        }
        
        return Future<Void, SnippetsParserServiceError> { promise in
            do {
                let fileURL = snippetsDirectoryURL.appendingPathComponent("\(snippet.id).codesnippet")
                try self.fileManager.removeItem(at: fileURL)
                self.snippetsValue.removeAll { $0.id == snippet.id }
                promise(.success(()))
            } catch {
                promise(.failure(.unableToRemoveSnippet))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func initialize() {
        fetchSnippets()
            .sink { completion in
                switch completion {
                case .finished: return
                case let .failure(error):
                    debugPrint("Error: \(error.localizedDescription)")
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchSnippets() -> AnyPublisher<Void, SnippetsParserServiceError> {
        let decoder = PropertyListDecoder()
        
        guard let snippetsDirectoryURL = self.snippetsDirectoryURL else {
            return Fail(error: .unableToFindSnippetsDirectory)
                .eraseToAnyPublisher()
        }
        
        return Future<Void, SnippetsParserServiceError> { promise in
            do {
                let files = try self.fileManager.contentsOfDirectory(atPath: snippetsDirectoryURL.path)
                for file in files where file.contains(".codesnippet") {
                    let fileDirectory = snippetsDirectoryURL.appendingPathComponent(file)
                    let data = try Data(contentsOf: fileDirectory)
                    let snippet = try decoder.decode(
                        Snippet.self,
                        from: data
                    )
                    self.snippetsValue.append(snippet)
                }
                promise(.success(()))
            } catch {
                promise(.failure(.unableToDecodeSnippet))
            }
        }
        .eraseToAnyPublisher()
    }
    
}
