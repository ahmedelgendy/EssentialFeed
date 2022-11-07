//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 6.10.2022.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}
public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
