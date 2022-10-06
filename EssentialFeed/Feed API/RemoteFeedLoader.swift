//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 3.10.2022.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}


public class RemoteFeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping ((Error) -> Void)) {
        client.get(from: url) { error in
            completion(.connectivity)
        }
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
}
