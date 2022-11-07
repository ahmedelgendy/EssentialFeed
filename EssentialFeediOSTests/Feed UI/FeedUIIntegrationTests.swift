//
//  FeedUIIntegrationTests.swift
//  EssentialFeediOSTests
//
//  Created by Ahmed Elgendy on 29.10.2022.
//

import Foundation
import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedUIIntegrationTests: XCTestCase {
    
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        XCTAssertEqual(sut.title, localized("FEED_VIEW_TITLE"))
    }
    
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let title = bundle.localizedString(forKey: key, value: nil, table: "Feed")
        if title == key {
            XCTFail("No localized value found for \(key)", file: file, line: line)
        }
        return title
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view loading")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once the view is loaded")
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a load")
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected a third loading request once user initiates another load")
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
        let image0 = feedImage(description: "some desc", location: "some location")
        let image1 = feedImage(description: nil, location: "some location")
        let image2 = feedImage(description: "some desc", location: nil)
        
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
        let image0 = feedImage(description: "some desc", location: "some location")
        let image1 = feedImage(description: nil, location: "some location")
        let image2 = feedImage(description: "some desc", location: nil)
        let feed = [image0, image1, image2]
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: feed, at: 0)
        
        sut.simulateFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRenderring: feed)
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let (sut, loader) = makeSUT()
        let image0 = feedImage(description: "some desc", location: "some location")
        let image1 = feedImage(description: nil, location: "some location")
        let feed = [image0, image1]
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: feed, at: 0)
        XCTAssertEqual(loader.loadedImagesURL, [])
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImagesURL, [image0.imageURL])
    }
    
    func test_feedImageView_cancelImageURLWhenInVisible() {
        let (sut, loader) = makeSUT()
        let image0 = feedImage(description: "some desc", location: "some location")
        let image1 = feedImage(description: nil, location: "some location")
        let feed = [image0, image1]
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: feed, at: 0)
        XCTAssertEqual(loader.loadedImagesURL, [])
        
        sut.simulateFeedImageViewInVisible(at: 0)
        XCTAssertEqual(loader.canceledImageURLs, [image0.imageURL])
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        let image0 = feedImage(description: "some desc", location: "some location")
        let image1 = feedImage(description: nil, location: "some location")
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true)
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true)
        
        loader.completeImageLoading(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false)
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        let image0 = feedImage(url: URL(string: "https://anyURL1.com")!)
        let image1 = feedImage(url: URL(string: "https://anyURL2.com")!)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.renderedImage, .none)
        XCTAssertEqual(view1?.renderedImage, .none)
        let image0Data = UIImage.make(withColor: .cyan).pngData()!
        loader.completeImageLoading(with: image0Data, at: 0)
        XCTAssertEqual(view0?.renderedImage, image0Data)
        XCTAssertEqual(view1?.renderedImage, .none)
        
        let image1Data = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: image1Data, at: 1)
        XCTAssertEqual(view0?.renderedImage, image0Data)
        XCTAssertEqual(view1?.renderedImage, image1Data)
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        let image0 = feedImage()
        let image1 = feedImage()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingRetryButton, false)
        XCTAssertEqual(view1?.isShowingRetryButton, false)
        let image0Data = UIImage.make(withColor: .cyan).pngData()!
        loader.completeImageLoading(with: image0Data, at: 0)
        XCTAssertEqual(view0?.isShowingRetryButton, false)
        XCTAssertEqual(view1?.isShowingRetryButton, false)
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryButton, false)
        XCTAssertEqual(view1?.isShowingRetryButton, true)
    }
    
    func test_feedImageViewRetryAction_retriesImageLoad() {
        let (sut, loader) = makeSUT()
        let image0 = feedImage()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        loader.completeImageLoadingWithError(at: 0)
        view0?.simulateRetryButtonTapped()
                
        XCTAssertEqual(loader.loadedImagesURL, [image0.imageURL, image0.imageURL])
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let (sut, loader) = makeSUT()
        let image0 = feedImage(url: URL(string: "https://anyurl0.com")!)
        let image1 = feedImage(url: URL(string: "https://anyurl1.com")!)
        let image2 = feedImage(url: URL(string: "https://anyurl2.com")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1, image2], at: 0)

        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImagesURL, [image0.imageURL])

        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImagesURL, [image0.imageURL, image1.imageURL])

        sut.simulateFeedImageViewNearVisible(at: 2)
        XCTAssertEqual(loader.loadedImagesURL, [image0.imageURL, image1.imageURL, image2.imageURL])
    }
    
    func test_feedImageView_cancelsImageURLWhenNotVisible() {
        let (sut, loader) = makeSUT()
        let image0 = feedImage(url: URL(string: "https://anyurl0.com")!)
        let image1 = feedImage(url: URL(string: "https://anyurl1.com")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImagesURL, [image0.imageURL])

        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImagesURL, [image0.imageURL, image1.imageURL])

        sut.simulateFeedImageViewNearInVisible(at: 1)
        XCTAssertEqual(loader.canceledImageURLs, [image1.imageURL])
        
    }
    
    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnyMore() {
        let (sut, loader) = makeSUT()
        let image = feedImage()
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image], at: 0)

        let view = sut.simulateFeedImageViewInVisible(at: 0)
        loader.completeImageLoading(with: anyImageData(), at: 0)

        XCTAssertNil(view?.renderedImage)
    }
    
    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_loadImageDataCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [feedImage()])
        _ = sut.simulateFeedImageViewVisible(at: 0)

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeImageLoading(with: self.anyImageData(), at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_feedView_showsErrorMessageOnLoadFailure() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoadingWithError()
        XCTAssertEqual(sut.errorMessage, localized("FEED_VIEW_CONNECTION_ERROR"))
    }

    func test_feedView_hidesShownErrorViewOnFeedReload() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoadingWithError()
        XCTAssertNotNil(sut.errorMessage)

        sut.simulateFeedReload()
        XCTAssertNil(sut.errorMessage)

        loader.completeFeedLoadingWithError()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_errorView_hidesItselfOnTapping() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoadingWithError()
        XCTAssertNotNil(sut.errorMessage)

        sut.simulateErrorViewTapping()

        XCTAssertNil(sut.errorMessage)
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
    
    private func feedImage(description: String? = nil, location: String? = nil, url: URL = anyURL()) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, imageURL: url)
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let controller = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeak(instance: loader, file: file, line: line)
        trackForMemoryLeak(instance: controller, file: file, line: line)
        return (controller, loader)
    }
    
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        
        // MARK - FeedLoader
        
        private(set) var loadFeedCallCount = 0
        private var feedRequests: [(FeedLoader.Result) -> Void] = []
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
            loadFeedCallCount += 1
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "any domain", code: 0)
            feedRequests[index](.failure(error))
        }
        
        // MARK - FeedImageLoaderDataLoader
        var loadedImagesURL: [URL] {
            imageLoadingRequests.map(\.url)
        }
        private(set) var imageLoadingRequests = [(url: URL, result: ((FeedImageDataLoader.Result) -> Void))]()
        private(set) var canceledImageURLs = [URL]()
        struct FeedImageDataLoaderTaskSpy: FeedImageDataLoaderTask {
            var cancelCompletion: () -> ()
            func cancel() {
                cancelCompletion()
            }
            
        }
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageLoadingRequests.append((url, completion))
            return FeedImageDataLoaderTaskSpy { [weak self] in
                self?.canceledImageURLs.append(url)
            }
        }
        
        func completeImageLoading(with data: Data = Data(), at index: Int) {
            imageLoadingRequests[index].result(.success(data))
        }
        
        func completeImageLoadingWithError(at index: Int) {
            imageLoadingRequests[index].result(.failure(anyNSError()))
        }
        
    }
    
    private func anyImageData() -> Data {
        return UIImage.make(withColor: .cyan).pngData()!
    }
    
}
