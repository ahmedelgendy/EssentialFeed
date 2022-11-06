//
//  FeedErrorViewModel.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 6.11.2022.
//

import Foundation

public struct FeedErrorViewModel {
    public var message: String?
    public static var noError: FeedErrorViewModel = {
        FeedErrorViewModel(message: nil)
    }()
    public static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
