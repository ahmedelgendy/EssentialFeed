//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 3.10.2022.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {

    }
    
    func test_init_doesntRequestDataFromURL() {
        let client = makeSUT().client
        XCTAssertTrue(client.urls.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://google.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        XCTAssertEqual(client.urls, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://google.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.urls, [url, url])
    }
    
    func test_load_deliversErrorOnClientSide() {
        let (sut, client) = makeSUT()
        
        var capturedError: RemoteFeedLoader.Error?
        
        sut.load { error in
            capturedError = error
        }
        
        client.complete(with: NSError(domain: "", code: 0))
        
        XCTAssertEqual(capturedError, .connectivity)
    }
    
    private func makeSUT(url: URL = URL(string: "https://google.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL, completion: (Error) -> Void)] = []
        
        var urls: [URL] {
            messages.map(\.url)
        }
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error)
        }
    }

}
