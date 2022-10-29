//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Ahmed Elgendy on 29.10.2022.
//

import XCTest

class FeedViewController {
    private let loader: FeedViewControllerTests.LoaderSpy
    init(loader: FeedViewControllerTests.LoaderSpy) {
        self.loader = loader
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesnotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    struct LoaderSpy {
        var loadCallCount = 0
    }

}
