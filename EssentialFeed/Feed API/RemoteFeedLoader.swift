//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 3.10.2022.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}


public class RemoteFeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping ((Result) -> Void)) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, urlResponse):
                if urlResponse.statusCode == 200,
                   let decodedData = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(decodedData.items))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure(_):
                completion(.failure(.connectivity))
            }
        }
    }
    
}

private struct Root: Decodable {
    let items: [FeedItem]
}
