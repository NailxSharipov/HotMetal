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
    private var cropRect: CGRect = .zero
    private var viewSize: CGSize = .zero
    
    mutating func update(viewPort: ViewPort) {
        guard cropRect != viewPort.cropWorld || viewSize != viewPort.viewSize   else { return }
        cropRect = viewPort.cropWorld
        viewSize = viewPort.viewSize

        camera.projectionMatrix = Matrix4.makeOrtho(viewRect: viewPort.cropWorld)
        camera.viewMatrix = Matrix4.makeLook(viewSize: viewPort.viewSize, clipRect: viewPort.cropNextLocal)
    }
    
    mutating func update(viewPort: ViewPort, posX: CGFloat, posY: CGFloat) {
        
        cropRect = viewPort.cropWorld
        viewSize = viewPort.viewSize

        camera.projectionMatrix = Matrix4.makeOrtho(viewRect: viewPort.cropWorld, posX: posX, posY: posY)
        camera.viewMatrix = Matrix4.makeLook(viewSize: viewPort.viewSize, clipRect: viewPort.cropNextLocal)
    }
    
}


private extension Matrix4 {
    
    static func makeOrtho(viewRect: CGRect) -> Matrix4 {
        let width = Float(viewRect.width)
        let height = Float(viewRect.height)

        let posX = viewRect.origin.x + 0.5 * viewRect.width
        let posY = viewRect.origin.y + 0.5 * viewRect.height
        
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
        
        print(m)
        
        return m
    }
    
    static func makeOrtho(viewRect: CGRect, posX: CGFloat, posY: CGFloat) -> Matrix4 {
        let width = Float(viewRect.width)
        let height = Float(viewRect.height)

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

    static func makeLook(viewSize: CGSize, clipRect: CGRect) -> Matrix4 {
        let sx = Float(clipRect.width / viewSize.width)
        let sy = Float(clipRect.height / viewSize.height)

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
