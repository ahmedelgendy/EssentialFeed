//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 1.11.2022.
//

import EssentialFeed

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    private let loader: FeedLoader
    
    var loadingView: FeedLoadingView?
    var feedView: FeedView?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }

    func loadFeed() {
        loadingView?.display(isLoading: true)
        loader.load { [weak self] result in
            guard let self = self else { return }
            if let feed = try? result.get() {
                self.feedView?.display(feed: feed)
            }
            self.loadingView?.display(isLoading: false)
        }
    }
}
