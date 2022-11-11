//
//  CoreDataFeedStore+FeedImageDataLoader.swift.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 11.11.2022.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedFeedImage.first(with: url, in: context).map { $0.data = data}.map(context.save)
            })
        }
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            do {
                let image = try ManagedFeedImage.first(with: url, in: context)
                completion(.success(image?.data))
            } catch { }
        }
    }
    
}
