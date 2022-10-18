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
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    private var maxCacheAge = 7
    private let calender = Calendar(identifier: .gregorian)
    private let feedStore: FeedStore
    private var currentDate: () -> Date
    
    public init(feedStore: FeedStore, currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
        self.feedStore = feedStore
    }
    
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
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        feedStore.retrieve { [unowned self] result in
            switch result {
            case .failure(let error):
                feedStore.deleteCachedFeed { _ in }
                completion(.failure(error))
            case .success(let cachedItems, let timestamp) where self.validate(timestamp):
                completion(.success(cachedItems.toModels()))
            case .empty, .success:
                completion(.success([]))
            }
        }
    }
    
    private func cache(_ items: [FeedItem], completion: @escaping (SaveResult?) -> Void) {
        feedStore.insert(items.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }

    private func validate(_ timestamp: Date) -> Bool {
        guard let maxDate = calender.date(byAdding: .day, value: maxCacheAge, to: timestamp) else { return false }
        return currentDate() < maxDate
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
