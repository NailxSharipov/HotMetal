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

    private (set) var camera = Camera.empty

    private var worldView: Rect = .zero
    private var angle: Float = 0
    
    mutating func update(viewPort: ViewPort) {
        let rect = viewPort.worldView
        guard worldView != rect || angle != viewPort.angle  else { return }
        worldView = rect
        angle = viewPort.angle
        camera.projectionMatrix = Matrix4.makeOrtho(rect: rect, angle: viewPort.angle)
    }
}

private extension ViewPort {
    
    var worldView: Rect {
        let w = transform.localToWorldScale * viewSize.width
        let h = transform.localToWorldScale * viewSize.height

        return Rect(center: nextWorld.center, width: w, height: h)
    }
}


private extension Matrix4 {

    static func makeOrtho(rect: Rect, angle: Float) -> Matrix4 {
        
        // translate
        
        let tx = -rect.center.x
        let ty = -rect.center.y
        
        let t = float4x4(
            .init(  1,  0,  0,  0),
            .init(  0,  1,  0,  0),
            .init(  0,  0,  1,  0),
            .init( tx, ty,  0,  1)
        )
        
        // rotate
        
        let dx = 0.5 * rect.width
        let dy = 0.5 * rect.height

        let cs = cos(angle)
        let sn = sin(angle)
        
        let m = float2x2(
            .init(cs, sn),
            .init(-sn, cs)
        )
        
        let v0 = simd_mul(m, Vector2(x: dx, y: 0))
        let v1 = simd_mul(m, Vector2(x: 0, y: dy))

        let v = float4x4(
            .init(v0.x, v0.y,   0,   0),
            .init(v1.x, v1.y,   0,   0),
            .init(   0,    0,   1,   0),
            .init(   0,    0,   0,   1)
        ).inverse
        
        return simd_mul(v, t)
    }
}
