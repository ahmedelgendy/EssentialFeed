//
//  FeedImageCell+Helpers.swift
//  EssentialFeediOSTests
//
//  Created by Ahmed Elgendy on 4.11.2022.
//

import Foundation
import EssentialFeediOS

extension FeedImageCell {
    
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
    
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return locationContainer.isShimmering
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var isShowingRetryButton: Bool {
        retryButton.isHidden == false
    }
    
    func simulateRetryButtonTapped() {
        retryButton.simulateButtonTapped()
    }
}
