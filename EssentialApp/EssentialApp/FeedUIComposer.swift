//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 1.11.2022.
//

import Foundation
import EssentialFeed
import UIKit
import EssentialFeediOS

public final class FeedUIComposer {
    
    private init() { }
    
    public static func feedComposedWith(feedLoader: @escaping () -> FeedLoader.Publisher, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedLoaderAdapter = FeedLoaderPresentationAdapter(feedLoader: { feedLoader().dispatchOnMainThread() })
        let feedViewController = instantiateFeedViewController(with: feedLoaderAdapter, title: FeedPresenter.title)
        let feedPresenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedViewController, imageLoader: imageLoader), loadingView: WeakRefProxy(feedViewController), errorView: WeakRefProxy(feedViewController)
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
