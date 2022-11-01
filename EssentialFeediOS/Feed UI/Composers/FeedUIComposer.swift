//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 1.11.2022.
//

import Foundation
import EssentialFeed

public final class FeedUIComposer {
    
    private init() { }
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageLoaderDataLoader) -> FeedViewController {
        let viewModel = FeedViewModel(loader: feedLoader)
        let refreshController = FeedRefreshController(viewModel: viewModel)
        let feedViewController = FeedViewController(refreshController: refreshController)
        viewModel.onFeedLoaded = adaptFeedToCellControllers(forwardingTo: feedViewController, imageLoader: imageLoader)
        return feedViewController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, imageLoader: FeedImageLoaderDataLoader) -> ([FeedImage]) -> Void {
         return { [weak controller] feed in
             controller?.tableModel = feed.map { FeedImageCellController(model: $0, imageLoader: imageLoader)}
        }
    }
    
}
