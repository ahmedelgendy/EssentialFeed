//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 6.11.2022.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

public class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?

    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            shouldRetry: false,
            isLoading: true
        ))
    }
    
    public func didFinishLoadingImageData(with data: Data, model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: imageTransformer(data),
            shouldRetry: false,
            isLoading: false
        ))
    }
    
    public func didFinishLoadingImageData(with error: Error, model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            shouldRetry: true,
            isLoading: false
        ))
    }
}
