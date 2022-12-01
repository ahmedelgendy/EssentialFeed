//
//  UIRefreshControl+SimulatePulling.swift
//  EssentialFeediOSTests
//
//  Created by Ahmed Elgendy on 4.11.2022.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
