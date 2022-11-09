//
//  LoadImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 9.11.2022.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    func retrieve(dataForURL url: URL)
}

final class ImageDataLoader: FeedImageDataLoader {
    
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url)
        return Task()
    }
    
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
}

class LoadImageDataFromCacheUseCaseTests: XCTestCase {
    
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, spy) = makeSUT()
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, spy) = makeSUT()
        let url = anyURL()
        _ = sut.loadImageData(from: url, completion: { _ in })
        XCTAssertEqual(spy.messages, [.retrieve(dataFor: url)])
    }
    
    // MARK: Helpers
    
    class ImageDataStoreSpy: FeedImageDataStore {
        
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        private(set) var messages = [Message]()
        
        func retrieve(dataForURL url: URL) {
            messages.append(.retrieve(dataFor: url))
        }

    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageDataLoader, store: ImageDataStoreSpy) {
        let store = ImageDataStoreSpy()
        let sut = ImageDataLoader(store: store)
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return (sut: sut, store: store)
    }
}
