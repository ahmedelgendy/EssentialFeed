//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 13.10.2022.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}


class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_failsOnWrongURL() {
        URLProtocolStub.startIntercepting()
        let client = URLSessionHTTPClient(session: .shared)
        let url = URL(string: "http://any-url.com")!
        let expectation = expectation(description: "block finished")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            expectation.fulfill()
        }
        
        client.get(from: url) { _ in }
        
        wait(for: [expectation], timeout: 1)
        URLProtocolStub.stopIntercepting()
    }
    
    func test_getFromUrl_failsOnRequestError() {
        URLProtocolStub.startIntercepting()
        
        let url = URL(string: "http://any-url.com")!
        let expectedError = NSError(domain: "any error", code: 1)
        
        URLProtocolStub.stub(url: url, error: expectedError, data: nil, response: nil)
        
        let client = URLSessionHTTPClient(session: .shared)

        let expectation = expectation(description: "data task finished loading")

        client.get(from: url) { result in
            switch result {
            case .success(_, _):
                XCTFail("expected error \(expectedError), found success instead")
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, expectedError.domain)
                XCTAssertEqual(error.code, expectedError.code)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        URLProtocolStub.stopIntercepting()
    }
    
    
    class URLProtocolStub: URLProtocol {
        
        struct Stub {
            let error: Error?
            let data: Data?
            let response: HTTPURLResponse?
        }
        
        static var stub: Stub?
        private static var observer: ((URLRequest) -> Void)?
        
        static func startIntercepting() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopIntercepting() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
        }
        
        static func observeRequests(_ observer: @escaping (URLRequest) -> Void) {
            URLProtocolStub.observer = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            observer?(request)
            return request
        }
        
        static func stub(url: URL, error: Error?, data: Data?, response: HTTPURLResponse?) {
            stub = Stub(error: error, data: data, response: response)
        }
        
        override func startLoading() {
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
    }

}
