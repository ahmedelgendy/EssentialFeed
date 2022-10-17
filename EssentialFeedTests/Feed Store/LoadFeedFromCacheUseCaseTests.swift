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
        let exp = expectation(description: "Wait load completion")
        sut.load() { result in
            switch result {
            case .success:
                XCTFail("Expected failure, found \(result) instead")
            case .failure(let error as NSError):
                XCTAssertEqual(error, retrievalError)
            }
            exp.fulfill()
        }
        store.completeRetrieval(withError: retrievalError)
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_deliverEmptyImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "Wait load completion")
        var recievedImages: [FeedItem]?
        sut.load() { result in
            switch result {
            case .success(let feed):
                recievedImages = feed
            default:
                XCTFail("Expected success, found \(result) instead")
            }
            exp.fulfill()
        }
        store.completeRetrievalSuccessfully()
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(recievedImages, [])
    }

    // MARK: - HELPERS

    private func makeSUT(timestamp: @escaping () -> Date = { Date() }, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(feedStore: store, currentDate: timestamp)
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return (sut: sut, store: store)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
}
