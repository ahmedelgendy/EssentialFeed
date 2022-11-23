//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 23.11.2022.
//

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
