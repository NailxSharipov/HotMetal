//
//  ViewPort+Camera.swift
//  ViewPort
//
//  Created by Nail Sharipov on 25.04.2022.
//

import simd
import HotMetal
import CoreGraphics

struct ViewPortCamera {
    
    var camera = Camera.empty

    private var worldView: Rect = .zero
    
    mutating func update(viewPort: ViewPort) {
        guard worldView != viewPort.worldView else { return }
        worldView = viewPort.worldView

        camera.projectionMatrix = Matrix4.makeOrtho(viewRect: worldView)
        camera.viewMatrix = .identity
    }
    
    static func worldView(viewSize: Size, localRect: Rect, worldRect: Rect) -> Rect {
        let m = localRect.toWorld(rect: worldRect)
        let sv = SIMD3(viewSize.width, viewSize.height, 0)
        let s = simd_mul(m, sv)
        let worldViewRect = Rect(center: worldRect.center, width: s.x, height: s.y, angle: worldRect.angle)
        
        
        return worldViewRect
    }
    
}


private extension Matrix4 {

    static func makeOrtho(viewRect: Rect) -> Matrix4 {
        let sx = 2 / viewRect.width
        let sy = 2 / viewRect.height
        
        let cx = -viewRect.center.x
        let cy = -viewRect.center.y

        let s = float4x4(
            .init( sx,  0,  0,  0),
            .init(  0, sy,  0,  0),
            .init(  0,  0,  1,  0),
            .init(  0,  0,  0,  1)
        )

        let a: Float = -viewRect.angle
        let cs: Float = cos(a)
        let sn: Float = sin(a)
        
        let r = float4x4(
            .init( cs, sn,  0,  0),
            .init(-sn, cs,  0,  0),
            .init( 0,   0,  1,  0),
            .init( 0,   0,  0,  1)
        )

        let t = float4x4(
            .init(  1,  0,  0,  0),
            .init(  0,  1,  0,  0),
            .init(  0,  0,  1,  0),
            .init( cx, cy,  0,  1)
        )
        
        // m = s * r * t
        
        let m0 = simd_mul(s, r)
        let m1 = simd_mul(m0, t)
        
        return m1
    }

}
