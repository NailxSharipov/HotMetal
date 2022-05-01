//
//  ViewPort+Modify.swift
//  ViewPort
//
//  Created by Nail Sharipov on 25.04.2022.
//

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
        let trans = transform.screenToLocal(size: translation)
        self.cropView = nextLocal.modify(corner: corner, translation: trans)
    }
    
    mutating func endMove(corner: Rect.Corner.Layout, translation: CGSize) {
        let trans = transform.screenToLocal(size: translation)
        let newRect = nextLocal.modify(corner: corner, translation: trans)
        
        self.update(newLocal: newRect)
        
        self.animate()
    }
    
    // move Body
    
    func isInside(point: CGPoint) -> Bool {
        let local = transform.screenToLocal(point: point)
        return cropLocal.isContain(point: local)
    }

    mutating func move(translation: CGSize) {
        let trans = transform.screenToLocal(size: translation)
        self.cropView = nextLocal.translate(size: trans)
    }
    
    mutating func endMove(translation: CGSize) {
        let trans = transform.screenToLocal(size: translation)
        let newRect = nextLocal.translate(size: trans)

        self.update(newLocal: newRect)
        
        self.animate()
    }
    
    mutating func animate() {
        let maxCropLocal = Self.calcMaxLocalCrop(viewSize: viewSize, worldSize: nextWorld.size, inset: inset)
        
        self.cropLocal = maxCropLocal
        self.cropView = cropLocal
        self.nextLocal = cropLocal
        self.cropWorld = nextWorld
        
        transform = .init(viewSize: viewSize, local: cropLocal, world: cropWorld, angle: angle)
    }
    
    private mutating func update(newLocal: Rect) {
        let dx = newLocal.center.x - cropLocal.center.x
        let dy = newLocal.center.y - cropLocal.center.y
        
        let dSize = transform.localToWorld(size: Size(width: dx, height: dy))

        let x = cropWorld.center.x + dSize.width
        let y = cropWorld.center.y + dSize.height
        
        let w = transform.scaleLocalToWorld(newLocal.width)
        let h = transform.scaleLocalToWorld(newLocal.height)
        
        nextWorld = Rect(
            x: x,
            y: y,
            width: w,
            height: h
        )

        cropView = newLocal
        nextLocal = newLocal
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
