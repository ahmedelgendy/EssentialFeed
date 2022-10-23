//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 23.10.2022.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    
    public init() {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping DeletionCompletion) {
        
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
}
