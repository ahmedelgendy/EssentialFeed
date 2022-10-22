//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 22.10.2022.
//

import Foundation
import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
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
    func insert(_ cache: (local: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var recievedError: Error?
        sut.insert(cache.local, timestamp: cache.timestamp) { error in
            recievedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return recievedError
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
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
    
}
