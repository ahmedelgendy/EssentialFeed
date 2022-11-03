//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 1.11.2022.
//

import Foundation
import EssentialFeed
import UIKit

public final class FeedUIComposer {
    
    private init() { }
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageLoaderDataLoader) -> FeedViewController {
        let feedLoaderAdapter = FeedLoaderPresentationAdapter(loader: feedLoader)
        let refreshController = FeedRefreshController(loadFeed: feedLoaderAdapter.loadFeed)
        let feedViewController = FeedViewController(refreshController: refreshController)
        let feedPresenter = FeedPresenter(
            loadingView: WeakRefProxy(refreshController),
            feedView: FeedViewAdapter(controller: feedViewController, imageLoader: imageLoader)
        )
        feedLoaderAdapter.presenter = feedPresenter
        return feedViewController
    }

    
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageLoaderDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageLoaderDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map {
            let viewModel = FeedImageViewModel(model: $0, imageLoader: imageLoader, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel: viewModel)
        }
    }
}

private final class FeedLoaderPresentationAdapter {
    private let loader: FeedLoader
    var presenter: FeedPresenter?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func loadFeed() {
        presenter?.didStartLoadingFeed()
        loader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
            case .failure(let error):
                self?.presenter?.didFinishLoading(with: error)
            }
        }
    }
}


final class WeakRefProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}
