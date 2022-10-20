//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 19.10.2022.
//

import XCTest
@testable import EssentialFeed

class CodableFeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var feedModels: [LocalFeedImage] {
            feed.map { $0.model }
        }
    }
    
    private struct CodableFeedImage: Equatable, Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let imageURL: URL
        
        init(_ localFeedImage: LocalFeedImage) {
            self.id = localFeedImage.id
            self.description = localFeedImage.description
            self.location = localFeedImage.location
            self.imageURL = localFeedImage.imageURL
        }
        
        var model: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, imageURL: imageURL)
        }
    }

    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let decoded = try! decoder.decode(Cache.self, from: data)
        completion(.found(decoded.feedModels, decoded.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.DeletionCompletion) {
        let codableFeedImages = feed.map { CodableFeedImage($0) }
        let cache = Cache(feed: codableFeedImages, timestamp: timestamp)
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        clearStoreCache()
    }
    
    override func tearDown() {
        super.tearDown()
        clearStoreCache()
    }
    
    func clearStoreCache() {
        try? FileManager.default.removeItem(at: storeURL())
    }
    
    func test_retrieve_deliversEmptyItemsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case .empty: break
                
            default:
                XCTFail("Expected empty, found \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    
    func test_retrieveTwice_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected empty result from two results but found \(firstResult), \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_retriveAfterInsertingToEmptyCache_returnsInsertedValues() {
        let sut = makeSUT()
        let expectedFeed = uniqueImageFeed().local
        let currentDate = Date()
        let exp = expectation(description: "Wait for cache retrieval")
        sut.insert(expectedFeed, timestamp: currentDate) { error in
            if error == nil {
                sut.retrieve { result in
                    switch result {
                    case let .found(feed, timstamp):
                        XCTAssertEqual(feed, expectedFeed)
                        XCTAssertEqual(currentDate, timstamp)
                    default:
                        XCTFail("Expected feed but found \(result) instead")
                    }
                    exp.fulfill()
                }
            }
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_retriveTwiceAfterInsertingToEmptyCache_returnsInsertedValues() {
        let sut = makeSUT()
        let currentDate = Date()
        let expectedFeed = [LocalFeedImage]()
        let exp = expectation(description: "Wait for cache retrieval")
        sut.insert(expectedFeed, timestamp: currentDate) { error in
            if error == nil {
                sut.retrieve { firstResult in
                    sut.retrieve { secondResult in
                        switch (firstResult, secondResult) {
                        case let (.found(firstFeed, firstTimstamp), .found(secondFeed, secondTimstamp)):
                            XCTAssertEqual(firstFeed, expectedFeed)
                            XCTAssertEqual(secondFeed, expectedFeed)
                            XCTAssertEqual(currentDate, firstTimstamp)
                            XCTAssertEqual(currentDate, secondTimstamp)
                        default:
                            XCTFail("Expected same feed results but found \(firstResult), \(secondResult) instead")
                        }
                        exp.fulfill()
                    }
                }
            }
        }
        wait(for: [exp], timeout: 1)
    }
    
    // MARK - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL())
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return sut
    }
    
    private func storeURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
}
