//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Ahmed Elgendy on 17.11.2022.
//

import EssentialFeed

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
    return [FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())]
}
