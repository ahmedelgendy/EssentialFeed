//
//  FeedViewController+Helpers.swift
//  EssentialFeediOSTests
//
//  Created by Ahmed Elgendy on 4.11.2022.
//

import Foundation
import EssentialFeediOS

extension FeedViewController {
    
    var errorMessage: String? {
        errorView.message
    }
    
    func simulateErrorViewTapping() {
        errorView.button.simulateButtonTapped()
    }
    
    func simulateFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    func feedImageView(at index: Int) -> FeedImageCell? {
        guard numberOfRenderedFeedImageViews() > index else {
            return nil
        }
        let dataSource = tableView.dataSource
        let indexPath = IndexPath(item: index, section: feedImagesSection)
        return dataSource?.tableView(tableView, cellForRowAt: indexPath) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index)
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    @discardableResult
    func simulateFeedImageViewInVisible(at index: Int) -> FeedImageCell? {
        let cell = simulateFeedImageViewVisible(at: index)!
        let delegate = tableView.delegate
        let indexPath = IndexPath(item: index, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        return cell
    }
    
    func simulateFeedImageViewNearVisible(at index: Int) {
        let prefetch = tableView.prefetchDataSource
        prefetch?.tableView(tableView, prefetchRowsAt: [IndexPath(item: index, section: feedImagesSection)])
    }
    
    func simulateFeedImageViewNearInVisible(at index: Int) {
        let prefetch = tableView.prefetchDataSource
        prefetch?.tableView?(tableView, cancelPrefetchingForRowsAt: [IndexPath(item: index, section: feedImagesSection)])
    }
    
    private var feedImagesSection: Int {
        return 0
    }
}
