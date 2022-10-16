//
//  FeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 16.10.2022.
//

import Foundation
import XCTest
import EssentialFeed

class FeedStoreTests: XCTestCase {
    
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
        let items = uniqueItems()
        sut.save(items.models) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.recievedMessages, [.deletion, .insertion(items.localItems, timestamp)])
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
        var sut: LocalFeedLoader? = LocalFeedLoader(feedStore: store, currentDate: Date.init)
        
        var recievedErrors = [LocalFeedLoader.SaveResult?]()
        sut?.save(uniqueItems().models) { recievedErrors.append($0)}
        sut = nil
        store.completeDeletion(withError: anyNSError())

        XCTAssertTrue(recievedErrors.isEmpty)
    }
    
    func test_save_doesnotDeliverInsertionErrorAfterSUTInstanceDeallocation() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(feedStore: store, currentDate: Date.init)
        
        var recievedErrors = [LocalFeedLoader.SaveResult?]()
        sut?.save(uniqueItems().models) { recievedErrors.append($0)}
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(withError: anyNSError())
        XCTAssertTrue(recievedErrors.isEmpty)
    }
    
    // MARK: - HELPERS
    
    private func expect(sut: LocalFeedLoader, completeWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait saving items")
        var recievedError: NSError?
        sut.save(uniqueItems().models) { error in
            recievedError = error as? NSError
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(recievedError, expectedError, file: file, line: line)
    }
    
    private func makeSUT(timestamp: @escaping () -> Date = { Date() }, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(feedStore: store, currentDate: timestamp)
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return (sut: sut, store: store)
    }
    
    private func uniqueItems() -> (models: [FeedItem], localItems: [LocalFeedImage]) {
        let items = [uniqueItem(), uniqueItem()]
        let localItems = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
        return (models: items, localItems: localItems)
    }
    
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    
    private class FeedStoreSpy: FeedStore {

        var deletionCompletions: [DeletionCompletion] = []
        var insertionCompletions: [InsertionCompletion] = []

        enum RecievedMessage: Equatable {
            case deletion
            case insertion([LocalFeedImage], Date)
        }
        
        var recievedMessages: [RecievedMessage] = []
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deletionCompletions.append(completion)
            recievedMessages.append(.deletion)
        }
        
        func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping DeletionCompletion) {
            insertionCompletions.append(completion)
            recievedMessages.append(.insertion(items, timestamp))
        }
        
        func completeDeletion(withError error: Error?, index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func completeInsertion(withError error: Error?, index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completeInsertionSuccessfully(index: Int = 0) {
            insertionCompletions[index](nil)
        }
    }
    
}

//private extension  Array where Element ==
