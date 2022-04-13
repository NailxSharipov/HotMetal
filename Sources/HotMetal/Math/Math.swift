//
//  Math.swift
//  
//
//  Created by Nail Sharipov on 12.04.2022.
//

import simd
import GLKit

public enum Math {

    public static func toRadians(_ degrees: Float) -> Float {
        degrees * .pi / 180.0
    }

    public static func toDegrees(_ radians: Float) -> Float {
        radians * 180.0 / .pi
    }

  /**
   Returns a matrix that converts points from world space to eye space
   */
    public static func makeLook(
        eye: Vector3,
        look: Vector3,
        up: Vector3
    ) -> Matrix4 {
        
        let target = eye + look
        let glLook = GLKMatrix4MakeLookAt(
            eye.x,
            eye.y,
            eye.z,
            target.x,
            target.y,
            target.z,
            up.x,
            up.y,
            up.z
        )
        
        return GLKMatrix4.toFloat4x4(matrix: glLook)
    }

    /// Returns a perspective projection matrix, to convert world space to Metal clip space
    public static func makePerspective(
        fovyDegrees fovy: Float,
        aspectRatio: Float,
        nearZ: Float,
        farZ: Float
    ) -> Matrix4 {

        let persp = GLKMatrix4MakePerspective(
            Math.toRadians(fovy),
            aspectRatio,
            nearZ,
            farZ
        )
        
        return GLKMatrix4.toFloat4x4(matrix: persp)
    }
}

extension GLKMatrix4 {
    
    static func toFloat4x4(matrix: GLKMatrix4) -> float4x4 {
        float4x4(
            Vector4(matrix.m00, matrix.m01, matrix.m02, matrix.m03),
            Vector4(matrix.m10, matrix.m11, matrix.m12, matrix.m13),
            Vector4(matrix.m20, matrix.m21, matrix.m22, matrix.m23),
            Vector4(matrix.m30, matrix.m31, matrix.m32, matrix.m33)
        )
    }
}
