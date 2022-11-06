//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 6.11.2022.
//

import XCTest
import EssentialFeed

final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT(imageTransformer: fail)
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage() {
        let (presenter, view) = makeSUT(imageTransformer: fail)
        
        let image = uniqueItem()
        presenter.didStartLoadingImageData(for: image)
        
        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysLoadedImage() {
        let transformedData = AnyImage()
        let (presenter, view) = makeSUT(imageTransformer: { _ in transformedData })
        let image = uniqueItem()
        presenter.didFinishLoadingImageData(with: Data(), model: image)
        
        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.image, transformedData)
    }
    
    func test_didFinishLoadingImageData_displaysRetry() {
        let transformedData = AnyImage()
        let (presenter, view) = makeSUT(imageTransformer: { _ in transformedData })
        let image = uniqueItem()
        
        presenter.didFinishLoadingImageData(with: anyNSError(), model: image)
        
        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertNil(message?.image)
    }
    
    // MARK: Helpers
    private struct AnyImage: Equatable {}

    private class ViewSpy: FeedImageView {
        
        private(set) var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ viewModel: FeedImageViewModel<AnyImage>) {
            messages.append(viewModel)
        }
    }
    
    private func makeSUT(imageTransformer: @escaping ((Data) -> FeedImagePresenterTests.AnyImage?), file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeak(instance: view, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return (sut: sut, view: view)
    }
    
    private var fail: (Data) -> AnyImage? {
            return { _ in nil }
        }

}
