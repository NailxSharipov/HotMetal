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
        
        private let mScreenToLocal: float3x3
        private let mLocalToScreen: float3x3
        
        private let mLocalToWorld: float3x3
        private let mWorldToLocal: float3x3
        
        private let mScreenToWorld: float3x3
        private let mWorldToScreen: float3x3
        
        let isEmpty: Bool
    }
    
}

extension ViewPort.CoordSystemTransformer {

    init() {
        mScreenToLocal = .identity
        mLocalToScreen = .identity
        
        mLocalToWorld = .identity
        mWorldToLocal = .identity
        
        mScreenToWorld = .identity
        mWorldToScreen = .identity
        
        isEmpty = true
    }
    
    init(viewSize: Size, local: Rect, world: Rect) {
        mScreenToLocal = Self.screenToLocal(viewSize: viewSize)
        mLocalToScreen = Self.localToScreen(viewSize: viewSize)
        
        mLocalToWorld = Self.localToWorld(local: local, world: world)
        mWorldToLocal = mLocalToWorld.inverse
        
        mScreenToWorld = simd_mul(mLocalToWorld, mScreenToLocal)
        mWorldToScreen = mScreenToWorld.inverse
        
        isEmpty = false
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
    
    private static func localToWorld(local: Rect, world: Rect) -> float3x3 {
        let sc = world.width / local.width
        
        let s = float3x3(
            .init(sc,  0,  0),
            .init( 0, sc,  0),
            .init( 0,  0,  1)
        )

        let cs: Float = cos(world.angle)
        let sn: Float = sin(world.angle)
        
        let r = float3x3(
            .init( cs, sn,  0),
            .init(-sn, cs,  0),
            .init( 0,   0,  1)
        )
        
        return simd_mul(s, r)
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

    // Screen to ...
    
    func screenToWorld(point p: CGPoint) -> Vector2 {
        let v0 = Vector3(x: Float(p.x), y: Float(p.y), z: 1)
        let v1 = simd_mul(mScreenToWorld, v0)
        return Vector2(x: v1.x, y: v1.y)
    }

    func screenToWorld(size s: CGSize) -> Size {
        let v0 = Vector3(x: Float(s.width), y: Float(s.height), z: 0)
        let v1 = simd_mul(mScreenToWorld, v0)
        return Size(width: v1.x, height: v1.y)
    }
    
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
    
    func worldToScreen(point p: Vector2) -> Vector2 {
        let v0 = Vector3(x: p.x, y: p.y, z: 1)
        let v1 = simd_mul(mWorldToScreen, v0)
        return Vector2(x: v1.x, y: v1.y)
    }
}
