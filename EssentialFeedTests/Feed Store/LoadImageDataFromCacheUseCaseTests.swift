//
//  LoadImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 9.11.2022.
//

import XCTest


final class ImageDataLoader {
    private let store: Any
    init(store: Any) {
        self.store = store
    }
}

class LoadImageDataFromCacheUseCaseTests: XCTestCase {
    
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, spy) = makeSUT()
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    // MARK: Helpers
    
    private class ImageDataStoreSpy {
        
        enum Message {
            
        }
        
        private(set) var messages = [Message]()
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageDataLoader, store: ImageDataStoreSpy) {
        let store = ImageDataStoreSpy()
        let sut = ImageDataLoader(store: store)
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return (sut: sut, store: store)
    }
}
