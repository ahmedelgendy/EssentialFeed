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
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://google.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://google.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientSide() {
        let (sut, client) = makeSUT()
        expect(sut: sut, completeWith: failure(.connectivity)) {
            client.complete(withError: NSError(domain: "Error", code: 0))
        }
    }
    
    func test_load_deliversErrorOnNon200Status() {
        let (sut, client) = makeSUT()
        let samples = [192, 300, 400, 500].enumerated()
        samples.forEach { index, code in
            expect(sut: sut, completeWith: failure(.invalidData)) {
                let json = makeItems([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200WithInvalidJSON() {
        let (sut, client) = makeSUT()
        let data = Data("invalid json".utf8)
        expect(sut: sut, completeWith: failure(.invalidData)) {
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_deliversEmptyArrayOn200WithValidJSON() {
        let (sut, client) = makeSUT()
        expect(sut: sut, completeWith: .success([])) {
            let json = makeItems([])
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    func test_load_deliversItemsOn200WithValidJSONItems() {
        let (sut, client) = makeSUT()
        let item1 = makeItem(id: UUID(), imageURL: URL(string: "https://anyimage.com")!)
        let item2 = makeItem(id: UUID(), description: "some des...", location: "loca", imageURL: URL(string: "https://anyimage2.com")!)
        
        expect(sut: sut, completeWith: .success([item1.model, item2.model])) {
            let data = makeItems([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_doesnotDeliverResultAfterSutInstanceDeallocation() {
        let url = URL(string: "https://anyimage2.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)

        var capturedResults = [RemoteFeedLoader.Result]()

        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItems([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    private func expect(sut: RemoteFeedLoader, completeWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = expectation(description: "Wait for load completion")
        sut.load { result in
            switch (result, expectedResult) {
            case (.success(let array), .success(let expectedArray)):
                XCTAssertEqual(array, expectedArray, file: file, line: line)
            case (.failure(let error as RemoteFeedLoader.Error), .failure(let expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result: \(expectedResult), got \(result) instead", file: file, line: line)
            }
            expectation.fulfill()
        }
        action()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func makeItems(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeItem(
        id: UUID, description: String? = nil, location: String? = nil, imageURL: URL
    ) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(
            id: id,
            description: description,
            location: location,
            imageURL: imageURL
        )
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString,
        ].reduce(into: [String: Any](), { (acc, e) in
            if let value = e.value {
                acc[e.key] = value
            }
        })
        return (item, json)
    }
    
    private func makeSUT(url: URL = URL(string: "https://google.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeak(instance: client)
        trackForMemoryLeak(instance: sut)
        return (sut, client)
    }
    
}
