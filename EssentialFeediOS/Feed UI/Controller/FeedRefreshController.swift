//
//  FeedRefreshController.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 31.10.2022.
//

import UIKit
import EssentialFeed

class FeedRefreshController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    private let loader: FeedLoader
    var onRefresh: (([FeedImage]) -> ())?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    @objc func refresh() {
        view.beginRefreshing()
        loader.load { [weak self] result in
            guard let self = self else { return }
            if let feed = try? result.get() {
                self.onRefresh?(feed)
            }
            self.view.endRefreshing()
        }
    }
}
