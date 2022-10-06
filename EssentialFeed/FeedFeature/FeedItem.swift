//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 2.10.2022.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let descriptin: String?
    let location: String?
    let imageURL: URL
}
