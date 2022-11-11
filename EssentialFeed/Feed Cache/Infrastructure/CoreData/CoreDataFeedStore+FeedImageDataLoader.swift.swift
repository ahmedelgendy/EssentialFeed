//
//  CoreDataFeedStore+FeedImageDataLoader.swift.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 11.11.2022.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
    
}
