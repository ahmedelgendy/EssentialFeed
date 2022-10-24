//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 16.10.2022.
//

import Foundation

final public class LocalFeedLoader {
    
    private let feedStore: FeedStore
    private var currentDate: () -> Date

    public init(feedStore: FeedStore, currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
        self.feedStore = feedStore
    }
    
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        feedStore.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(.some(let cache)) where FeedCachPolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))
            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Result<Void, Error>

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult?) -> Void) {
        feedStore.deleteCachedFeed { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.cache(feed, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], completion: @escaping (SaveResult?) -> Void) {
        feedStore.insert(feed.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }

}

extension LocalFeedLoader {
    public func validateCache() {
        feedStore.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.feedStore.deleteCachedFeed { _ in }
            case let .success(.some(cache)) where !FeedCachPolicy.validate(cache.timestamp, against: self.currentDate()):
                self.feedStore.deleteCachedFeed { _ in }
            case .success: break
            }
        }

    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
    }
}


private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
    }
}
