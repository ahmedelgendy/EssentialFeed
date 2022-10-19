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
    
    func test_load_deliverCachedImagesOnLessThanSevenDaysOldCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let items = uniqueItems()
        let lessThanSevenDaysTimestamp = currentDate.adding(days: -7).adding(seconds: 1)
        expect(sut, completeWith: .success(items.models)) {
            store.completeRetrieval(with: items.localItems, timestamp: lessThanSevenDaysTimestamp)
        }
    }
    
    func test_load_deliverNoImagesOnSevenDaysOldCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let items = uniqueItems()
        let sevenDaysTimestamp = currentDate.adding(days: -7)
        expect(sut, completeWith: .success([])) {
            store.completeRetrieval(with: items.localItems, timestamp: sevenDaysTimestamp)
        }
    }
    
    func test_load_deliverNoImagesOnMoreThanSevenDaysOldCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let items = uniqueItems()
        let lessThanSevenDaysTimestamp = currentDate.adding(days: -10)
        expect(sut, completeWith: .success([])) {
            store.completeRetrieval(with: items.localItems, timestamp: lessThanSevenDaysTimestamp)
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
    
    func test_load_hasNoSideEffectOnLessThanSevenDaysOldCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let items = uniqueItems()
        let lessThanSevenDaysTimestamp = currentDate.adding(days: -7).adding(seconds: 1)
        
        sut.load() { _ in }
        store.completeRetrieval(with: items.localItems, timestamp: lessThanSevenDaysTimestamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_deletesCacheOnSevenDaysOldCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let items = uniqueItems()
        let sevenDaysTimestamp = currentDate.adding(days: -7)
        
        sut.load() { _ in }
        store.completeRetrieval(with: items.localItems, timestamp: sevenDaysTimestamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve, .deletion])
    }
    
    func test_load_doesnotDeliverResultAfterSUTDeinitalization() {
        let currentDate = Date()
        let feedStore = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(feedStore: feedStore, currentDate: { currentDate })
        
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
        let sut = LocalFeedLoader(feedStore: store, currentDate: currentDate)
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return (sut: sut, store: store)
    }
}
