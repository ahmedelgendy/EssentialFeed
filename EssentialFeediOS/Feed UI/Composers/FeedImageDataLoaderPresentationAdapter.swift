//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 5.11.2022.
//

import EssentialFeed

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let imageLoader: FeedImageLoaderDataLoader
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage

    var presenter: FeedImagePresenter<View, Image>?

    init(model: FeedImage, imageLoader: FeedImageLoaderDataLoader) {
        self.imageLoader = imageLoader
        self.model = model
    }

    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.presenter?.didFinishLoadingImageData(with: data, model: self.model)
            case .failure(let error):
                self.presenter?.didFinishLoadingImageData(with: error, model: self.model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
}
