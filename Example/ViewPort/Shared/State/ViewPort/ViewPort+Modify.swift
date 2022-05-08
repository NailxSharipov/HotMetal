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
        guard modeState == .idle else { return nil }

        let p = transform.screenToLocal(point: point)
        
        let distanceList = nextLocal.corners.map({ Distance(sqrDist: $0.point.sqrDistance(p), corner: $0.layout) })
        
        guard let nearest = distanceList.sorted(by: { $0.sqrDist < $1.sqrDist }).first else { return nil }

        if nearest.sqrDist < Float(sqrRadius) {
            return nearest.corner
        }
        
        return nil
    }

    mutating func move(corner: Rect.Corner.Layout, translation: CGSize) {
        modeState = .corner
        self.cropView = self.translate(corner: corner, screen: translation)
    }
    
    mutating func endMove(corner: Rect.Corner.Layout, translation: CGSize) {
        let newLocal = self.translate(corner: corner, screen: translation)
        cropView = newLocal
        nextLocal = newLocal
        nextWorld = self.world(newLocal: newLocal)

        // TODO
        // после таймера закончить
        
        // обновить cropLocal
        modeState = .idle
    }
    
    // move Body
    
    func isInside(point: CGPoint) -> Bool {
        guard modeState == .idle else { return false }
        let local = transform.screenToLocal(point: point)
        return nextLocal.isContain(point: local)
    }

    mutating func move(translation: CGSize) {
        modeState = .body
        cropWorld = self.clipTranslate(screen: translation).stretch
    }
    
    mutating func endMove(translation: CGSize) {
        cropWorld = self.clipTranslate(screen: translation).fixed
        transform = CoordSystemTransformer(viewSize: viewSize, local: cropLocal, world: cropWorld, angle: angle)
        modeState = .idle
    }
    
    // rotate
    
    mutating func set(angle: Float) {
        guard modeState == .idle else { return }
        self.angle = angle

        let newWorld = world(newLocal: cropLocal)
        let clip = self.scaleClip(world: newWorld)
        if case let .overlap(rect) = clip {
            cropWorld = rect
        } else {
            cropWorld = newWorld
        }
        
        let maxCropLocal = Self.calcMaxLocalCrop(viewSize: viewSize, worldSize: cropWorld.size, inset: inset)
        
        cropLocal = maxCropLocal
        cropView = cropLocal
        nextLocal = cropLocal

        transform = CoordSystemTransformer(viewSize: viewSize, local: cropLocal, world: cropWorld, angle: angle)
    }
    
//    mutating func animate() {
//        let maxCropLocal = Self.calcMaxLocalCrop(viewSize: viewSize, worldSize: cropWorld.size, inset: inset)
//
//        self.cropLocal = maxCropLocal
//        self.cropView = cropLocal
//        self.nextLocal = cropLocal
//
//        transform = .init(viewSize: viewSize, local: cropLocal, world: cropWorld, angle: angle)
//    }

    private func world(newLocal: Rect) -> Rect {
        let center = transform.localToWorld(point: newLocal.center)

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
        let newWorld = nextWorld.translate(size: worldTrans)
        let clip = self.rectClip(world: newWorld)
        guard clip.isOverlap else {
            return ClipTranslation(stretch: newWorld, fixed: newWorld)
        }
        
        let localSize = transform.worldToLocal(size: Size(vector: clip.vector))
        let worldStretch = worldTrans + transform.localToWorld(size: localSize.stretch)
        let worldFixed = worldTrans + transform.localToWorld(size: localSize)
        
        let stretch = nextWorld.translate(size: worldStretch)
        let fixed = nextWorld.translate(size: worldFixed)
        
        return ClipTranslation(stretch: stretch, fixed: fixed)
    }

    private func translate(corner: Rect.Corner.Layout, screen translation: CGSize) -> Rect {
        var rect = nextLocal
        
        let fixed = rect.corner(layout: rect.opossite(layout: corner))
        let fixedWorld = transform.localToWorld(point: fixed.point)
        
        let trans = transform.screenToLocal(size: translation)
        var float = rect.cornerPoint(layout: corner) + trans
        let floatWorld = transform.localToWorld(point: float)

        // clip float corner
        
        let clip = self.clip(point: floatWorld)
        if clip.isOverlap {
            float = transform.worldToLocal(point: clip.point)
        }
        
        rect = Rect(a: fixed.point, b: float)
        
        let cw = rect.corner(layout: rect.clockWise(layout: corner))
        let cwWorld = transform.localToWorld(point: cw.point)

        let ccw = rect.corner(layout: rect.counterClockWise(layout: corner))
        let ccwWorld = transform.localToWorld(point: ccw.point)
        
        let cwClip = self.clip(fixed: fixedWorld, float: cwWorld)
        let ccwClip = self.clip(fixed: fixedWorld, float: ccwWorld)
        
        if cwClip.isOverlap || ccwClip.isOverlap {
            let a = transform.worldToLocal(point: cwClip.point)
            let b = transform.worldToLocal(point: ccwClip.point)
            rect = Rect(a: a, b: b)
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
    
    init(a: Vector2, b: Vector2) {
        let ab = a - b
        let size = Size(width: abs(ab.x), height: abs(ab.y))
        let center = 0.5 * (a + b)
        
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
    
    var rounded: Rect {
        let x = center.x.rounded
        let y = center.y.rounded
        let width = width.rounded
        let height = height.rounded
        
        return Rect(x: x, y: y, width: width, height: height)
    }
}

private extension Float {
    
    var stretch: Float {
        let x = self
        let a = abs(x)
        return x * (1 - 0.5 / (0.005 * a + 1))
    }
    
    var rounded: Float {
        0.5 * (self * 2).rounded(.toNearestOrAwayFromZero)
    }
}

private extension Size {
    
    var stretch: Size {
        Size(width: width.stretch, height: height.stretch)
    }

}
