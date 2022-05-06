//
//  ViewPort+Modify.swift
//  ViewPort
//
//  Created by Nail Sharipov on 25.04.2022.
//

import SwiftUI
import HotMetal
import CoreGraphics
import simd

let minLocalSize = Size(width: 64, height: 64)
let minWorldSize = Size(width: 128, height: 128)

extension ViewPort {
    
    private struct Distance {
        let sqrDist: Float
        let corner: Rect.Corner.Layout
    }
    
    // move Corner
    
    func isCorner(point: CGPoint, sqrRadius: CGFloat) -> Rect.Corner.Layout? {
        let p = transform.screenToLocal(point: point)
        
        let distanceList = cropLocal.corners.map({ Distance(sqrDist: $0.point.sqrDistance(p), corner: $0.layout) })
        
        guard let nearest = distanceList.sorted(by: { $0.sqrDist < $1.sqrDist }).first else { return nil }

        if nearest.sqrDist < Float(sqrRadius) {
            return nearest.corner
        }
        
        return nil
    }

    mutating func move(corner: Rect.Corner.Layout, translation: CGSize) {
        self.cropView = self.translate(corner: corner, screen: translation)
    }
    
    mutating func endMove(corner: Rect.Corner.Layout, translation: CGSize) {
        let newLocal = self.translate(corner: corner, screen: translation)
        
        nextWorld = self.world(newLocal: newLocal)
        cropWorld = nextWorld
        cropView = newLocal
        nextLocal = newLocal
        
        self.animate()
    }
    
    // move Body
    
    func isInside(point: CGPoint) -> Bool {
        let local = transform.screenToLocal(point: point)
        return nextLocal.isContain(point: local)
    }

    mutating func move(translation: CGSize) {
        nextWorld = self.clipTranslate(screen: translation).stretch
    }
    
    mutating func endMove(translation: CGSize) {
        nextWorld = self.clipTranslate(screen: translation).fixed
        cropWorld = nextWorld
        transform = CoordSystemTransformer(viewSize: viewSize, local: cropLocal, world: cropWorld, angle: angle)
    }
    
    // rotate
    
    mutating func set(angle: Float) {
        self.angle = angle

        let newWorld = world(newLocal: cropLocal)
        let clip = self.scaleClip(world: newWorld)
        if case let .overlap(rect) = clip {
            nextWorld = rect
        } else {
            nextWorld = newWorld
        }
        cropWorld = nextWorld
        
        let maxCropLocal = Self.calcMaxLocalCrop(viewSize: viewSize, worldSize: cropWorld.size, inset: inset)
        
        cropLocal = maxCropLocal
        cropView = cropLocal
        nextLocal = cropLocal

        transform = CoordSystemTransformer(viewSize: viewSize, local: cropLocal, world: cropWorld, angle: angle)
    }
    
    mutating func animate() {
        let maxCropLocal = Self.calcMaxLocalCrop(viewSize: viewSize, worldSize: cropWorld.size, inset: inset)
        
        self.cropLocal = maxCropLocal
        self.cropView = cropLocal
        self.nextLocal = cropLocal
        
        transform = .init(viewSize: viewSize, local: cropLocal, world: cropWorld, angle: angle)
    }

    private func world(newLocal: Rect) -> Rect {
        let dCenter = newLocal.center - nextLocal.center
        
        let dSize = transform.localToWorld(size: Size(vector: dCenter))

        let center = cropWorld.center + dSize
        
        // TODO
        let w = transform.scaleLocalToWorld(newLocal.width)
        let h = transform.scaleLocalToWorld(newLocal.height)
        
        return Rect(
            x: center.x,
            y: center.y,
            width: w,
            height: h
        )
    }
    
    private struct ClipTranslation {
        let stretch: Rect
        let fixed: Rect
    }
    
    private func clipTranslate(screen translation: CGSize) -> ClipTranslation {
        let localTrans = -1 * transform.screenToLocal(size: translation)
        let worldTrans = transform.localToWorld(size: localTrans)
        let newWorld = cropWorld.translate(size: worldTrans)
        let clip = self.rectClip(world: newWorld)
        guard clip.isOverlap else {
            return ClipTranslation(stretch: newWorld, fixed: newWorld)
        }
        
        let localSize = transform.worldToLocal(size: Size(vector: clip.vector))
        let worldStretch = worldTrans + transform.localToWorld(size: localSize.stretch)
        let worldFixed = worldTrans + transform.localToWorld(size: localSize)
        
        let stretch = cropWorld.translate(size: worldStretch)
        let fixed = cropWorld.translate(size: worldFixed)
        
        return ClipTranslation(stretch: stretch, fixed: fixed)
    }

