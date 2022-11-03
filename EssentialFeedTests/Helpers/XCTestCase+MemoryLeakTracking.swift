//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Ahmed Elgendy on 13.10.2022.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeak(instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in // important to
            XCTAssertNil(instance, "Potential Memory Leak", file: file, line: line)
        }
    }
}

