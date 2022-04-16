//
//  Math.swift
//  HotMetal
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

  
    /// Returns a matrix that converts points from world space to eye space
    /// - Parameters:
    ///   - eye: camera position
    ///   - look: look direction
    ///   - up: second vector, most of the time it's (0, 1, 0)
    /// - Returns: view matrix
    @inlinable
    public static func makeLook(
        eye: Vector3,
        look: Vector3,
        up: Vector3
    ) -> Matrix4 {
        
        assert(simd_length_squared(up) == 1)
        assert(simd_length_squared(look) == 1)
        
        let oy = up
        let oz = look
        let ox = simd_cross(oy, oz)
        let ow = -eye
        
        let matrix = float4x4(
            .init(v: ox, w: 0),
            .init(v: oy, w: 0),
            .init(v: oz, w: 0),
            .init(v: ow, w: 1)
        )

        return matrix
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
        var matrix = GLKMatrix4.toFloat4x4(matrix: persp)
        
        let zs = farZ / (nearZ - farZ)
        matrix[2][2] = zs
        matrix[3][2] = zs * nearZ
        
        return matrix
    }

    
    /// Returns an ortho projection matrix, to convert world space to Metal clip space
    /// - Parameters:
    ///   - size: view height
    ///   - aspectRatio: view width/height
    ///   - nearZ: near clip plane
    ///   - farZ:  far clip plane
    /// - Returns: ortho projection matrix
    @inlinable
    public static func makeOrtho(
        size: Float,
        aspectRatio: Float,
        nearZ: Float,
        farZ: Float
    ) -> Matrix4 {

        let h = size
        let w = aspectRatio * size
        let l = farZ - nearZ
        
        let x =  2 / w // -1 - 1
        let y =  2 / h // 1 - -1
        let z =  1 / l // 0 - 1
        let zt = (farZ + nearZ) * z
        
        let matrix = float4x4(
            .init( x,  0,  0,  0),
            .init( 0,  y,  0,  0),
            .init( 0,  0,  z, zt),
            .init( 0,  0,  0,  1)
        )

        return matrix
    }
    
    @inlinable
    public static func makeOrtho(
        size: Float,
        aspectRatio: Float,
        length: Float
    ) -> Matrix4 {

        let h = size
        let w = aspectRatio * size
        let l = length
        
        let x = -2 / w // -1 - 1
        let y =  2 / h // 1 - -1
        let z = -1 / l // 0 - 1
        
        let matrix = float4x4(
            .init( x,  0,  0,  0),
            .init( 0,  y,  0,  0),
            .init( 0,  0,  z,  0),
            .init( 0,  0,  0,  1)
        )

        return matrix
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
