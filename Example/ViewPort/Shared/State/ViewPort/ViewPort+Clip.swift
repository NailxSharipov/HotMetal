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
    
    enum RotateClip {
        case noClipping
        case overlap(Rect)
    }
    
    func rotateClip(world: Rect, angle: Float) -> RotateClip {
        let points = world.rotate(angle: angle)
        
        let xMax = 0.5 * imageSize.width
        let yMax = 0.5 * imageSize.height
        
        var ms: Float = 1   // min scale
        let c = world.center
        
        // right
        if let p = points.max(by: { $0.x < $1.x }), p.x > xMax {
            let d0 = p.x - c.x  // big
            let d1 = xMax - c.x // small
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
        
        let xMaxE = xMax + 0.01
        let yMaxE = yMax + 0.01
        
        let vec = float - fixed

        var maxOffset: Float = 0
        var point: Vector2?
        
        if vec.x > 0 && float.x > xMaxE {
            let n = vec.normalized
            
            let dx = xMax - fixed.x
            let dy = dx * n.y / n.x

            maxOffset = float.x - xMax
            
            point = fixed + Vector2(x: dx, y: dy)
        } else if vec.x < 0 && float.x < -xMaxE {
            let n = vec.normalized
            
            let dx = -xMax - fixed.x
            let dy = dx * n.y / n.x
            
            maxOffset = xMax - float.y
            
            point = fixed + Vector2(x: dx, y: dy)
        }

        if vec.y > 0 && float.y > yMaxE {
            let n = vec.normalized
            
            let dy = yMax - fixed.y
            let dx = dy * n.x / n.y
            
            let offset = float.y - yMax

            if maxOffset < offset {
                point = fixed + Vector2(x: dx, y: dy)
            }
        } else if vec.y < 0 && float.y < -yMaxE {
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
    
    enum ScaleClip {
        case noClipping
        case overlap(Rect)
    }
    
    func scaleClip(world: Rect, angle: Float) -> ScaleClip {
        let points = world.rotate(angle: angle)
        
        let xMax = 0.5 * imageSize.width
        let yMax = 0.5 * imageSize.height
        let xeMax = xMax + 0.001
        let yeMax = yMax + 0.001
        let xeMin = -xeMax
        let yeMin = -yeMax

        
        var offset: Vector2 = .zero
        var isOverlap = false
        
        let pxMin = points.min(by: { $0.x < $1.x })?.x ?? 0
        let pxMax = points.max(by: { $0.x < $1.x })?.x ?? 0
        let pyMin = points.min(by: { $0.y < $1.y })?.y ?? 0
        let pyMax = points.max(by: { $0.y < $1.y })?.y ?? 0
        
        // right
        if pxMax > xeMax {
            let dx = xMax - pxMax
            offset.x = dx
            isOverlap = true
        }

        // left
        if pxMin < xeMin {
            let d = -xMax - pxMin
            offset.x += d
            isOverlap = true
        }

        // top
        if pyMax > yeMax {
            let dy = yMax - pyMax
            offset.y = dy
            isOverlap = true
        }

        // bottom
        if pyMin < yeMin {
            let dy = -yMax - pyMin
            offset.y += dy
            isOverlap = true
        }
        
        guard isOverlap  else {
            return .noClipping
        }
        
        let dWidth = pxMax - pxMin
        let dHeight = pyMax - pyMin
        
        let sx = dWidth / imageSize.width
        let sy = dHeight / imageSize.height
        
        let s = 1 / max(sx, sy)

        let size = Size(width: s * world.width, height: s * world.height)
        
        let cx: Float
        
        if sx > 1 {
            cx = 0
        } else {
            cx = world.center.x + offset.x
        }

        let cy: Float
        
        if sy > 1 {
            cy = 0
        } else {
            cy = world.center.y + offset.y
        }

        return .overlap(Rect(
            center: Vector2(x: cx, y: cy),
            size: size
        ))
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
