//
//  Vector4.swift
//  HotMetal
//
//  Created by Nail Sharipov on 12.04.2022.
//

import CoreGraphics

public typealias Vector4 = SIMD4<Float>

public extension Vector4 {
    
    init(v: Vector3, w: Float) {
        self.init(x: v.x, y: v.y, z: v.z, w: w)
    }

    init(_ color: CGColor) {
        guard let c = color.components else {
            self.init(x: 1, y: 1, z: 1, w: 1)
            return
        }
        
        if c.count == 2 {
            let rgb = Float(c[0])
            let a = Float(c[1])
            self.init(x: rgb, y: rgb, z: rgb, w: a)
        } else {
            let r = Float(c[0])
            let g = Float(c[1])
            let b = Float(c[2])
            let a = Float(c[3])
            self.init(x: r, y: g, z: b, w: a)
        }
    }

}
