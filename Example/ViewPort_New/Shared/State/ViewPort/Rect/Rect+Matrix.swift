//
//  Rect+Matrix.swift
//  ViewPort
//
//  Created by Nail Sharipov on 28.04.2022.
//

import simd

extension Rect {
    
    func toWorld(rect: Rect) -> float3x3 {
        let dx = rect.center.x
        let dy = rect.center.y
        
        let t = float3x3(
            .init( 1,  0,  0),
            .init( 0,  1,  0),
            .init(dx, dy,  1)
        )
        
        let sx = rect.width / width
        let sy = rect.height / height
        
        let s = float3x3(
            .init(sx, 0, 0),
            .init(0, sy, 0),
            .init(0, 0,  1)
        )
        
        let a: Float = rect.angle
        
        let cs: Float = cos(a)
        let sn: Float = sin(a)
        
        let r = float3x3(
            .init( cs, sn,  0),
            .init(-sn, cs,  0),
            .init( 0,   0,  1)
        )
        
        // m = t*r*s
        
        let tr = simd_mul(t, r)
        let m = simd_mul(tr, s)

        return m
    }

    static func newWorld(oldLocal: Rect, newLocal: Rect, oldWorld: Rect) -> Rect {
        let m = oldLocal.toWorld(rect: oldWorld)

        let c = simd_mul(m, SIMD3<Float>(newLocal.center, 1))
        let s = simd_mul(m, SIMD3<Float>(newLocal.width, newLocal.height, 0))
        
        return Rect(
            center: .init(x: c.x, y: c.y),
            width: s.x,
            height: s.y,
            angle: oldWorld.angle
        )
    }
}
