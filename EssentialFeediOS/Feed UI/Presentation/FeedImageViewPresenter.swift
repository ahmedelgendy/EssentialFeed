//
//  FeedImageViewPresenter.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 2.11.2022.
//

import EssentialFeed

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let shouldRetry: Bool
    let isLoading: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}

protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    typealias Observer<T> = (T) -> ()
    private let imageTransformer: (Data) -> Image?
    private let view: View
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.imageTransformer = imageTransformer
        self.view = view
    }

    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            shouldRetry: false,
            isLoading: true
        ))
    }
    
    func didFinishLoadingImageData(with data: Data, model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: imageTransformer(data),
            shouldRetry: false,
            isLoading: false
        ))
    }
    
    func didFinishLoadingImageData(with error: Error, model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            shouldRetry: true,
            isLoading: false
        ))
    }
}
