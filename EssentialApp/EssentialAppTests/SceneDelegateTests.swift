//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Ahmed Elgendy on 1.12.2022.
//

import XCTest
@testable import EssentialApp
import EssentialFeediOS

class SceneDelegateTests: XCTestCase {
    
    func test_sceneWillConnectToSession_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController

        XCTAssertNotNil(rootNavigation)
        XCTAssertTrue(topController is FeedViewController)
    }
    
}
