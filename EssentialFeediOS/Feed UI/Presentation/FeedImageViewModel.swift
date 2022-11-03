//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 2.11.2022.
//

import EssentialFeed

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> ()
    private let model: FeedImage
    private let imageLoader: FeedImageLoaderDataLoader
    private let imageTransformer: (Data) -> Image?
    private var task: FeedImageDataLoaderTask?

    var onImageLoad: Observer<Image?>?
    var onShouldRetryImageLoadStateChanged: Observer<Bool>?
    var onImageLoadingStateChange: Observer<Bool>?
    
    init(model: FeedImage, imageLoader: FeedImageLoaderDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    var description: String? {
        model.description
    }
    var location: String? {
        model.location
    }
    var hasLocation: Bool {
        location != nil
    }
    var imageURL: URL {
        model.imageURL
    }
    
    func loadImage() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChanged?(false)
        task = imageLoader.loadImageData(from: self.model.imageURL) { [weak self] result in
            self?.handleLoadImageDataResult(result)
        }
    }
    
    private func handleLoadImageDataResult(_ result: Result<Data, Error>) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChanged?(true)
        }
        onImageLoadingStateChange?(false)
    }
    
    func cancelImageLoading() {
        task?.cancel()
    }
}
