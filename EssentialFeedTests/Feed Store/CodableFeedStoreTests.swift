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
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(Cache.self, from: data)
            completion(.found(local: decoded.feedModels, timestamp: decoded.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.DeletionCompletion) {
        do {
            let codableFeedImages = feed.map(CodableFeedImage.init)
            let cache = Cache(feed: codableFeedImages, timestamp: timestamp)
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func delete(completion: @escaping FeedStore.DeletionCompletion) {
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
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
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    func test_retrieve_deliversEmptyItemsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
    }
    
    
    func test_retrieveTwice_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retriveAfterInsertingToEmptyCache_returnsInsertedValues() {
        let sut = makeSUT()
        let expectedFeed = uniqueImageFeed().local
        let currentDate = Date()
        insert((local: expectedFeed, timestamp: currentDate), to: sut)
        expect(sut, toRetrieve: .found(local: expectedFeed, timestamp: currentDate))
    }
    
    func test_retrive_hasNoSideEffectWhenCalledTwice() {
        let sut = makeSUT()
        let currentDate = Date()
        let expectedFeed = uniqueImageFeed().local
        insert((local: expectedFeed, timestamp: currentDate), to: sut)
        expect(sut, toRetrieveTwice: .found(local: expectedFeed, timestamp: currentDate))
    }
    
    func test_retrieve_deliverFailureOnRetrievalError() {
        let sut = makeSUT()
        try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectOnFailure() {
        let sut = makeSUT()
        try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let insertError = insert((local: feed, timestamp: Date()), to: sut)
        XCTAssertNil(insertError, "Expected feed to be inserted successfully")
        
        let lastInsertedFeed = uniqueImageFeed().local
        let lastInsertedDate = Date()
        let lastInsertError = insert((local: lastInsertedFeed, timestamp: Date()), to: sut)
        XCTAssertNil(lastInsertError, "Expected feed to be inserted successfully")
        
        expect(sut, toRetrieve: .found(local: lastInsertedFeed, timestamp: lastInsertedDate))
    }
    
    func test_insert_deliverErrorOnInsertionFailure() {
        let storeURL = URL(string: "https://invalid-url.com")
        let sut = makeSUT(storeURL: storeURL)
        let feed = uniqueImageFeed().local
        let insertError = insert((local: feed, timestamp: Date()), to: sut)
        XCTAssertNotNil(insertError, "Expected feed to be inserted to be failed")
    }
    
    func test_delete_clearPreviouslyInsertedCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let insertError = insert((local: feed, timestamp: Date()), to: sut)
        XCTAssertNil(insertError, "Expected feed to be inserted successfully")
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected feed to be deleted successfully")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionFailure() {
        let storeURL = URL(string: "https://invalid-url.com")
        let sut = makeSUT(storeURL: storeURL)
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected feed to deliver deletion error")
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    // MARK - Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL() )
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return sut
    }
    
    func deleteCache(from sut: CodableFeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var recievedError: Error?
        sut.delete() { error in
            recievedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return recievedError
    }
    
    @discardableResult
    private func insert(_ cache: (local: [LocalFeedImage], timestamp: Date), to sut: CodableFeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var recievedError: Error?
        sut.insert(cache.local, timestamp: cache.timestamp) { error in
            recievedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return recievedError
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { result in
            switch (result, expectedResult) {
            case let (.found(local, timestamp), .found(expectedLocal, expectedTimestamp)) :
                XCTAssertEqual(local, expectedLocal, file: file, line: line)
                XCTAssertEqual(timestamp, expectedTimestamp, file: file, line: line)
            case (.empty, .empty),
                (.failure, .failure):
                break
            default:
                XCTFail("Expected local feed but found \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
}
