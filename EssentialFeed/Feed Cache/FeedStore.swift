//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 16.10.2022.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case found(local: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping DeletionCompletion)
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
