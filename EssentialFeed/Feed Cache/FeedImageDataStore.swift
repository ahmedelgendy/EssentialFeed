//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 9.11.2022.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
