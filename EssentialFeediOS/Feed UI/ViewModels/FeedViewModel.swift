//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 1.11.2022.
//

import EssentialFeed

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    private let loader: FeedLoader
    
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoaded: Observer<[FeedImage]>?

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
