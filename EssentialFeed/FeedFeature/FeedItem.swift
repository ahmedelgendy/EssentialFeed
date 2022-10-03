//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 2.10.2022.
//

import Foundation

struct FeedItem {
    let id: UUID
    let descriptin: String?
    let location: String?
    let imageURL: URL
}

protocol HTTPClient {
    func get(from url: URL)
}
