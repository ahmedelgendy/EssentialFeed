//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Ahmed Elgendy on 29.10.2022.
//

import XCTest
import UIKit
import EssentialFeed

class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        refreshControl?.beginRefreshing()
        load()
    }
    
    @objc private func load() {
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (controller, loader) = makeSUT()
        controller.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_pullToRefersh_loadsFeed() {
        let (controller, loader) = makeSUT()
        controller.loadViewIfNeeded()
        controller.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        controller.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 3)
        
        controller.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 4)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (controller, _) = makeSUT()
        controller.loadViewIfNeeded()
        XCTAssertEqual(controller.refreshControl?.isRefreshing, true)
    }
    
    func test_viewDidLoad_hideLoadingIndicatorOnLoaderCompletion() {
        let (controller, loader) = makeSUT()
        controller.loadViewIfNeeded()
        loader.completeFeedLoading()
        XCTAssertEqual(controller.refreshControl?.isRefreshing, false)
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let controller = FeedViewController(loader: loader)
        trackForMemoryLeak(instance: loader, file: file, line: line)
        trackForMemoryLeak(instance: controller, file: file, line: line)
        return (controller, loader)
    }
    
    class LoaderSpy: FeedLoader {
        var loadCallCount = 0
        
        private var loadingCompletions: [(FeedLoader.Result) -> Void] = []
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadingCompletions.append(completion)
            loadCallCount += 1
        }
        
        func completeFeedLoading(at index: Int = 0) {
            loadingCompletions[index](.success([]))
        }
    }

}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
