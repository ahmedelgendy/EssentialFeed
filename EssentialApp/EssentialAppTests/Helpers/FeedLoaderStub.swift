//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Ahmed Elgendy on 23.11.2022.
//

import EssentialFeed

class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
