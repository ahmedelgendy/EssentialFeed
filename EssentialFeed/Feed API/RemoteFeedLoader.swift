//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 3.10.2022.
//

import Foundation

public class RemoteFeedLoader: FeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping ((LoadFeedResult) -> Void)) {
        client.get(from: url) { [weak self] result in
            guard let _ = self else { return }
            switch result {
            case let .success(data, response):
                completion(FeedItemsMapper.map(data: data, response: response))
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        }
    }
    
}
