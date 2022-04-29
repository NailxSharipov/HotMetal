//
//  Size.swift
//  ViewPort
//
//  Created by Nail Sharipov on 28.04.2022.
//

import CoreGraphics

struct Size: Equatable {

    static let zero = Size(width: 0, height: 0)
    
    let width: Float
    let height: Float
    
}

extension Size {

    init(size: CGSize) {
        self.init(
            width: Float(size.width),
            height: Float(size.height)
        )
    }
}

extension CGSize {
    
    init(size: Size) {
        self.init(
            width: CGFloat(size.width),
            height: CGFloat(size.height)
        )
    }
}
