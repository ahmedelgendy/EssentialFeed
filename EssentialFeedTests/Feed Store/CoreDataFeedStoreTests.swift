//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 23.10.2022.
//

import XCTest
import EssentialFeed

class CoreDataFeedStore: FeedStore {
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping DeletionCompletion) {
        
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        
    }
    
}

class CoreDataFeedStoreTests: XCTestCase {

    
    
    // MARK: - HELPERS
    private func makeSUT() -> FeedStore {
        let sut = CoreDataFeedStore()
        trackForMemoryLeak(instance: sut)
        return sut
    }
}
