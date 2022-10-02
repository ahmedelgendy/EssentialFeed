//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 2.10.2022.
//

import Foundation

enum FeedResult {
    case success([FeedItem])
    case empty
    case error
}

protocol FeedLoader {
    func load(completion: @escaping (FeedResult) -> Void)
}
