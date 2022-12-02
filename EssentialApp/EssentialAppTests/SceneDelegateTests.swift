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
    
    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let window = UIWindowSpy()
        let sut = SceneDelegate()
        sut.window = window
        
        sut.configureWindow()
        
        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1)
    }
    
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
    
    private class UIWindowSpy: UIWindow {
      var makeKeyAndVisibleCallCount = 0
      override func makeKeyAndVisible() {
        makeKeyAndVisibleCallCount = 1
      }
    }
    
}
