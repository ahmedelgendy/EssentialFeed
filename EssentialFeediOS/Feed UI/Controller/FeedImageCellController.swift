//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 1.11.2022.
//

import UIKit

final class FeedImageCellController {
    private let viewModel: FeedImageViewModel<UIImage>
    
    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    public func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImage()
        return cell
    }
    
    private func binded(_ cell: FeedImageCell) -> FeedImageCell {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.descriptionLabel.text = viewModel.description
        cell.locationLabel.text = viewModel.location
        cell.feedImageView.image = nil
        
        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            cell?.locationContainer.isShimmering = isLoading
        }
        viewModel.onImageLoad = { [weak cell] in
            cell?.feedImageView.image = $0
        }
        viewModel.onShouldRetryImageLoadStateChanged = { [weak cell] shouldRetry in
            cell?.retryButton.isHidden = !shouldRetry
        }
        cell.onRetry = viewModel.loadImage
        return cell
    }
    
    func preload() {
        viewModel.loadImage()
    }
    
    func cancelTask() {
        viewModel.cancelImageLoading()
    }
    
}
