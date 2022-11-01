//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 1.11.2022.
//

import UIKit
import EssentialFeed

final class FeedImageCellController {
    private let cellModel: FeedImage
    private let imageLoader: FeedImageLoaderDataLoader
    private var task: FeedImageDataLoaderTask?
    
    init(model: FeedImage, imageLoader: FeedImageLoaderDataLoader) {
        self.cellModel = model
        self.imageLoader = imageLoader
    }
    
    public func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = cellModel.location == nil
        cell.descriptionLabel.text = cellModel.description
        cell.locationLabel.text = cellModel.location
        cell.locationContainer.startShimmering()
        cell.feedImageView.image = nil
        cell.retryButton.isHidden = true
        
        let loadImage = { [weak cell, weak self] in
            guard let self = self else { return }
            self.task = self.imageLoader.loadImageData(from: self.cellModel.imageURL) { [weak cell] result in
                switch result {
                case .success(let data):
                    let image = UIImage(data: data)
                    cell?.feedImageView.image = image
                case .failure:
                    cell?.retryButton.isHidden = false
                }
                cell?.locationContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    func preload() {
        task = imageLoader.loadImageData(from: cellModel.imageURL) { _ in }
    }
    
    func cancelTask() {
        task?.cancel()
    }
    
}
