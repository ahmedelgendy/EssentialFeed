//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 5.11.2022.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { image in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefProxy<FeedImageCellController>, UIImage>(
                model: image,
                imageLoader: imageLoader
            )
            let view = FeedImageCellController(delegate: adapter)
            adapter.presenter = FeedImagePresenter<WeakRefProxy<FeedImageCellController>, UIImage>(
                view: WeakRefProxy(view),
                imageTransformer: UIImage.init
            )
            return view
        })
    }
}
