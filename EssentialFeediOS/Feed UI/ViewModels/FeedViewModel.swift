//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 1.11.2022.
//

import EssentialFeed

final class FeedViewModel {
 
    private let loader: FeedLoader
    
    var onLoadingStateChange: ((Bool) -> ())?
    var onFeedLoaded: (([FeedImage]) -> ())?

    init(loader: FeedLoader) {
        self.loader = loader
    }

    func loadFeed() {
        onLoadingStateChange?(true)
        loader.load { [weak self] result in
            guard let self = self else { return }
            if let feed = try? result.get() {
                self.onFeedLoaded?(feed)
            }
            self.onLoadingStateChange?(false)
        }
    }
}
