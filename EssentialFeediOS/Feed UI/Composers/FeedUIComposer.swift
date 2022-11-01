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
        let refreshController = FeedRefreshController(loader: feedLoader)
        let feedViewController = FeedViewController(refreshController: refreshController)
        
        refreshController.onRefresh = { [weak feedViewController] feed in
            feedViewController?.tableModel = feed.map { FeedImageCellController(model: $0, imageLoader: imageLoader)}
        }
        return feedViewController
    }
    
}
