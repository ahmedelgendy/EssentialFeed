//
//  FeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 16.10.2022.
//

import Foundation
import XCTest
import EssentialFeed

class FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    var deletionCount = 0
    var insertionCount = 0
    
    var deletionCompletions: [DeletionCompletion] = []
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        deletionCount += 1
    }
    
    func insert(_ items: [FeedItem]) {
        insertionCount += 1
    }
    
    func complete(withError error: Error?, index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(index: Int = 0) {
        deletionCompletions[index](nil)
    }
}

class LocalFeedLoader {
    private let feedStore: FeedStore
    
    init(feedStore: FeedStore) {
        self.feedStore = feedStore
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        feedStore.deleteCachedFeed { [unowned self] error in
            if let error = error {
                completion(error)
            } else {
                feedStore.insert(items)
            }
        }
    }
    
}

class FeedStoreTests: XCTestCase {
    
    func test_init_doesnotClearCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deletionCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) { _ in }
        XCTAssertEqual(store.deletionCount, 1)
    }
    
    func test_save_doesnotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem()]
        sut.save(items) { _ in }
        store.complete(withError: anyNSError())
        XCTAssertEqual(store.insertionCount, 0)
    }
    
    func test_save_requestInsertionOnDeletionSuccess() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem()]
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.insertionCount, 1)
    }
    
    // MARK: - HELPERS
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(feedStore: store)
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return (sut: sut, store: store)
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
    
}
