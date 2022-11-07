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
        return HTTPTaskWrapper(task: client.get(from: url) { [weak self] result in
                guard self != nil else { return }
                switch result {
                case .success(let (data, response)):
                    if response.statusCode == 200, !data.isEmpty {
                        completion(.success(data))
                    } else {
                        completion(.failure(Error.invalidData))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }
    
    private struct HTTPTaskWrapper: FeedImageDataLoaderTask {
        let task: HTTPClientTask

        func cancel() {
            task.cancel()
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
    
    func test_loadImageData_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSut()
        let error = RemoteFeedImageDataLoader.Error.invalidData
        let statusCodes = [199, 201, 300, 400, 500]
        statusCodes.indices.forEach { index in
            expect(sut, toCompleteWith: .failure(error)) {
                client.completeWith(statusCode: statusCodes[index], data: anyData(), index: index)
            }
        }
    }
    
    func test_loadImageData_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSut()
        let error = RemoteFeedImageDataLoader.Error.invalidData
        expect(sut, toCompleteWith: .failure(error)) {
            client.completeWith(statusCode: 200, data: Data())
        }
    }
    
    func test_loadImageData_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSut()
        let data = anyData()
        expect(sut, toCompleteWith: .success(data)) {
            client.completeWith(statusCode: 200, data: data)
        }
    }
    
    func test_loadImageData_doesNotDeliverResultAfterSUTDeinitalization() {
        let client = ClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        var results = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: anyURL()) { result in
            results.append(result)
        }
        sut = nil
        client.completeWith(statusCode: 200, data: anyData())
        XCTAssertTrue(results.isEmpty)
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
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private class ClientSpy: HTTPClient {
        private struct Task: HTTPClientTask {
            var completion: () -> Void
            func cancel() {
                completion()
            }
        }
        var requestedURLs: [URL] {
            requests.map(\.url)
        }
        private var requests = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        var cancelledURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            requests.append((url, completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func completeWithError(_ error: NSError, index: Int = 0) {
            requests[index].completion(.failure(error))
        }
        
        func completeWith(statusCode: Int, data: Data, index: Int = 0) {
            let response = HTTPURLResponse(
                url: requests[index].url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            requests[index].completion(.success((data, response)))
        }
    }
}
