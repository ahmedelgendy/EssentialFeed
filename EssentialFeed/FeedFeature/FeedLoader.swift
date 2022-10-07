//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 2.10.2022.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
