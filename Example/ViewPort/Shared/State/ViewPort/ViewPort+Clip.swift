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

    struct RectClip {
        let vector: Vector2
        let delta: Size
        
        let isOverlap: Bool
    }
    
    func isClip(world: Rect) -> RectClip {
        
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
        
        return RectClip(vector: Vector2(x: x, y: y), delta: Size(width: w, height: h), isOverlap: isOverlap)
    }
    
    enum ScaleClip {
        case noClipping
        case overlap(Rect)
    }
    
    func scaleClip(world: Rect) -> ScaleClip {
        let points = world.rotate(angle: angle)
        
        let dx = 0.5 * imageSize.width
        let dy = 0.5 * imageSize.height
        
        var ms: Float = 1   // min scale
        let c = world.center
        
        // right
        if let p = points.max(by: { $0.x < $1.x }), p.x > dx {
            let d0 = p.x - c.x  // big
            let d1 = dx - c.x   // small
            let s = d1 / d0     // < 1
            ms = min(ms, s)
        }

        // left
        if let p = points.min(by: { $0.x < $1.x }), p.x < -dx {
            let d0 = c.x - p.x  // big
            let d1 = c.x + dx   // small
            let s = d1 / d0     // < 1
            ms = min(ms, s)
        }

        // top
        if let p = points.max(by: { $0.y < $1.y }), p.y > dy {
            let d0 = p.y - c.y  // big
            let d1 = dy - c.y   // small
            let s = d1 / d0     // < 1
            ms = min(ms, s)
        }

        // bottom
        if let p = points.min(by: { $0.y < $1.y }), p.y < -dy {
            let d0 = c.y - p.y   // big
            let d1 = c.y + dy    // small
            let s = d1 / d0      // < 1
            ms = min(ms, s)
        }
        
        guard ms < 1 else {
            return .noClipping
        }
        
        let width = ms * world.width
        let height = ms * world.height

        return .overlap(Rect(center: world.center, size: Size(width: width, height: height)))
    }
    
    struct CornerClip {
        let point: Vector2
        let delta: Size
        
        let isOverlap: Bool
    }
    
    func clip(point: Vector2) -> CornerClip {
        let dx = 0.5 * imageSize.width
        let dy = 0.5 * imageSize.height
        
        var p = point
        
        var isOverlap = false
        
        if p.x > dx {
            p.x = dx
            isOverlap = true
        }
        
        if p.x < -dx {
            p.x = -dx
            isOverlap = true
        }

        if p.y > dy {
            p.y = dy
            isOverlap = true
        }
        
        if p.y < -dy {
            p.y = -dy
            isOverlap = true
        }
        
        return .init(point: p, delta: Size(vector: point - p), isOverlap: isOverlap)
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
