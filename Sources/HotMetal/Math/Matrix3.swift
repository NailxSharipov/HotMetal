//
//  Matrix3.swift
//  HotMetal
//
//  Created by Nail Sharipov on 21.04.2022.
//

import simd

public typealias Matrix3 = float3x3

public extension Matrix3 {

    static let identity = float3x3(Float(1.0))
    
    @inlinable
    static func rotate(angle: Float) -> Matrix3 {
        let cs = cos(angle)
        let sn = sin(angle)
        
        return Matrix3(columns:(
            Vector3(cs, -sn,  0),
            Vector3(sn,  cs,  0),
            Vector3( 0,   0,  1)
        ))
    }
    
    @inlinable
    static func translate(x: Float, y: Float) -> Matrix3 {
        Matrix3(columns:(
            Vector3( 1,  0,  x),
            Vector3( 0,  1,  y),
            Vector3( 0,  0,  1)
        ))
    }
    
    @inlinable
    static func scale(sx: Float, sy: Float) -> Matrix3 {
        Matrix3(columns:(
            Vector3(sx,  0,   0),
            Vector3( 0,  sy,  0),
            Vector3( 0,   0,  1)
        ))
    }

}

func *(left: Matrix3, right: Vector3) -> Vector3 {
    matrix_multiply(left, right)
}
