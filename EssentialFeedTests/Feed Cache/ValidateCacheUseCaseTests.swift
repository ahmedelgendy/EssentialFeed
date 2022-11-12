//
//  ValidateCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 19.10.2022.
//

import XCTest
import EssentialFeed

class ValidateCacheUseCaseTests: XCTestCase {

    func test_init_doesnotClearCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }

    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        sut.validateCache { _ in }
        store.completeRetrieval(withError: retrievalError)
        XCTAssertEqual(store.recievedMessages, [.retrieve, .deletion])
    }
    
    func test_validateCache_doesnotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        sut.validateCache { _ in }
        store.completeRetrievalWithEmptyImages()
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_validateCache_doesnotDeleteValidCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let feed = uniqueImageFeed()
        let validTimestamp = currentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        sut.validateCache { _ in }
        store.completeRetrieval(with: feed.local, timestamp: validTimestamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesInvalidCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let feed = uniqueImageFeed()
        let invalidTimestamp = currentDate.minusFeedCacheMaxAge()
        
        sut.validateCache { _ in }
        store.completeRetrieval(with: feed.local, timestamp: invalidTimestamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve, .deletion])
    }
    
    func test_validateCache_doesnotDeleteCacheAfterSUTDeallocation() {
        let currentDate = Date()
        let feedStore = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: feedStore, currentDate: { currentDate })
        
        sut?.validateCache { _ in }

        sut = nil
        feedStore.completeRetrieval(withError: anyNSError())
        
        XCTAssertEqual(feedStore.recievedMessages, [.retrieve])
    }
    
    // MARK: - HELPERS

    private func makeSUT(currentDate: @escaping () -> Date = { Date() }, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return (sut: sut, store: store)
    }
}
