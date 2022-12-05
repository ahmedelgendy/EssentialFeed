//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 5.11.2022.
//

import EssentialFeed
import EssentialFeediOS
import Combine

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private var cancellable: Cancellable?
    var presenter: FeedImagePresenter<View, Image>?

    init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.imageLoader = imageLoader
        self.model = model
    }

    func didRequestImage() {
        let model = model
        presenter?.didStartLoadingImageData(for: model)
        
        cancellable = imageLoader(model.imageURL)
            .dispatchOnMainThread()
            .sink { [weak self] completion in
            switch completion {
            case .failure(let error):
                self?.presenter?.didFinishLoadingImageData(with: error, model: model)
            case .finished:
                break
            }
        } receiveValue: { [weak self] data in
            self?.presenter?.didFinishLoadingImageData(with: data, model: model)
        }
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}
