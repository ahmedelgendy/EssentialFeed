//
//  SharedTestsHelper.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 19.10.2022.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 1)
}

func anyData() -> Data {
    return Data("any data".utf8)
}
