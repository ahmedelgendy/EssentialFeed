//
//  FeedLoadingViewModel.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 3.11.2022.
//

import Foundation

struct FeedLoadingViewModel {
    let isLoading: Bool
}

enum FeedErrorViewModel {
    case noError
    case error(message: String)
}
