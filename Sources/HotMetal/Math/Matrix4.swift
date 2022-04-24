//
//  Matrix4.swift
//  HotMetal
//
//  Created by Nail Sharipov on 12.04.2022.
//

import simd

public typealias Matrix4 = float4x4

public extension Matrix4 {

    static let identity = float4x4(Float(1.0))

    init(quaternion: Quaternion) {
        self.init(quaternion)
        self[3][3] = 1
    }
    
    @inlinable
    static func scale(_ scaleX: Float, _ scaleY: Float, _ scaleZ: Float) -> Matrix4 {
        Matrix4(diagonal: [scaleX, scaleY, scaleZ, 1])
    }

    @inlinable
    static func rotate(radians: Float, axis: Vector3) -> Matrix4 {
        Matrix4(Quaternion(angle: radians, axis: axis))
    }

    @inlinable
    static func translate(_ translation: Vector3) -> Matrix4 {
        Matrix4(columns:(
            Vector4(1, 0, 0, 0),
            Vector4(0, 1, 0, 0),
            Vector4(0, 0, 1, 0),
            Vector4(translation, 1)
        ))
    }

    /// Returns a matrix that converts points from world space to eye space
    /// - Parameters:
    ///   - eye: camera position
    ///   - look: look direction
    ///   - up: second vector, most of the time it's (0, 1, 0)
    /// - Returns: view matrix
    @inlinable
    static func makeLook(
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
    /// - Parameters:
    ///   - fovy: fovy in radians
    ///   - aspectRatio: view width/height
    ///   - nearZ: near clip plane
    ///   - farZ: far clip plane
    /// - Returns: perspective projection matrix
    static func makePerspective(
        fovyDegrees fovy: Float,
        aspectRatio: Float,
        nearZ: Float,
        farZ: Float
    ) -> Matrix4 {
        let y: Float = 1 / tan(0.5 * fovy)
        let x = y / aspectRatio
        let length = farZ - nearZ
        let z = (farZ + nearZ) / length
        let wz = -farZ * nearZ / length

        let matrix = float4x4(
            .init( x,  0,  0,  0),
            .init( 0,  y,  0,  0),
            .init( 0,  0,  z,  1),
            .init( 0,  0, wz,  0)
        )

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
    static func makeOrtho(
        size: Float,
        aspectRatio: Float,
        nearZ z1: Float,
        farZ z2: Float
    ) -> Matrix4 {

        let dy = size
        let dx = aspectRatio * size
        let dz = z2 - z1
        
        let sx = 2 / dx
        let sy = 2 / dy
        let sz = 1 / dz
        let tz = -z1 / dz
        
        let matrix = float4x4(
            .init(sx,  0,  0,  0),
            .init( 0, sy,  0,  0),
            .init( 0,  0, sz,  0),
            .init( 0,  0, tz,  1)
        )

        return matrix
    }
    
    /// Returns an ortho projection matrix, to convert world space to Metal clip space
    /// - Parameters:
    ///   - left: screen left
    ///   - right: screen right
    ///   - top: screen top
    ///   - bottom: screen bottom
    ///   - nearZ: near clip plane
    ///   - farZ:  far clip plane
    /// - Returns: ortho projection matrix
    @inlinable
    static func makeOrtho(
        left x1: Float,
        right x2: Float,
        top y2: Float,
        bottom y1: Float,
        nearZ z1: Float,
        farZ z2: Float
    ) -> Matrix4 {

        let dx = x2 - x1
        let dy = y2 - y1
        let dz = z2 - z1

        let ix = 1 / dx
        let iy = 1 / dy
        let iz = 1 / dz
        
        let sx = 2 * ix
        let sy = 2 * iy
        let sz = iz
        
        let xt = -(x1 + x2) * ix
        let yt = -(y1 + y2) * iy
        let zt = -z1 * iz
        
        let matrix = float4x4(
            .init(sx,  0,  0,  0),
            .init( 0, sy,  0,  0),
            .init( 0,  0, sz,  0),
            .init(xt, yt, zt,  1)
        )

        return matrix
    }
}
