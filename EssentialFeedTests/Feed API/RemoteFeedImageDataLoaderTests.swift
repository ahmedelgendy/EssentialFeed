//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 7.11.2022.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success((_, _)):
                break
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestImageLoading() {
        let (_, client) = makeSut()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageData_requestsDataFromURL() {
        let (sut, client) = makeSut()
        let url = anyURL()
        sut.loadImageData(from: url) { _ in
            
        }
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSut()
        let url = anyURL()
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataTwice_deliversErrorOnLoadingError() {
        let (sut, client) = makeSut()
        let error = anyNSError()
        expect(sut, toCompleteWith: .failure(error)) {
            client.completeWithError(error)
        }
    }
    
    // MARK: Helper
    
    private func makeSut(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: ClientSpy) {
        let client = ClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return (sut: sut, client: client)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action : () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "wait load image data completion")
        sut.loadImageData(from: url) { result in
            switch (result, expectedResult) {
            case (.failure(let error as NSError), (.failure(let expectedError as NSError))):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), found \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    
    private class ClientSpy: HTTPClient {
        
        var requestedURLs: [URL] {
            requests.map(\.url)
        }
        private var requests = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requests.append((url, completion))
        }
        
        func completeWithError(_ error: NSError, index: Int = 0) {
            requests[index].completion(.failure(error))
        }
        
    }
}