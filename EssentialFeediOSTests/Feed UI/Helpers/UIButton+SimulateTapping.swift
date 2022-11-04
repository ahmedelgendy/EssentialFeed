//
//  UIButton+SimulateTapping.swift
//  EssentialFeediOSTests
//
//  Created by Ahmed Elgendy on 4.11.2022.
//

import UIKit

extension UIButton {
    func simulateButtonTapped() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
