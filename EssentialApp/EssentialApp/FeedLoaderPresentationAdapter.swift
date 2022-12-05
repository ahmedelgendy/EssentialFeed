//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 5.11.2022.
//

import EssentialFeed
import EssentialFeediOS
import Combine

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: () -> FeedLoader.Publisher
    private var cancellable: Cancellable?
    var presenter: FeedPresenter?
    
    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        cancellable = feedLoader()
            .dispatchOnMainThread()
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                break
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        } receiveValue: { [weak self] feed in
            self?.presenter?.didFinishLoadingFeed(with: feed)
        }
    }
}
