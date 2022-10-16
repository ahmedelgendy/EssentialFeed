//
//  FeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 16.10.2022.
//

import Foundation
import XCTest

class FeedStore {
    var deletionCount = 0
}

class LocalFeedLoader {
    private let feedStore: FeedStore
    
    init(feedStore: FeedStore) {
        self.feedStore = feedStore
    }
    
}

class FeedStoreTests: XCTestCase {
    
    func test_init_doesnotClearCacheUponCreation() {
        let store = FeedStore()
        let _ = LocalFeedLoader(feedStore: store)
        
        XCTAssertEqual(store.deletionCount, 0)
    }
    
}
