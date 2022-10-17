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
    
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping DeletionCompletion) {
        insertionCompletions.append(completion)
        recievedMessages.append(.insertion(items, timestamp))
    }
    
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        recievedMessages.append(.retrieve)
    }
    
    func completeDeletion(withError error: Error?, index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsertion(withError error: Error?, index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func completeRetrieval(withError error: Error, index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
}
