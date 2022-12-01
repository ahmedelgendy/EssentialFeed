//
//  HTTPClientStub.swift
//  EssentialAppTests
//
//  Created by Ahmed Elgendy on 1.12.2022.
//

import EssentialFeed

class HTTPClientStub: HTTPClient {
    
    struct Task: HTTPClientTask {
        func cancel() { }
    }
    
    private let stub: (URL) -> HTTPClient.Result
    
    init(stub: @escaping (URL) -> HTTPClient.Result) {
        self.stub = stub
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completion(stub(url))
        return Task()
    }
}

extension HTTPClientStub {
    
    static var offline: HTTPClientStub {
        HTTPClientStub { _ in return .failure(anyNSError()) }
    }
    
    static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
        HTTPClientStub { url in return .success(stub(url))}
    }
    
}
