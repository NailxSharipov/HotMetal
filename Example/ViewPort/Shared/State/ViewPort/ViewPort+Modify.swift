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

let minSize = Size(width: 64, height: 64)

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
        self.cropView = self.translate(local: nextLocal, screen: translation)
    }
    
    mutating func endMove(translation: CGSize) {
        var newLocal = self.translate(local: nextLocal, screen: translation)

        let world = world(newLocal: newLocal)
        let clip = self.isClip(world: world)
        guard clip.isOverlap else {

            nextWorld = self.world(newLocal: newLocal)
            cropView = newLocal
            nextLocal = newLocal
            
            animate()
            return
        }

        let dSize = transform.worldToLocal(size: Size(vector: clip.vector))

        newLocal.center = newLocal.center + dSize
        
        nextWorld = self.world(newLocal: newLocal)
        cropView = newLocal
        nextLocal = newLocal
        
        animate()
    }
    
    // rotate
    
    mutating func set(angle: Float) {
        self.angle = angle

        let newWorld = world(newLocal: cropLocal)
        let clip = self.scaleClip(world: newWorld)
        if case let .overlap(rect) = clip {
            cropWorld = rect
        } else {
            cropWorld = newWorld
        }
        nextWorld = cropWorld
        
        let maxCropLocal = Self.calcMaxLocalCrop(viewSize: viewSize, worldSize: nextWorld.size, inset: inset)
        
        cropLocal = maxCropLocal
        cropView = cropLocal
        nextLocal = cropLocal

        transform = CoordSystemTransformer(viewSize: viewSize, local: cropLocal, world: cropWorld, angle: angle)
    }
    
    mutating func animate() {
        let maxCropLocal = Self.calcMaxLocalCrop(viewSize: viewSize, worldSize: nextWorld.size, inset: inset)
        
        self.cropLocal = maxCropLocal
        self.cropView = cropLocal
        self.nextLocal = cropLocal
        self.cropWorld = nextWorld
        
        transform = .init(viewSize: viewSize, local: cropLocal, world: cropWorld, angle: angle)
    }

    private func world(newLocal: Rect) -> Rect {
        let dCenter = newLocal.center - nextLocal.center
        
        let dSize = transform.localToWorld(size: Size(vector: dCenter))

        let center = cropWorld.center + dSize
        
        let w = transform.scaleLocalToWorld(newLocal.width)
        let h = transform.scaleLocalToWorld(newLocal.height)
        
        return Rect(
            x: center.x,
            y: center.y,
            width: w,
            height: h
        )
    }
    
    private func translate(local rect: Rect, screen translation: CGSize) -> Rect {
        let trans = transform.screenToLocal(size: translation)
        let newLocal = rect.translate(size: trans)
        let newWorld = world(newLocal: newLocal)
        let clip = self.isClip(world: newWorld)
        guard clip.isOverlap else {
            return newLocal
        }
        
        let dSize = transform.worldToLocal(size: Size(vector: clip.vector))
        
        let width = trans.width + dSize.width.stretch
        let height = trans.height + dSize.height.stretch
        
        return rect.translate(size: Size(width: width, height: height))
    }

    private func translate(corner: Rect.Corner.Layout, screen translation: CGSize) -> Rect {
        let trans = transform.screenToLocal(size: translation)
        let newCorner = nextLocal.corner(layout: corner) + trans
        let worldCorner = transform.localToWorld(point: newCorner) + cropWorld.center
        let clip = self.clip(point: worldCorner)
        guard clip.isOverlap else {
            return nextLocal.modify(corner: corner, translation: trans)
        }
        
        let dSize = transform.worldToLocal(size: clip.delta)
        
        let clipTrans = trans - dSize
        
        return nextLocal.modify(corner: corner, translation: clipTrans)
    }
    
//    private func animate(rect: Rect, translate: Size) {
//        withAnimation(.linear(duration: 1)) {
//
//        }
//    }
//
}


private extension Rect {
    
    func modify(corner: Corner.Layout, translation: Size) -> Rect {

        let x: Float
        let y: Float
        let w: Float
        let h: Float

        switch corner {
        case .topLeft:
            w = max(width - translation.width, minSize.width)
            h = max(height + translation.height, minSize.height)

            let x0 = center.x + 0.5 * width
            let y0 = center.y - 0.5 * height
            
            x = x0 - 0.5 * w
            y = y0 + 0.5 * h
        case .topRight:
            w = max(width + translation.width, minSize.width)
            h = max(height + translation.height, minSize.height)
            
            let x0 = center.x - 0.5 * width
            let y0 = center.y - 0.5 * height
            
            x = x0 + 0.5 * w
            y = y0 + 0.5 * h
        case .bottomLeft:
            w = max(width - translation.width, minSize.width)
            h = max(height - translation.height, minSize.height)

            let x0 = center.x + 0.5 * width
            let y0 = center.y + 0.5 * height
            
            x = x0 - 0.5 * w
            y = y0 - 0.5 * h
        case .bottomRight:
            w = max(width + translation.width, minSize.width)
            h = max(height - translation.height, minSize.height)

            let x0 = center.x - 0.5 * width
            let y0 = center.y + 0.5 * height
            
            x = x0 + 0.5 * w
            y = y0 - 0.5 * h
        }
        
        return Rect(x: x, y: y, width: w, height: h)
    }
    
}

private extension Float {
    
    var stretch: Float {
        let x = self
        let a = abs(x)
        return x * (1 - 0.5 / (0.005 * a + 1))
    }

}
