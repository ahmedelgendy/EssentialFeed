//
//  UITableView+Dequeuing.swift
//  EssentialFeediOS
//
//  Created by Ahmed Elgendy on 4.11.2022.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
