//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 6.11.2022.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let shouldRetry: Bool
    public let isLoading: Bool

    public var hasLocation: Bool {
        location != nil
    }
}
