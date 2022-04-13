//
//  Matrix.swift
//  
//
//  Created by Nail Sharipov on 12.04.2022.
//

import simd

public typealias Matrix4 = float4x4

extension Matrix4 {

    public static let identity = float4x4(Float(1.0))

    public init(quaternion: Quaternion) {
        self.init(quaternion)
        self[3][3] = 1
    }
    
    public static func scale(_ scaleX: Float, _ scaleY: Float, _ scaleZ: Float) -> Matrix4 {
        Matrix4(diagonal: [scaleX, scaleY, scaleZ, 1])
    }

    public static func rotate(radians: Float, axis: Vector3) -> Matrix4 {
        Matrix4(Quaternion(angle: radians, axis: axis))
    }

    public static func translate(_ translation: Vector3) -> Matrix4 {
        Matrix4(columns:(
            Vector4(1, 0, 0, 0),
            Vector4(0, 1, 0, 0),
            Vector4(0, 0, 1, 0),
            Vector4(translation, 1)
        ))
    }
}
