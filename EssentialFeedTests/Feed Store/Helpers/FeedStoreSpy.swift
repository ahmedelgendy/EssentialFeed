//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 17.10.2022.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {

    var deletionCompletions: [DeletionCompletion] = []
    var insertionCompletions: [InsertionCompletion] = []
    var retrievalCompletions: [RetrievalCompletion] = []
    
    enum RecievedMessage: Equatable {
        case deletion
        case insertion([LocalFeedImage], Date)
        case retrieve
    }
    
    var recievedMessages: [RecievedMessage] = []
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        recievedMessages.append(.deletion)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping DeletionCompletion) {
        insertionCompletions.append(completion)
        recievedMessages.append(.insertion(feed, timestamp))
    }
    
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        recievedMessages.append(.retrieve)
    }
    
    func completeDeletion(withError error: Error, index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func completeInsertion(withError error: Error, index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func completeRetrieval(withError error: Error, index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyImages(index: Int = 0) {
        retrievalCompletions[index](.empty)
    }
    
    func completeRetrieval(with items: [LocalFeedImage], timestamp: Date, index: Int = 0) {
        retrievalCompletions[index](.found(local: items, timestamp: timestamp))
    }
}
