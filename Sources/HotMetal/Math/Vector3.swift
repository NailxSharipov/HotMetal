//
//  Vector3.swift
//  HotMetal
//
//  Created by Nail Sharipov on 23.04.2022.
//

public typealias Vector3 = SIMD3<Float>

public extension Vector3 {
    
    static let up = Vector3(0, 1, 0)
    
    init(v: Vector4) {
        self.init(x: v.x, y: v.y, z: v.z)
    }
}
