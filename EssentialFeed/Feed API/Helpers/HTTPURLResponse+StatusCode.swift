//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 8.11.2022.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
