//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 29.10.2022.
//

import EssentialFeed
import UIKit

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var imageLoader: FeedImageLoaderDataLoader?
    private var tableModel = [FeedImage]() {
        didSet { tableView.reloadData() }
    }
    private var feedImageViewControllers = [IndexPath: FeedImageCellController]()

    private var refreshController: FeedRefreshController?
    
    public convenience init(loader: FeedLoader, imageLoader: FeedImageLoaderDataLoader) {
        self.init()
        self.refreshController = FeedRefreshController(loader: loader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        refreshController?.onRefresh = { [weak self] feed in
            self?.tableModel = feed
        }
        refreshControl = refreshController?.view
        refreshController?.refresh()
        
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellConroller(at: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelImageDownloadingTask(at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellConroller(at: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cancelImageDownloadingTask(at: indexPath)
        }
    }
    
    private func cellConroller(at indexPath: IndexPath) -> FeedImageCellController {
        let cellModel = tableModel[indexPath.row]
        let controller = FeedImageCellController(model: cellModel, imageLoader: imageLoader!)
        feedImageViewControllers[indexPath] = controller
        return controller
    }
    
    private func cancelImageDownloadingTask(at indexPath: IndexPath) {
        feedImageViewControllers[indexPath] = nil
    }
}
