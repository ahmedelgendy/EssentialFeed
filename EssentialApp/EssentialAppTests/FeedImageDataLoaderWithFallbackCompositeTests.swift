//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Ahmed Elgendy on 17.11.2022.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite {
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        
    }
}

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        _ = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

        var loadedURLs: [URL] {
            messages.map(\.url)
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url: url, completion: completion))
            return Task()
        }
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() {
                
            }
        }
    }
    
}
