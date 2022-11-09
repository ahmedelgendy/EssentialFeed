//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 9.11.2022.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case retrieve(dataFor: URL)
        case insert(data: Data, for: URL)
    }
    private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private var insertionCompletions = [(FeedImageDataStore.InsertionResult) -> Void]()

    private(set) var messages = [Message]()
    
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
        messages.append(.retrieve(dataFor: url))
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
    
    func completeRetrieval(withError error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        messages.append(.insert(data: data, for: url))
        insertionCompletions.append(completion)
    }
    
}
