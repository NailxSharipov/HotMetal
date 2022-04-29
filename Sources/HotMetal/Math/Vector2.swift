//
//  Vector2.swift
//  HotMetal
//
//  Created by Nail Sharipov on 23.04.2022.
//

import CoreGraphics

public typealias Vector2 = SIMD2<Float>

public extension Vector2 {
    
    init(_ v: Vector3) {
        self.init(x: v.x, y: v.y)
    }
    
    init(_ p: CGPoint) {
        self.init(x: Float(p.x), y: Float(p.y))
    }

    func sqrDistance(_ v: Vector2) -> Float {
        let dx = x - v.x
        let dy = y - v.y
        return dx * dx + dy * dy
    }
    
}

@inlinable
public func +(left: Vector2, right: Vector2) -> Vector2 {
    Vector2(left.x + right.x, left.y + right.y)
}

public extension CGPoint {
    
    init(_ v: Vector2) {
        self.init(x: CGFloat(v.x), y: CGFloat(v.y))
    }
    
}
