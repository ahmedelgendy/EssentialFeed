//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 1.11.2022.
//

import EssentialFeed

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    
    private var errorView: FeedErrorView
    private var loadingView: FeedLoadingView
    private var feedView: FeedView
    
    static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Title for my feed")
    }
    
    var errorMessage: String {
        NSLocalizedString("FEED_VIEW_CONNECTION_ERROR", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Title for my feed")
    }
    
    init(loadingView: FeedLoadingView, feedView: FeedView, errorView: FeedErrorView) {
        self.loadingView = loadingView
        self.feedView = feedView
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoading(with error: Error) {
        errorView.display(.error(message: errorMessage))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
}
