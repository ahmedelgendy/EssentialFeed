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

    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        sut.validateCache()
        store.completeRetrieval(withError: retrievalError)
        XCTAssertEqual(store.recievedMessages, [.retrieve, .deletion])
    }
    
    func test_validateCache_doesnotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        sut.validateCache()
        store.completeRetrievalWithEmptyImages()
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_validateCache_doesnotDeleteCacheLessThanSevenDaysOldCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let items = uniqueItems()
        let lessThanSevenDaysTimestamp = currentDate.adding(days: -7).adding(seconds: 1)
        
        sut.load() { _ in }
        store.completeRetrieval(with: items.localItems, timestamp: lessThanSevenDaysTimestamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
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