    private func translate(corner: Rect.Corner.Layout, screen translation: CGSize) -> Rect {
        var rect = nextLocal
        
        let fixed = rect.corner(layout: rect.opossite(layout: corner))
        let fixedWorld = transform.localToWorld(point: fixed.point) + cropWorld.center
        
        let trans = transform.screenToLocal(size: translation)
        var float = rect.cornerPoint(layout: corner) + trans
        let floatWorld = transform.localToWorld(point: float) + cropWorld.center

        // clip float corner
        
        let clip = self.clip(point: floatWorld)
        if clip.isOverlap {
            float = transform.worldToLocal(point: clip.point - cropWorld.center)
        }
        
        rect = Rect(fixed: fixed.point, float: float)
        
        let cw = rect.corner(layout: rect.clockWise(layout: corner))
        let cwWorld = transform.localToWorld(point: cw.point) + cropWorld.center
        
        var ccw = rect.corner(layout: rect.counterClockWise(layout: corner))
        
        let cwClip = self.clip(fixed: fixedWorld, float: cwWorld)
        
        if cwClip.isOverlap {
            let local = transform.worldToLocal(point: cwClip.point - cropWorld.center)
            rect = Rect(fixed: fixed, float: .init(layout: cw.layout, point: local), other: ccw)
            ccw = rect.corner(layout: rect.counterClockWise(layout: corner))
        }
        
        let ccwWorld = transform.localToWorld(point: ccw.point) + cropWorld.center
        let ccwClip = self.clip(fixed: fixedWorld, float: ccwWorld)

        if ccwClip.isOverlap {
            let local = transform.worldToLocal(point: ccwClip.point - cropWorld.center)
            rect = Rect(fixed: fixed, float: .init(layout: ccw.layout, point: local), other: cw)
        }

        // clip size
        let worldSize = transform.localToWorld(size: rect.size)
        if worldSize.width < minWorldSize.width || worldSize.height < minWorldSize.height {
            let width = max(worldSize.width, minWorldSize.width)
            let height = max(worldSize.height, minWorldSize.height)

            let localSize = transform.worldToLocal(size: Size(width: width, height: height))

            rect = Rect(corner: rect.corner(layout: fixed.layout), size: localSize)
        }

        return rect
    }

}


private extension Rect {
    
    func modify(corner: Corner.Layout, translation: Size) -> Rect {

        let x: Float
        let y: Float
        let w: Float
        let h: Float

        switch corner {
        case .topLeft:
            w = max(width - translation.width, minLocalSize.width)
            h = max(height + translation.height, minLocalSize.height)

            let x0 = center.x + 0.5 * width
            let y0 = center.y - 0.5 * height
            
            x = x0 - 0.5 * w
            y = y0 + 0.5 * h
        case .topRight:
            w = max(width + translation.width, minLocalSize.width)
            h = max(height + translation.height, minLocalSize.height)
            
            let x0 = center.x - 0.5 * width
            let y0 = center.y - 0.5 * height
            
            x = x0 + 0.5 * w
            y = y0 + 0.5 * h
        case .bottomLeft:
            w = max(width - translation.width, minLocalSize.width)
            h = max(height - translation.height, minLocalSize.height)

            let x0 = center.x + 0.5 * width
            let y0 = center.y + 0.5 * height
            
            x = x0 - 0.5 * w
            y = y0 - 0.5 * h
        case .bottomRight:
            w = max(width + translation.width, minLocalSize.width)
            h = max(height - translation.height, minLocalSize.height)

            let x0 = center.x - 0.5 * width
            let y0 = center.y + 0.5 * height
            
            x = x0 + 0.5 * w
            y = y0 - 0.5 * h
        }
        
        return Rect(x: x, y: y, width: w, height: h)
    }
    
    init(fixed: Vector2, float: Vector2) {
        let delta = fixed - float
        let size = Size(width: abs(delta.x), height: abs(delta.y))
        let center = 0.5 * (fixed + float)
        
        self.init(center: center, size: size)
    }
    
    init(corner: Corner, size: Size) {
        let x: Float
        let y: Float
        let dx = 0.5 * size.width
        let dy = 0.5 * size.height
        
        
        switch corner.layout {
        case .topLeft:
            x = corner.point.x + dx
            y = corner.point.y - dy
        case .topRight:
            x = corner.point.x - dx
            y = corner.point.y - dy
        case .bottomLeft:
            x = corner.point.x + dx
            y = corner.point.y + dy
        case .bottomRight:
            x = corner.point.x - dx
            y = corner.point.y + dy
        }
        
        self.init(x: x, y: y, width: size.width, height: size.height)
    }
    
    init(fixed a: Corner, float b: Corner, other c: Corner) {
        let side = [a.layout, b.layout]
        
        let width: Float
        let height: Float
        
        if side.contains(.bottomLeft) && side.contains(.bottomRight) ||
            side.contains(.topLeft) && side.contains(.topRight) {
            width = abs(a.point.x - b.point.x)
            height = abs(a.point.y - c.point.y)
        } else {
            width = abs(a.point.x - c.point.x)
            height = abs(a.point.y - b.point.y)
        }
        
        let center = 0.5 * (b.point + c.point)
        
        self.init(center: center, width: width, height: height)
    }
    
    
}

private extension Float {
    
    var stretch: Float {
        let x = self
        let a = abs(x)
        return x * (1 - 0.5 / (0.005 * a + 1))
    }
}

private extension Size {
    
    var stretch: Size {
        Size(width: width.stretch, height: height.stretch)
    }

}
