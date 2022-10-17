//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 16.10.2022.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping DeletionCompletion)
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func retrieve()
}
