//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 31.10.2022.
//

import Foundation

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

public protocol FeedImageDataLoaderTask {
    func cancel()
}
