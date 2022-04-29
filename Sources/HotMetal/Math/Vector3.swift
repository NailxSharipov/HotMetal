//
//  Vector3.swift
//  HotMetal
//
//  Created by Nail Sharipov on 23.04.2022.
//

import CoreGraphics

public typealias Vector3 = SIMD3<Float>

public extension Vector3 {
    
    static let up = Vector3(0, 1, 0)
    
    init(v: Vector4) {
        self.init(x: v.x, y: v.y, z: v.z)
    }
}

@inlinable
public func +(left: Vector3, right: Vector3) -> Vector3 {
    Vector3(left.x + right.x, left.y + right.y, left.z + right.z)
}


public extension CGPoint {
    
    init(_ v: Vector3) {
        self.init(x: CGFloat(v.x), y: CGFloat(v.y))
    }
    
}
