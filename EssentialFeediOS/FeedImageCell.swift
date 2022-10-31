//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 30.10.2022.
//

import UIKit

public class FeedImageCell: UITableViewCell {
    public let locationContainer = UIView()
    public let descriptionLabel = UILabel()
    public let locationLabel = UILabel()
    public let feedImageView = UIImageView()
    public lazy var retryButton = {
       let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> ())?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
