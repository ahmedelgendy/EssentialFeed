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
    
    struct InvalidDataError: Error { }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(InvalidDataError()))
            }
        }.resume()
    }
}


class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startIntercepting()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopIntercepting()
    }
    
    func test_getFromURL_failsOnWrongURL() {
        let sut = makeSUT()
        let url = anyURL()
        let exp = expectation(description: "Wait for request")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        sut.get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_getFromUrl_failsOnRequestError() {
        let url = anyURL()
        let expectedError = anyNSError()
        
        URLProtocolStub.stub(url: url, error: expectedError, data: nil, response: nil)
        
        let sut = makeSUT()

        let exp = expectation(description: "data task finished loading")

        sut.get(from: url) { result in
            switch result {
            case .success(_, _):
                XCTFail("expected error \(expectedError), found success instead")
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, expectedError.domain)
                XCTAssertEqual(error.code, expectedError.code)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_getFromUrl_failsOnAllInvalidCases() {
        XCTAssertNotNil(resultError(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultError(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultError(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultError(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultError(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromUrl_succeedOnHTTPResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        let result = resultValuesFor(data: data, response: response , error: nil)
        XCTAssertEqual(result?.data, data)
        XCTAssertEqual(result?.response.url, response.url)
        XCTAssertEqual(result?.response.statusCode, response.statusCode)
    }
    
    func test_getFromUrl_deliversEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        let result = resultValuesFor(data: nil, response: response , error: nil)
        XCTAssertEqual(result?.data, Data())
        XCTAssertEqual(result?.response.url, response.url)
        XCTAssertEqual(result?.response.statusCode, response.statusCode)
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error)
        switch result {
        case let .success(recievedData, recievedResponse):
            return (data: recievedData, response: recievedResponse)
        case .failure:
            XCTFail("Expected Success, found \(result) instead")
            return nil
        }
    }
    
    private func resultError(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error)
        switch result {
        case .success:
            XCTFail("Expected failure, found \(result) instead", file: file, line: line)
            return nil
        case .failure(let error):
            return error
        }
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
        let url = anyURL()
        let sut = makeSUT()
        let exp = expectation(description: "Wait response")

        URLProtocolStub.stub(url: url, error: error, data: data, response: response)
        
        var returnedResult: HTTPClientResult!
        sut.get(from: url) { result in
            returnedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        return returnedResult
    }
    
    private func makeSUT() -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient(session: .shared)
        trackForMemoryLeak(instance: sut, file: #filePath, line: #line)
        return sut
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse()
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse()
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    class URLProtocolStub: URLProtocol {
        
        struct Stub {
            let error: Error?
            let data: Data?
            let response: URLResponse?
        }
        
        static var stub: Stub?
        private static var observer: ((URLRequest) -> Void)?
        
        static func startIntercepting() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopIntercepting() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            observer = nil
        }
        
        static func observeRequests(_ observer: @escaping (URLRequest) -> Void) {
            URLProtocolStub.observer = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            observer?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        static func stub(url: URL, error: Error?, data: Data?, response: URLResponse?) {
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
