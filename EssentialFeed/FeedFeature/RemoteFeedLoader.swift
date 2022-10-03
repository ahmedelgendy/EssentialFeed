//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 3.10.2022.
//

import Foundation

class RemoteFeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}
