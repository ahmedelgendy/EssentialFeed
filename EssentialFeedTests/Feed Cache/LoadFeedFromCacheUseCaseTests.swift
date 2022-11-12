//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 17.10.2022.
//

import Foundation
import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    /// it's ok to duplicate this test since it's in a different context
    func test_init_doesnotClearCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        sut.load() { _ in }
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrieveError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        expect(sut, completeWith: .failure(retrievalError)) {
            store.completeRetrieval(withError: retrievalError)
        }
    }
    
    func test_load_deliverEmptyImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        expect(sut, completeWith: .success([])) {
            store.completeRetrievalWithEmptyImages()
        }
    }
    
    func test_load_deliverCachedImagesOnValidCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let feed = uniqueImageFeed()
        let validTimestamp = currentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        expect(sut, completeWith: .success(feed.models)) {
            store.completeRetrieval(with: feed.local, timestamp: validTimestamp)
        }
    }
    
    func test_load_deliverNoImagesOnInvalidCacheMaxDays() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let feed = uniqueImageFeed()
        let invalidTimestamp = currentDate.minusFeedCacheMaxAge()
        expect(sut, completeWith: .success([])) {
            store.completeRetrieval(with: feed.local, timestamp: invalidTimestamp)
        }
    }
    
    func test_load_deliverNoImagesOnInvalidCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let feed = uniqueImageFeed()
        let validTimestamp = currentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        expect(sut, completeWith: .success([])) {
            store.completeRetrieval(with: feed.local, timestamp: validTimestamp)
        }
    }
    
    func test_load_hasNoSideEffectOnCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        sut.load() { _ in }
        store.completeRetrieval(withError: retrievalError)
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnEmptyCache() {
        let (sut, store) = makeSUT()
        sut.load() { _ in }
        store.completeRetrieval(with: [], timestamp: Date())
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnValidCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let feed = uniqueImageFeed()
        let validTimestamp = currentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        
        sut.load() { _ in }
        store.completeRetrieval(with: feed.local, timestamp: validTimestamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnInvalidCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let feed = uniqueImageFeed()
        let invalidTimestamp = currentDate.minusFeedCacheMaxAge()
        
        sut.load() { _ in }
        store.completeRetrieval(with: feed.local, timestamp: invalidTimestamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_doesnotDeliverResultAfterSUTDeallocation() {
        let currentDate = Date()
        let feedStore = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: feedStore, currentDate: { currentDate })
        
        var recievedResults = [LocalFeedLoader.LoadResult]()
        sut?.load { recievedResults.append($0) }
        
        sut = nil
        feedStore.completeRetrievalWithEmptyImages()
        
        XCTAssertTrue(recievedResults.isEmpty)
    }

    // MARK: - HELPERS

    private func expect(_ sut: LocalFeedLoader, completeWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait load completion")
        sut.load() { result in
            switch (result, expectedResult) {
            case let (.success(items), .success(expectedItems)):
                XCTAssertEqual(items, expectedItems, file: file, line: line)
            case let (.failure(error as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), found \(result) instead")
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = { Date() }, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return (sut: sut, store: store)
    }
}
