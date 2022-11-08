//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 8.11.2022.
//

import EssentialFeed

class HTTPClientSpy: HTTPClient {
    
    private struct TaskSpy: HTTPClientTask {
        let completion: () -> Void
        func cancel() {
            completion()
        }
    }
    var messages: [(url: URL, completion: (HTTPClient.Result) -> Void)] = []
    var requestedURLs: [URL] {
        messages.map(\.url)
    }
    var cancelledURLs = [URL]()
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((url, completion))
        return TaskSpy { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func complete(withError error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode statusCode: Int, data: Data = Data(), at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success((data, response)))
    }
}
