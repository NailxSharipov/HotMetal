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
    private var cropRect: Rect = .zero
    private var viewSize: Size = .zero
    
    mutating func update(viewPort: ViewPort) {
        guard cropRect != viewPort.cropWorld || viewSize != viewPort.viewSize   else { return }

        cropRect = viewPort.cropWorld
        viewSize = viewPort.viewSize

        let worldViewRect = Self.worldView(
            viewSize: viewSize,
            localRect: viewPort.cropLocal,
            worldRect: cropRect
        )
        
        camera.projectionMatrix = Matrix4.makeOrtho2(viewRect: worldViewRect)
        camera.viewMatrix = .identity //Matrix4.makeLook(viewSize: viewPort.viewSize, clipRect: viewPort.cropNextLocal)
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
        let width = viewRect.width
        let height = viewRect.height

        let posX = viewRect.center.x
        let posY = viewRect.center.y
        
        let iw = 1 / width
        let ih = 1 / height
        
        let sx = 2 * iw
        let sy = 2 * ih
        
        let cx = -Float(posX)
        let cy = -Float(posY)

        let s = float4x4(
            .init(   sx,    0,    0,    0),
            .init(    0,   sy,    0,    0),
            .init(    0,    0,    1,    0),
            .init(    0,    0,    0,    1)
        )

        let t = float4x4(
            .init(    1,    0,    0,    0),
            .init(    0,    1,    0,    0),
            .init(    0,    0,    1,    0),
            .init(   cx,   cy,    0,    1)
        )
        
        let m = simd_mul(s, t)
        
        return m
    }
    
    static func makeOrtho2(viewRect: Rect) -> Matrix4 {
        let width = viewRect.width
        let height = viewRect.height

        let posX = viewRect.center.x
        let posY = viewRect.center.y
        
        let iw = 1 / width
        let ih = 1 / height
        
        let sx = 2 * iw
        let sy = 2 * ih
        
        let cx = -Float(posX)
        let cy = -Float(posY)

        let s = float4x4(
            .init(   sx,    0,    0,    0),
            .init(    0,   sy,    0,    0),
            .init(    0,    0,    1,    0),
            .init(    0,    0,    0,    1)
        )

        
        let a = viewRect.angle
        let cs: Float = cos(a)
        let sn: Float = sin(a)
        
        let r = float4x4(
            .init( cs, sn,  0,  0),
            .init(-sn, cs,  0,  0),
            .init( 0,   0,  1,  0),
            .init( 0,   0,  0,  1)
        )

        let t = float4x4(
            .init(    1,    0,    0,    0),
            .init(    0,    1,    0,    0),
            .init(    0,    0,    1,    0),
            .init(   cx,   cy,    0,    1)
        )
        
        // m = r * s * t
        
        var m = simd_mul(r, s)
        m = simd_mul(m, t)
        
        return m
    }

    static func makeLook(viewSize: Size, clipRect: Rect) -> Matrix4 {
        let sx = clipRect.width / viewSize.width
        let sy = clipRect.height / viewSize.height

        let dx: Float = 0
        let dy: Float = 0
        
        let translate = float4x4(
            .init(   sx,    0,    0,    0),
            .init(    0,   sy,    0,    0),
            .init(    0,    0,    1,    0),
            .init(   dx,   dy,    0,    1)
        )

        return translate
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
    
    @inline(__always)
    static func scale(_ s: Float) -> Matrix4 {
        float4x4(
            .init( s, 0, 0, 0),
            .init( 0, s, 0, 0),
            .init( 0, 0, 1, 0),
            .init( 0, 0, 0, 1)
        )
    }
    
}
