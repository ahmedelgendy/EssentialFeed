//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 7.11.2022.
//

import XCTest
import EssentialFeed

public protocol FeedImageDataLoaderTask {
    func cancel()
}

class RemoteFeedImageDataLoader {
    private let client: HTTPClient
   
    public enum Error: Swift.Error {
        case invalidData
    }

    init(client: HTTPClient) {
        self.client = client
    }
    
    @discardableResult
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
                guard self != nil else { return }
                switch result {
                case .success(let (data, response)):
                    if response.statusCode == 200, !data.isEmpty {
                        task.complete(with: .success(data))
                    } else {
                        task.complete(with: .failure(Error.invalidData))
                    }
                case .failure(let error):
                    task.complete(with: .failure(error))
                }
            }
        return task
    }
    
    private final class HTTPTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        var wrapped: HTTPClientTask?
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
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
            client.complete(withError: error)
        }
    }
    
    func test_loadImageData_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSut()
        let error = RemoteFeedImageDataLoader.Error.invalidData
        let statusCodes = [199, 201, 300, 400, 500]
        statusCodes.indices.forEach { index in
            expect(sut, toCompleteWith: .failure(error)) {
                client.complete(withStatusCode: statusCodes[index], data: anyData(), at: index)
            }
        }
    }
    
    func test_loadImageData_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSut()
        let error = RemoteFeedImageDataLoader.Error.invalidData
        expect(sut, toCompleteWith: .failure(error)) {
            client.complete(withStatusCode: 200, data: Data())
        }
    }
    
    func test_loadImageData_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSut()
        let data = anyData()
        expect(sut, toCompleteWith: .success(data)) {
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_loadImageData_doesNotDeliverResultAfterSUTDeinitalization() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        var results = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: anyURL()) { result in
            results.append(result)
        }
        sut = nil
        client.complete(withStatusCode: 200, data: anyData())
        XCTAssertTrue(results.isEmpty)
    }
    
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        let url = anyURL()
        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertEqual(client.cancelledURLs, [])
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url])
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        var results = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { result in
            results.append(result)
        }
        task.cancel()
        client.complete(withStatusCode: 404, data: anyData())
        client.complete(withStatusCode: 200, data: anyData())
        client.complete(withError: anyNSError())
        XCTAssertTrue(results.isEmpty)
    }
    
    // MARK: Helper
    
    private func makeSut(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
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
            case (.success(let response), (.success(let expectedResponse))):
                XCTAssertEqual(response, expectedResponse, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), found \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    
}
