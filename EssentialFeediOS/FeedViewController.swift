//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 29.10.2022.
//

import EssentialFeed
import UIKit

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageLoaderDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

public final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var imageLoader: FeedImageLoaderDataLoader?
    private var tableModel = [FeedImage]() {
        didSet { tableView.reloadData() }
    }
    private var tasks = [IndexPath: FeedImageDataLoaderTask]()
    
    public convenience init(loader: FeedLoader, imageLoader: FeedImageLoaderDataLoader?) {
        self.init()
        self.loader = loader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let feed):
                self.tableModel = feed
            case .failure(_):
                break
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = cellModel.location == nil
        cell.descriptionLabel.text = cellModel.description
        cell.locationLabel.text = cellModel.location
        cell.locationContainer.startShimmering()
        cell.feedImageView.image = nil
        cell.retryButton.isHidden = true
        tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.imageURL) { [weak cell] result in
            switch result {
            case .success(let data):
                let image = UIImage(data: data)
                cell?.feedImageView.image = image
            case .failure:
                cell?.retryButton.isHidden = false
            }
            cell?.locationContainer.stopShimmering()
        }
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
    
}
