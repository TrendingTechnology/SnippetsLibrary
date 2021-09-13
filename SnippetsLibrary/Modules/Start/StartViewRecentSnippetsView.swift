//
//  StartViewRecentSnippetsView.swift
//  SnippetsLibrary
//
//  Created by Krzysztof Łowiec on 07/09/2021.
//

import SwiftUI

struct StartViewRecentSnippetsView: View {
    
    private enum Constants {
        static let viewSize = CGSize(width: 850, height: 460)
        static let spacerHeight: CGFloat = 16.0
        static let scrollViewHorizontalPadding: CGFloat = 10.0
    }
    
    // MARK: - Stored Properties
    
    @State private(set) var recentSnippets: [Snippet]
    
    @Binding internal var activeAppView: ActiveAppView?
    
    @State private var selectedSnippetIndex: Int?
    
    // MARK: - Views
    
    var body: some View {
        VStack(spacing: .zero) {
            Text("No Recent Files")
                .font(.system(size: 17.0))
                .foregroundColor(
                    .primary
                        .opacity(Layout.mediumOpacity)
                )
                .frame(height: Constants.viewSize.height)
                .makeVisible(
                    recentSnippets.isEmpty,
                    removed: true
                )
            
            ScrollView(showsIndicators: false) {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: Constants.spacerHeight)
                
                ForEach(
                    Array(recentSnippets.enumerated()),
                    id: \.offset
                ) { (index, file) in
                    RecentSnippetCardView(
                        snippet: file,
                        tag: index,
                        selectedFileIndex: $selectedSnippetIndex
                    ) {
                        activeAppView = .snippetsLibrary(file)
                    }
                }
            }
            .background(Color.clear)
            .makeVisible(!recentSnippets.isEmpty)
            .padding(.horizontal, Constants.scrollViewHorizontalPadding)
        }
        .frame(width: Constants.viewSize.width * 0.38)
        .background(
            VisualEffectView(
                material: .menu,
                blendingMode: .behindWindow
            )
        )
        .ignoresSafeArea()
    }
    
}

struct StartViewRecentSnippetsView_Previews: PreviewProvider {
    static var previews: some View {
        StartViewRecentSnippetsView(recentSnippets: [], activeAppView: .constant(nil))
    }
}
