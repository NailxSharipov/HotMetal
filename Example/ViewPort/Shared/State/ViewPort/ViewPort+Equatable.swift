//
//  ViewPort+Equatable.swift
//  ViewPort
//
//  Created by Nail Sharipov on 30.04.2022.
//

extension ViewPort: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.viewSize == rhs.viewSize && lhs.cropView == rhs.cropView && lhs.angle == rhs.angle
    }
}
