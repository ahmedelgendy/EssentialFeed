//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 1.11.2022.
//

import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}
protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    
    var loadingView: FeedLoadingView?
    var feedView: FeedView?
    
    func didStartLoadingFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView?.display(FeedViewModel(feed: feed))
        loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoading(with error: Error) {
        loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
    
}

final class FeedLoaderPresentationAdapter {
    private let loader: FeedLoader
    private let presenter: FeedPresenter
    
    init(loader: FeedLoader, presenter: FeedPresenter) {
        self.loader = loader
        self.presenter = presenter
    }
    
    func loadFeed() {
        presenter.didStartLoadingFeed()
        loader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.presenter.didFinishLoadingFeed(with: feed)
            case .failure(let error):
                self?.presenter.didFinishLoading(with: error)
            }
        }
    }
}
