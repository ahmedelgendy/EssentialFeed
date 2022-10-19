//
//  FeedCachPolicy.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 19.10.2022.
//

import Foundation

final class FeedCachPolicy {
    private init() { }
    
    private static let calender = Calendar(identifier: .gregorian)
    private static var maxCacheAge: Int { return 7 }
    
    static func validate(_ timestamp: Date, against currentDate: Date) -> Bool {
        guard let maxDate = calender.date(byAdding: .day, value: maxCacheAge, to: timestamp) else {
            return false
        }
        return currentDate < maxDate
    }
}
