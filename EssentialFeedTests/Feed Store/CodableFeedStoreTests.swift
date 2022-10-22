//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 19.10.2022.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    
    override func setUp() {
        super.setUp()
        clearStoreCache()
    }
    
    override func tearDown() {
        super.tearDown()
        clearStoreCache()
    }
    
    private func clearStoreCache() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
    }
    
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let expectedFeed = uniqueImageFeed().local
        let currentDate = Date()
        insert((local: expectedFeed, timestamp: currentDate), to: sut)
        expect(sut, toRetrieve: .found(local: expectedFeed, timestamp: currentDate))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let currentDate = Date()
        let expectedFeed = uniqueImageFeed().local
        insert((local: expectedFeed, timestamp: currentDate), to: sut)
        expect(sut, toRetrieveTwice: .found(local: expectedFeed, timestamp: currentDate))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let sut = makeSUT()
        try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
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
        let lastInsertError = insert((local: lastInsertedFeed, timestamp: lastInsertedDate), to: sut)
        XCTAssertNil(lastInsertError, "Expected feed to be inserted successfully")
        
        expect(sut, toRetrieve: .found(local: lastInsertedFeed, timestamp: lastInsertedDate))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let insertError = insert((local: feed, timestamp: Date()), to: sut)
        XCTAssertNil(insertError, "Expected feed to be inserted successfully")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(insertionError, "Expected to override cache successfully")
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let storeURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: storeURL)
        let feed = uniqueImageFeed().local
        let insertError = insert((local: feed, timestamp: Date()), to: sut)
        XCTAssertNotNil(insertError, "Expected feed to be inserted to be failed")
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let storeURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: storeURL)
        let feed = uniqueImageFeed().local
        insert((local: feed, timestamp: Date()), to: sut)
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let insertError = insert((local: feed, timestamp: Date()), to: sut)
        XCTAssertNil(insertError, "Expected feed to be inserted successfully")
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected feed to be deleted successfully")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        insert((local: feed, timestamp: Date()), to: sut)
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected feed to be deleted successfully")
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected feed to be deleted successfully")
    }

    func test_delete_deliversErrorOnDeletionError() {
        let sut = makeSUT(storeURL: homeDirectoryURL())
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected feed to deliver deletion error")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected feed to be deleted successfully")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let sut = makeSUT(storeURL: homeDirectoryURL())
        deleteCache(from: sut)
        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        var expectations = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1 completion")
        sut.insert(feed, timestamp: Date()) { _ in
            expectations.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2 completion")
        sut.deleteCachedFeed { _ in
            expectations.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3 completion")
        sut.retrieve { _ in
            expectations.append(op3)
            op3.fulfill()
        }
        
        wait(for: [op1, op2, op3], timeout: 5)
        
        XCTAssertEqual(expectations, [op1, op2, op3])
    }
    
    // MARK - Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL() )
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var recievedError: Error?
        sut.deleteCachedFeed() { error in
            recievedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return recievedError
    }
    
    @discardableResult
    private func insert(_ cache: (local: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var recievedError: Error?
        sut.insert(cache.local, timestamp: cache.timestamp) { error in
            recievedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return recievedError
    }
    
    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
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
    
    /// We don't have permission to delete home directory for current user
    private func homeDirectoryURL() -> URL {
        return FileManager.default.homeDirectoryForCurrentUser
    }
    
}
