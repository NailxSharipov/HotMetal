//
//  ViewPort+Clip.swift
//  ViewPort
//
//  Created by Nail Sharipov on 01.05.2022.
//

import HotMetal
import Darwin
import simd

extension ViewPort {

    struct Clip {
        let vector: Vector2
        let delta: Size
        
        let isOverlap: Bool
    }
    
    func isClip(world: Rect) -> Clip {
        
        var x: Float = 0
        var y: Float = 0
        var w: Float = 0
        var h: Float = 0
        var isOverlap = false
        
        let points = world.rotate(angle: angle)
        
        let dx = 0.5 * imageSize.width
        let dy = 0.5 * imageSize.height
        
        // right
        if let p = points.max(by: { $0.x < $1.x }), p.x > dx {
            let dif = dx - p.x
            x += dif
            w += dif
            isOverlap = true
        }

        // left
        if let p = points.min(by: { $0.x < $1.x }), p.x < -dx {
            let dif = -dx - p.x
            x += dif
            w -= dif
            isOverlap = true
        }

        // top
        if let p = points.max(by: { $0.y < $1.y }), p.y > dy {
            let dif = dy - p.y
            y += dif
            h += dif
            isOverlap = true
        }

        // bottom
        if let p = points.min(by: { $0.y < $1.y }), p.y < -dy {
            let dif = -dy - p.y
            y += dif
            h -= dif
            isOverlap = true
        }
        
        return Clip(vector: Vector2(x: x, y: y), delta: Size(width: w, height: h), isOverlap: isOverlap)
    }
    
}

private extension Rect {
    
    func rotate(angle: Float) -> [Vector2] {
        let dx = 0.5 * width
        let dy = 0.5 * height

        let bottomLeft = Vector2(x: -dx, y: -dy)
        let topLeft = Vector2(x: -dx, y:  dy)
        let topRight = Vector2(x:  dx, y:  dy)
        let bottomRight = Vector2(x:  dx, y: -dy)

        let cs = cos(angle)
        let sn = sin(angle)

        let m = float2x2(
            .init(cs, sn),
            .init(-sn, cs)
        )

        return [
            simd_mul(m, bottomLeft) + center,
            simd_mul(m, topLeft) + center,
            simd_mul(m, topRight) + center,
            simd_mul(m, bottomRight) + center
        ]
    }

}
