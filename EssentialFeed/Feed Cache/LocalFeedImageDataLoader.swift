//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 9.11.2022.
//

import Foundation

public final class LocalFeedImageDataLoader: FeedImageDataLoader {
        
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    
}

// MARK: - Retrieval
extension LocalFeedImageDataLoader {
    public typealias LoadResult = FeedImageDataLoader.Result
    public func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> FeedImageDataLoaderTask {
        let task = Task(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(LoadError.notFound)
                }
            )
        }
        return task
    }
    
    private class Task: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            completion = nil
        }
    }
    
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
}

// MARK: - Insertion
extension LocalFeedImageDataLoader {
    public typealias SaveResult = Result<Void, Swift.Error>
    
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { [weak self] result in
            guard self != nil else { return }
            completion(result.mapError { _ in SaveError.failed })
        }
    }
    
    public enum SaveError: Error {
        case failed
    }
}
