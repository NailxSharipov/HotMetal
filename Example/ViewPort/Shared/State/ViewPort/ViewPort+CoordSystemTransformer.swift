//
//  ViewPort+CoordSystemTransformer.swift
//  ViewPort
//
//  Created by Nail Sharipov on 01.05.2022.
//

import simd
import HotMetal
import CoreGraphics

extension ViewPort {
    
    struct CoordSystemTransformer {
        let localToWorldScale: Float
        
        private let mScreenToLocal: float3x3
        private let mLocalToScreen: float3x3
        private var mLocalToWorld: float3x3
        private var mWorldToLocal: float3x3
        
        let isEmpty: Bool
    }
    
}

extension ViewPort.CoordSystemTransformer {

    init() {
        localToWorldScale = 1
        
        mScreenToLocal = .identity
        mLocalToScreen = .identity
        
        mLocalToWorld = .identity
        mWorldToLocal = .identity
        
        isEmpty = true
    }
    
    init(viewSize: Size, scale: Float, angle: Float, translate: Vector2) {
//        localToWorldScale = world.width / local.width

        localToWorldScale = scale
        
        mScreenToLocal = Self.screenToLocal(viewSize: viewSize)
        mLocalToScreen = Self.localToScreen(viewSize: viewSize)

        mLocalToWorld = Self.localToWorld(scale: localToWorldScale, angle: angle, translate: translate)
        mWorldToLocal = mLocalToWorld.inverse
        
        isEmpty = false
    }
    
    mutating func update(worldPos: Vector2) {
        mLocalToWorld.columns.2.x = worldPos.x
        mLocalToWorld.columns.2.y = worldPos.y
        mWorldToLocal = mLocalToWorld.inverse
    }
    
    private static func screenToLocal(viewSize: Size) -> float3x3 {
        let tx = -0.5 * viewSize.width
        let ty = -0.5 * viewSize.height

        let s = float3x3(
            .init( 1,  0,  0),
            .init( 0, -1,  0),
            .init( 0,  0,  1)
        )

        let t = float3x3(
            .init(  1,  0,  0),
            .init(  0,  1,  0),
            .init( tx, ty,  1)
        )

        return simd_mul(s, t)
    }
    
    private static func localToScreen(viewSize: Size) -> float3x3 {
        let tx = 0.5 * viewSize.width
        let ty = 0.5 * viewSize.height

        let s = float3x3(
            .init( 1,  0,  0),
            .init( 0, -1,  0),
            .init( 0,  0,  1)
        )

        let t = float3x3(
            .init(  1,  0,  0),
            .init(  0,  1,  0),
            .init( tx, ty,  1)
        )

        return simd_mul(t, s)
    }
    
    private static func localToWorld(scale: Float, angle: Float, translate t: Vector2) -> float3x3 {
        let sc = scale
        
        let s = float3x3(
            .init(sc,  0,  0),
            .init( 0, sc,  0),
            .init( 0,  0,  1)
        )

        let cs: Float = cos(angle)
        let sn: Float = sin(angle)
        
        let r = float3x3(
            .init( cs, sn,  0),
            .init(-sn, cs,  0),
            .init( 0,   0,  1)
        )
        
        let t = float3x3(
            .init(  1,  0,  0),
            .init(  0,  1,  0),
            .init( t.x, t.y,  1)
        )
        
        let m0 = simd_mul(t, r)
        let m1 = simd_mul(m0, s)
        
        return m1
    }
}


extension ViewPort.CoordSystemTransformer {

    // Local to ...
    
    func localToScreen(point p: Vector2) -> Vector2 {
        let v0 = Vector3(x: p.x, y: p.y, z: 1)
        let v1 = simd_mul(mLocalToScreen, v0)
        return Vector2(x: v1.x, y: v1.y)
    }
    
    func localToWorld(size s: Size) -> Size {
        let v0 = Vector3(x: s.width, y: s.height, z: 0)
        let v1 = simd_mul(mLocalToWorld, v0)
        return Size(width: v1.x, height: v1.y)
    }
    
    func localToWorld(point p: Vector2) -> Vector2 {
        let v0 = Vector3(x: p.x, y: p.y, z: 1)
        let v1 = simd_mul(mLocalToWorld, v0)
        return Vector2(x: v1.x, y: v1.y)
    }
    
    func localToWorld(rect: Rect) -> Rect {
        let center = self.localToWorld(point: rect.center)

        let w = self.scaleLocalToWorld(rect.width)
        let h = self.scaleLocalToWorld(rect.height)
        
        return Rect(
            x: center.x,
            y: center.y,
            width: w,
            height: h
        )
    }
    
    // Screen to ...

    func screenToLocal(size s: CGSize) -> Size {
        let v0 = Vector3(x: Float(s.width), y: Float(s.height), z: 0)
        let v1 = simd_mul(mScreenToLocal, v0)
        return Size(width: v1.x, height: v1.y)
    }
    
    func screenToLocal(point p: CGPoint) -> Vector2 {
        let v0 = Vector3(x: Float(p.x), y: Float(p.y), z: 1)
        let v1 = simd_mul(mScreenToLocal, v0)
        return Vector2(x: v1.x, y: v1.y)
    }

    // World to ...
    func worldToLocal(size s: Size) -> Size {
        let v0 = Vector3(x: s.width, y: s.height, z: 0)
        let v1 = simd_mul(mWorldToLocal, v0)
        return Size(width: v1.x, height: v1.y)
    }
    
    func worldToLocal(point p: Vector2) -> Vector2 {
        let v0 = Vector3(x: p.x, y: p.y, z: 1)
        let v1 = simd_mul(mWorldToLocal, v0)
        return Vector2(x: v1.x, y: v1.y)
    }
    
    // Scale
    
    func scaleLocalToWorld(_ value: Float) -> Float {
        value * localToWorldScale
    }
    
    func scaleWorldToLocal(_ value: Float) -> Float {
        value / localToWorldScale
    }

    func scaleLocalToWorld(_ size: Size) -> Size {
        Size(
            width: scaleLocalToWorld(size.width),
            height: scaleLocalToWorld(size.height)
        )
    }
    
    func scaleWorldToLocal(_ size: Size) -> Size {
        Size(
            width: scaleWorldToLocal(size.width),
            height: scaleWorldToLocal(size.height)
        )
    }
}
