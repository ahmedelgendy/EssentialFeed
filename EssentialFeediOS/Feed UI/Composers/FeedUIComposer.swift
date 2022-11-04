//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 1.11.2022.
//

import Foundation
import EssentialFeed
import UIKit

public final class FeedUIComposer {
    
    private init() { }
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageLoaderDataLoader) -> FeedViewController {
        let feedLoaderAdapter = FeedLoaderPresentationAdapter(loader: MainQueueDispatchDecorator(decoratee: feedLoader))
        let feedViewController = FeedViewController.instantiate(with: feedLoaderAdapter, title: FeedPresenter.title)
        let feedPresenter = FeedPresenter(
            loadingView: WeakRefProxy(feedViewController),
            feedView: FeedViewAdapter(controller: feedViewController, imageLoader: imageLoader)
        )
        feedLoaderAdapter.presenter = feedPresenter
        return feedViewController
    }

    
}

private extension FeedViewController {
    static func instantiate(with delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageLoaderDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageLoaderDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { image in
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
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let loader: FeedLoader
    var presenter: FeedPresenter?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        loader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
            case .failure(let error):
                self?.presenter?.didFinishLoading(with: error)
            }
        }
    }
}

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
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


final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }

        completion()
    }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}

final class WeakRefProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        object?.display(viewModel)
    }
}
