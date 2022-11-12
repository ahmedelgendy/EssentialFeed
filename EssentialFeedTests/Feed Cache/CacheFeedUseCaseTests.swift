//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 16.10.2022.
//

import Foundation
import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesnotClearCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) { _ in }
        XCTAssertEqual(store.recievedMessages, [.deletion])
    }
    
    func test_save_doesnotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem()]
        sut.save(items) { _ in }
        store.completeDeletion(withError: anyNSError())
        XCTAssertEqual(store.recievedMessages, [.deletion])
    }
    
    func test_save_requestsInsertionWithTimestampOnDeletionSuccess() {
        let timestamp = Date()
        let (sut, store) = makeSUT(timestamp: { timestamp })
        let feed = uniqueImageFeed()
        sut.save(feed.models) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.recievedMessages, [.deletion, .insertion(feed.local, timestamp)])
    }
    
    func test_save_deliversErrorOnDeletionError() {
        let (sut, store) = makeSUT()
        let expectedError = anyNSError()
        expect(sut: sut, completeWithError: expectedError) {
            store.completeDeletion(withError: expectedError)
        }
    }

    func test_save_deliversErrorOnInsertionError() {
        let (sut, store) = makeSUT()
        let expectedError = anyNSError()
        expect(sut: sut, completeWithError: expectedError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(withError: expectedError)
        }
    }
    
    func test_save_deliversSuccessOnInsertionSuccess() {
        let (sut, store) = makeSUT()
        expect(sut: sut, completeWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesnotDeliverDeletionErrorAfterSUTInstanceDeallocation() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var recievedErrors = [LocalFeedLoader.SaveResult?]()
        sut?.save(uniqueImageFeed().models) { recievedErrors.append($0)}
        sut = nil
        store.completeDeletion(withError: anyNSError())

        XCTAssertTrue(recievedErrors.isEmpty)
    }
    
    func test_save_doesnotDeliverInsertionErrorAfterSUTInstanceDeallocation() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var recievedErrors = [LocalFeedLoader.SaveResult?]()
        sut?.save(uniqueImageFeed().models) { recievedErrors.append($0)}
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(withError: anyNSError())
        XCTAssertTrue(recievedErrors.isEmpty)
    }
    
    // MARK: - HELPERS
    
    private func expect(sut: LocalFeedLoader, completeWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait saving items")
        var recievedError: NSError?
        sut.save(uniqueImageFeed().models) { result in
            switch result {
            case .failure(let error as NSError):
                recievedError = error
            default: break
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(recievedError, expectedError, file: file, line: line)
    }
    
    private func makeSUT(timestamp: @escaping () -> Date = { Date() }, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: timestamp)
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return (sut: sut, store: store)
    }
    
}
