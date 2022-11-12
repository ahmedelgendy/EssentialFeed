//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 14.10.2022.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    private struct InvalidDataError: Error { }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(InvalidDataError()))
            }
        }
        task.resume()
        return URLSessionWrapper(wrapped: task)
    }
    
    struct URLSessionWrapper: HTTPClientTask {
        var wrapped: URLSessionDataTask
        func cancel() {
            wrapped.cancel()
        }
    }
}
