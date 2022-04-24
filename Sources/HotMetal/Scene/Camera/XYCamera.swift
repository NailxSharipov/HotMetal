//
//  XYCamera.swift
//  HotMetal
//
//  Created by Nail Sharipov on 23.04.2022.
//

import simd

public struct XYCamera {

    fileprivate static let nearZ: Float = -100
    fileprivate static let farZ: Float = 100
    private static let look = Vector3(x: 0, y: 0, z: 1)
    
    public enum Anchor {
        case center
        case leftTop
        case rightTop
        case leftBottom
        case rightBottom
    }
    
    public private (set) var camera: Camera
    private var anchor: Anchor
    public private(set) var position: Vector2
    public private(set) var angle: Float
    private var rotate: Matrix4
    
    public init(
        position: Vector2 = .zero,
        angle: Float = 0,
        width: Float,
        height: Float,
        anchor: Anchor = .center
    ) {
        self.position = position
        self.angle = angle
        self.rotate = Matrix4.rotate(angle: angle)
        self.anchor = anchor
        
        let projectionMatrix = Matrix4.makeOrtho(width: width, height: height, anchor: anchor)
        let viewMatrix = Matrix4.makeLook(position: position, rotate: rotate, anchor: anchor)
        
        camera = Camera(projectionMatrix: projectionMatrix, viewMatrix: viewMatrix)
    }

    public mutating func update(position: Vector2) {
        self.position = position
        camera.viewMatrix = Matrix4.makeLook(position: position, rotate: rotate, anchor: anchor)
    }

    public mutating func update(angle: Float) {
        self.angle = angle
        self.rotate = Matrix4.rotate(angle: angle)
        camera.viewMatrix = Matrix4.makeLook(position: position, rotate: rotate, anchor: anchor)
    }
    
    public mutating func update(position: Vector2, angle: Float) {
        self.angle = angle
        self.rotate = Matrix4.rotate(angle: angle)
        camera.viewMatrix = Matrix4.makeLook(position: position, rotate: rotate, anchor: anchor)
    }
    
    public mutating func update(width: Float, height: Float) {
        camera.projectionMatrix = Matrix4.makeOrtho(width: width, height: height, anchor: anchor)
        camera.viewMatrix = Matrix4.makeLook(position: position, rotate: rotate, anchor: anchor)
    }
    
    public mutating func update(width: Float, height: Float, anchor: Anchor) {
        self.anchor = anchor
        camera.projectionMatrix = Matrix4.makeOrtho(width: width, height: height, anchor: anchor)
        camera.viewMatrix = Matrix4.makeLook(position: position, rotate: rotate, anchor: anchor)
    }
}

private extension Matrix4 {

    static func makeOrtho(
        width: Float,
        height: Float,
        anchor: XYCamera.Anchor
    ) -> Matrix4 {
        let left: Float
        let right: Float
        let bottom: Float
        let top: Float
        
        switch anchor {
        case .center:
            let dx = 0.5 * width
            let dy = 0.5 * height
            left = -dx
            right = dx
            bottom = -dy
            top = dy
        case .leftTop:
            left = 0
            right = width
            top = 0
            bottom = -height
        case .rightTop:
            left = -width
            right = 0
            top = 0
            bottom = -height
        case .leftBottom:
            left = 0
            right = width
            top = height
            bottom = 0
        case .rightBottom:
            left = -width
            right = 0
            top = height
            bottom = 0
        }
        
        return Matrix4.makeOrtho(left: left, right: right, top: top, bottom: bottom, nearZ: XYCamera.nearZ, farZ: XYCamera.farZ)
    }
    
    static func makeLook(position p: Vector2, rotate: Matrix4, anchor: XYCamera.Anchor) -> Matrix4 {

        let ox: Vector3
        let oy: Vector3

        switch anchor {
        case .center:
            ox = .init(x: 1, y: 0, z: 0)
            oy = .init(x: 0, y: 1, z: 0)
        case .leftTop:
            ox = .init(x: 1, y: 0, z: 0)
            oy = .init(x: 0, y:-1, z: 0)
        case .rightTop:
            ox = .init(x:-1, y: 0, z: 0)
            oy = .init(x: 0, y:-1, z: 0)
        case .leftBottom:
            ox = .init(x: 1, y: 0, z: 0)
            oy = .init(x: 0, y: 1, z: 0)
        case .rightBottom:
            ox = .init(x:-1, y: 0, z: 0)
            oy = .init(x: 0, y: 1, z: 0)
        }

        let oz = Vector3(x: 0, y: 0, z: 1)
        let ow = Vector3(x: -p.x, y: -p.y, z: -10)
        
        let origin = float4x4(
            .init(v: ox, w: 0),
            .init(v: oy, w: 0),
            .init(v: oz, w: 0),
            .init(v: ow, w: 1)
        )
        
        let result = simd_mul(origin, rotate)
        
        return result
    }
    
    @inline(__always)
    static func rotate(angle: Float) -> Matrix4 {
        let cos = Darwin.cos(angle)
        let sin = Darwin.sin(angle)
        return float4x4(
            .init(cos, -sin, 0, 0),
            .init(sin,  cos, 0, 0),
            .init(  0,    0, 1, 0),
            .init(  0,  cos, 0, 1)
        )
    }
    
}
