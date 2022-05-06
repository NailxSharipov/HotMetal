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
        let isOverlap: Bool
    }
    
    func rectClip(world: Rect) -> RectClip {
        
        var x: Float = 0
        var y: Float = 0
        var isOverlap = false
        
        let points = world.rotate(angle: angle)
        
        let dx = 0.5 * imageSize.width
        let dy = 0.5 * imageSize.height
        
        // right
        if let p = points.max(by: { $0.x < $1.x }), p.x > dx {
            let dif = dx - p.x
            x += dif
            isOverlap = true
        }

        // left
        if let p = points.min(by: { $0.x < $1.x }), p.x < -dx {
            let dif = -dx - p.x
            x += dif
            isOverlap = true
        }

        // top
        if let p = points.max(by: { $0.y < $1.y }), p.y > dy {
            let dif = dy - p.y
            y += dif
            isOverlap = true
        }

        // bottom
        if let p = points.min(by: { $0.y < $1.y }), p.y < -dy {
            let dif = -dy - p.y
            y += dif
            isOverlap = true
        }
        
        return RectClip(vector: Vector2(x: x, y: y), isOverlap: isOverlap)
    }
    
    enum ScaleClip {
        case noClipping
        case overlap(Rect)
    }
    
    func scaleClip(world: Rect) -> ScaleClip {
        let points = world.rotate(angle: angle)
        
        let xMax = 0.5 * imageSize.width
        let yMax = 0.5 * imageSize.height
        
        var ms: Float = 1   // min scale
        let c = world.center
        
        // right
        if let p = points.max(by: { $0.x < $1.x }), p.x > xMax {
            let d0 = p.x - c.x  // big
            let d1 = xMax - c.x   // small
            let s = d1 / d0     // < 1
            ms = min(ms, s)
        }

        // left
        if let p = points.min(by: { $0.x < $1.x }), p.x < -xMax {
            let d0 = c.x - p.x  // big
            let d1 = c.x + xMax // small
            let s = d1 / d0     // < 1
            ms = min(ms, s)
        }

        // top
        if let p = points.max(by: { $0.y < $1.y }), p.y > yMax {
            let d0 = p.y - c.y  // big
            let d1 = yMax - c.y // small
            let s = d1 / d0     // < 1
            ms = min(ms, s)
        }

        // bottom
        if let p = points.min(by: { $0.y < $1.y }), p.y < -yMax {
            let d0 = c.y - p.y   // big
            let d1 = c.y + yMax  // small
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
    
    struct PointClip {
        let point: Vector2
        let isOverlap: Bool
    }
    
    func clip(point: Vector2) -> PointClip {
        let xMax = 0.5 * imageSize.width
        let yMax = 0.5 * imageSize.height
        
        var p = point
        var isOverlap = false
        
        if p.x > xMax {
            p.x = xMax
            isOverlap = true
        } else if p.x < -xMax {
            p.x = -xMax
            isOverlap = true
        }

        if p.y > yMax {
            p.y = yMax
            isOverlap = true
        } else if p.y < -yMax {
            p.y = -yMax
            isOverlap = true
        }
        
        return PointClip(point: p, isOverlap: isOverlap)
    }
    
    func clip(fixed: Vector2, float: Vector2) -> PointClip {
        let xMax = 0.5 * imageSize.width
        let yMax = 0.5 * imageSize.height
        
        let vec = float - fixed

        var maxOffset: Float = 0
        var point: Vector2?
        
        if vec.x > 0 && float.x > xMax {
            let n = vec.normalized
            
            let dx = xMax - fixed.x
            let dy = dx * n.y / n.x

            maxOffset = float.x - xMax
            
            point = fixed + Vector2(x: dx, y: dy)
        } else if vec.x < 0 && float.x < -xMax {
            let n = vec.normalized
            
            let dx = -xMax - fixed.x
            let dy = dx * n.y / n.x
            
            maxOffset = xMax - float.y
            
            point = fixed + Vector2(x: dx, y: dy)
        }

        if vec.y > 0 && float.y > yMax {
            let n = vec.normalized
            
            let dy = yMax - fixed.y
            let dx = dy * n.x / n.y
            
            let offset = float.y - yMax

            if maxOffset < offset {
                point = fixed + Vector2(x: dx, y: dy)
            }
        } else if vec.y < 0 && float.y < -yMax {
            let n = vec.normalized
            
            let dy = -yMax - fixed.y
            let dx = dy * n.x / n.y
            
            let offset = yMax - float.y
            
            if maxOffset < offset {
                point = fixed + Vector2(x: dx, y: dy)
            }
        }
        
        if let point = point {
            return PointClip(point: point, isOverlap: true)
        } else {
            return PointClip(point: float, isOverlap: false)
        }
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
