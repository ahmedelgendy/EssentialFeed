//
//  UIImageView+Animation.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 4.11.2022.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        guard newImage != nil else { return }
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
