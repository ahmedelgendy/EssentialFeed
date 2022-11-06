//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 6.11.2022.
//

import XCTest

class FeedPresenter {
    private let view: Any
    init(view: Any) {
        self.view = view
    }
}

class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        XCTAssertEqual(view.messages, [])
    }
    
    // MARK: Helper Methods
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let presenter = FeedPresenter(view: view)
        trackForMemoryLeak(instance: view, file: file, line: line)
        trackForMemoryLeak(instance: presenter, file: file, line: line)
        return (sut: presenter, view: view)
    }
    
    class ViewSpy {
        enum Message: Hashable {
            
        }
        private(set) var messages = Set<Message>()
    }
    
}
