//
//  FeedStoreTestsHelper.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 19.10.2022.
//

import Foundation
import EssentialFeed

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let feed = [uniqueItem(), uniqueItem()]
    let local = feed.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
    return (models: feed, local: local)
}

func uniqueImage() -> FeedImage {
    uniqueItem()
}

func uniqueItem() -> FeedImage {
    FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())
}

extension Date {
    
    private var maxAge: Int { return 7 }

    func minusFeedCacheMaxAge() -> Date {
        self.adding(days: -maxAge)
    }

    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}
  
extension Date {
    func adding(seconds: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .second, value: seconds, to: self)!
    }
}
