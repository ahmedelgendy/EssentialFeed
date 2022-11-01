//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 29.10.2022.
//

import EssentialFeed
import UIKit

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    var tableModel = [FeedImageCellController](){
        didSet { tableView.reloadData() }
    }
    private var refreshController: FeedRefreshController?

    convenience init(refreshController: FeedRefreshController) {
        self.init()
        self.refreshController = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
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
        return tableModel[indexPath.row]
    }
    
    private func cancelImageDownloadingTask(at indexPath: IndexPath) {
        tableModel[indexPath.row].cancelTask()
    }
}
