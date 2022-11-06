//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 6.11.2022.
//

import XCTest


struct FeedLoadingViewModel {
    let isLoading: Bool
}

struct FeedErrorViewModel {
    var message: String?
    static var noError: FeedErrorViewModel = {
        FeedErrorViewModel(message: nil)
    }()
    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}


protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

class FeedPresenter {
    private let errorView: FeedErrorView
    private let loadingView: FeedLoadingView
    
    var errorMessage: String {
        NSLocalizedString("FEED_VIEW_CONNECTION_ERROR", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Title for my feed")
    }
    
    init(loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.errorView = errorView
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoading(with error: Error) {
        errorView.display(.error(message: errorMessage))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
}

class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        XCTAssertEqual(view.messages, [])
    }
    
    func test_didStartLoadingFeed_doesNotDisplayErrorAndStartLoading() {
        let (sut, view) = makeSUT()
        sut.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [
            .display(errorMessage: nil),
            .display(isLoading: true)
        ])
    }
    
    func test_didFinishLoading_displaysErrorAndEndLoading() {
        let (sut, view) = makeSUT()
        sut.didFinishLoading(with: anyNSError())
        XCTAssertEqual(view.messages, [
            .display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")),
            .display(isLoading: false)
        ])
    }
    
    // MARK: Helper Methods
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let presenter = FeedPresenter(loadingView: view, errorView: view)
        trackForMemoryLeak(instance: view, file: file, line: line)
        trackForMemoryLeak(instance: presenter, file: file, line: line)
        return (sut: presenter, view: view)
    }
    
    class ViewSpy: FeedErrorView, FeedLoadingView {
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
    }
    
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let title = bundle.localizedString(forKey: key, value: nil, table: "Feed")
        if title == key {
            XCTFail("No localized value found for \(key)", file: file, line: line)
        }
        return title
    }
    
}