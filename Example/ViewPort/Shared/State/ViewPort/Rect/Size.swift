//
//  Size.swift
//  ViewPort
//
//  Created by Nail Sharipov on 28.04.2022.
//

import CoreGraphics
import HotMetal

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
    
    init(vector: Vector2) {
        self.init(width: vector.x, height: vector.y)
    }
    
    @inline(__always)
    func scale(_ scale: Float) -> Size {
        Size(
            width: width * scale,
            height: height * scale
        )
    }
    
    static func +(left: Size, right: Size) -> Size {
        Size(width: left.width + right.width, height: left.height + right.height)
    }
    
    static func -(left: Size, right: Size) -> Size {
        Size(width: left.width - right.width, height: left.height - right.height)
    }
    
    static func *(left: Float, right: Size) -> Size {
        Size(width: left * right.width, height: left * right.height)
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

extension Vector2 {

    init(size: Size) {
        self.init(x: size.width, y: size.height)
    }
    
    static func +(left: Vector2, right: Size) -> Vector2 {
        left + Vector2(size: right)
    }

    static func +(left: Size, right: Vector2) -> Vector2 {
        right + Vector2(size: left)
    }
}
