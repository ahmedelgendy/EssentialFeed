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
        let feedLoaderAdapter = FeedLoaderPresentationAdapter(loader: MainQueueDispatchDecorator(decoratee: feedLoader))
        let feedViewController = instantiateFeedViewController(with: feedLoaderAdapter, title: FeedPresenter.title)
        let feedPresenter = FeedPresenter(
            loadingView: WeakRefProxy(feedViewController),
            feedView: FeedViewAdapter(controller: feedViewController, imageLoader: imageLoader)
        )
        feedLoaderAdapter.presenter = feedPresenter
        return feedViewController
    }

    static func instantiateFeedViewController(with delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
