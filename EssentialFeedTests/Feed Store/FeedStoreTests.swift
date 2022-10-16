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
    var deletionCount = 0
    
    func deleteCachedFeed() {
        deletionCount += 1
    }
}

class LocalFeedLoader {
    private let feedStore: FeedStore
    
    init(feedStore: FeedStore) {
        self.feedStore = feedStore
    }
    
    func save(_ items: [FeedItem]) {
        feedStore.deleteCachedFeed()
    }
    
}

class FeedStoreTests: XCTestCase {
    
    func test_init_doesnotClearCacheUponCreation() {
        let store = FeedStore()
        let _ = LocalFeedLoader(feedStore: store)
        
        XCTAssertEqual(store.deletionCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let store = FeedStore()
        let sut = LocalFeedLoader(feedStore: store)
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        XCTAssertEqual(store.deletionCount, 1)
    }
    
    // MARK: - HELPERS
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}
