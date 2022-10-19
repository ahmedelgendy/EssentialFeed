//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 16.10.2022.
//

import Foundation

public enum LocalFeedResult {
    case empty
    case success([LocalFeedImage], Date)
    case failure(Error)
}

final public class LocalFeedLoader {
    
    private let calender = Calendar(identifier: .gregorian)
    private let feedStore: FeedStore
    private var currentDate: () -> Date
    private var maxCacheAge: Int { return 7 }

    public init(feedStore: FeedStore, currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
        self.feedStore = feedStore
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxDate = calender.date(byAdding: .day, value: maxCacheAge, to: timestamp) else {
            return false
        }
        return currentDate() < maxDate
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?

    public func save(_ items: [FeedItem], completion: @escaping (SaveResult?) -> Void) {
        feedStore.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, completion: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], completion: @escaping (SaveResult?) -> Void) {
        feedStore.insert(items.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }

}

extension LocalFeedLoader {
    public typealias LoadResult = LoadFeedResult

    public func load(completion: @escaping (LoadResult) -> Void) {
        feedStore.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let cachedItems, let timestamp) where self.validate(timestamp):
                completion(.success(cachedItems.toModels()))
            case .empty, .success:
                completion(.success([]))
            }
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
            case .success(_, let timestamp) where !self.validate(timestamp):
                self.feedStore.deleteCachedFeed { _ in }
            case .empty, .success: break
            }
        }

    }
}

private extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
    }
}


private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedItem] {
        map { FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
    }
}
