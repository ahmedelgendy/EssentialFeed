//
//  InvalidateCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 19.10.2022.
//

import XCTest
import EssentialFeed

class InvalidateCacheUseCaseTests: XCTestCase {

    func test_init_doesnotClearCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }

    
    // MARK: - HELPERS

    private func makeSUT(currentDate: @escaping () -> Date = { Date() }, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(feedStore: store, currentDate: currentDate)
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return (sut: sut, store: store)
    }
}
