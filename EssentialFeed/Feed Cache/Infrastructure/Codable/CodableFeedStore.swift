//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 21.10.2022.
//

import Foundation

public final class CodableFeedStore: FeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var feedModels: [LocalFeedImage] {
            feed.map { $0.model }
        }
    }
    
    private struct CodableFeedImage: Equatable, Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let imageURL: URL
        
        init(_ localFeedImage: LocalFeedImage) {
            self.id = localFeedImage.id
            self.description = localFeedImage.description
            self.location = localFeedImage.location
            self.imageURL = localFeedImage.imageURL
        }
        
        var model: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, imageURL: imageURL)
        }
    }
    
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.none))
            }
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(Cache.self, from: data)
                completion(.success((feed: decoded.feedModels, timestamp: decoded.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping DeletionCompletion) {
        let storeURL = storeURL
        queue.async(flags: .barrier) {
            do {
                let codableFeedImages = feed.map(CodableFeedImage.init)
                let cache = Cache(feed: codableFeedImages, timestamp: timestamp)
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(.success(()))
            }
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
