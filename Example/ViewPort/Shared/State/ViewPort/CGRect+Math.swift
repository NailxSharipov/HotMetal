//
//  CGRect+Transformation.swift
//  ViewPort
//
//  Created by Nail Sharipov on 25.04.2022.
//

import CoreGraphics
import HotMetal
import simd

extension CGRect {

    @inline(__always)
    var topLeft: CGPoint {
        origin
    }
    
    @inline(__always)
    var bottomLeft: CGPoint {
        CGPoint(x: topLeft.x, y: topLeft.y + height)
    }
    
    @inline(__always)
    var topRight: CGPoint {
        CGPoint(x: topLeft.x + width, y: topLeft.y)
    }
    
    @inline(__always)
    var bottomRight: CGPoint {
        CGPoint(x: topLeft.x + width, y: topLeft.y + height)
    }
    
    @inline(__always)
    var center: Vector2 {
        let x = midX
        let y = midY
        return Vector2(Float(x), Float(y))
    }
    
    var vectors: [Vector2] {
        [
            Vector2(bottomLeft),
            Vector2(topLeft),
            Vector2(topRight),
            Vector2(bottomRight)
        ]
    }
    
    @inline(__always)
    func translate(size: CGSize) -> CGRect {
        return CGRect(
            x: origin.x + size.width,
            y: origin.y,// + size.height,
            width: width,
            height: height
        )
    }

    @inline(__always)
    func transform(matrix: float3x3) -> [CGPoint] {
        self.vectors.map({ CGPoint(simd_mul(matrix, Vector3($0.x, $0.y, 1))) })
    }
}
