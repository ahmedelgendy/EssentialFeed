//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Ahmed Elgendy on 29.10.2022.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {

    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view loading")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once the view is loaded")

        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a load")
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading request once user initiates another load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
 
        sut.simulateFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let (sut, loader) = makeSUT()
        let image0 = uniqueFeed(description: "some desc", location: "some location")
        let image1 = uniqueFeed(description: nil, location: "some location")
        let image2 = uniqueFeed(description: "some desc", location: nil)

        sut.loadViewIfNeeded()
        
        assertThat(sut, isRenderring: [])

        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRenderring: [image0])
        
        sut.simulateFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2], at: 1)
        assertThat(sut, isRenderring: [image0, image1, image2])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let (sut, loader) = makeSUT()
        let image0 = uniqueFeed(description: "some desc", location: "some location")
        let image1 = uniqueFeed(description: nil, location: "some location")
        let image2 = uniqueFeed(description: "some desc", location: nil)
        let feed = [image0, image1, image2]
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: feed, at: 0)
        
        sut.simulateFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRenderring: feed)
    }
    
    // MARK: Helper Methods
    
    private func assertThat(_ sut: FeedViewController, isRenderring images: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenferedFeedImageViews() == images.count else {
            return XCTFail("Expected images count to be \(images.count), found \(sut.numberOfRenferedFeedImageViews()) instead", file: file, line: line)
        }
        images.enumerated().forEach { (index, image) in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let cell = sut.feedImageView(at: index)
        XCTAssertNotNil(cell, file: file, line: line)
        let shouldShowLocation = image.location != nil
        XCTAssertEqual(cell?.isShowingLocation, shouldShowLocation, "Expected 'isShowingLocation' to be \(shouldShowLocation)", file: file, line: line)
        XCTAssertEqual(cell?.descriptionText, image.description, file: file, line: line)
        XCTAssertEqual(cell?.locationText, image.location, file: file, line: line)
    }
    
    private func uniqueFeed(description: String?, location: String?) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, imageURL: anyURL())
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let controller = FeedViewController(loader: loader)
        trackForMemoryLeak(instance: loader, file: file, line: line)
        trackForMemoryLeak(instance: controller, file: file, line: line)
        return (controller, loader)
    }
    
    class LoaderSpy: FeedLoader {
        var loadCallCount = 0
        
        private var loadingCompletions: [(FeedLoader.Result) -> Void] = []
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadingCompletions.append(completion)
            loadCallCount += 1
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            loadingCompletions[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let error = NSError(domain: "any domain", code: 0)
            loadingCompletions[index](.failure(error))
        }

    }

}

private extension FeedViewController {
    func simulateFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func numberOfRenferedFeedImageViews() -> Int {
        tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    func feedImageView(at index: Int) -> FeedImageCell? {
        let dataSource = tableView.dataSource
        let indexPath = IndexPath(item: index, section: feedImagesSection)
        return dataSource?.tableView(tableView, cellForRowAt: indexPath) as? FeedImageCell
    }
    
    private var feedImagesSection: Int {
        return 0
    }
}


extension FeedImageCell {
    
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var locationText: String? {
        locationLabel.text
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
