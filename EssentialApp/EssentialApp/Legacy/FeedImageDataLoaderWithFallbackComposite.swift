//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Ahmed Elgendy on 17.11.2022.
//

import EssentialFeed

public class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader
    
    public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = Task()
        task.wrapped = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        return task
    }
    
    private class Task: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        func cancel() {
            wrapped?.cancel()
        }
    }
}
