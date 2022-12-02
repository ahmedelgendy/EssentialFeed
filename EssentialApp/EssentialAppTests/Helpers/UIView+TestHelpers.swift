//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Ahmed Elgendy on 2.12.2022.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
