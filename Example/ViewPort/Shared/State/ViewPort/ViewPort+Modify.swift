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
        let corner: Corner
    }
    
    func isCorner(point: CGPoint, sqrRadius: CGFloat) -> Corner? {
        let p = transform.screenToLocal(point: point)
        
        let points = cropLocal.points
        
        let distanceList = [
            Distance(sqrDist: p.sqrDistance(points[0]), corner: .bottomLeft),
            Distance(sqrDist: p.sqrDistance(points[1]), corner: .topLeft),
            Distance(sqrDist: p.sqrDistance(points[2]), corner: .topRight),
            Distance(sqrDist: p.sqrDistance(points[3]), corner: .bottomRight)
        ]
        
        guard let nearest = distanceList.sorted(by: { $0.sqrDist < $1.sqrDist }).first else { return nil }

        if nearest.sqrDist < Float(sqrRadius) {
            return nearest.corner
        }
        
        return nil
    }
    
    func isInside(point: CGPoint) -> Bool {
        let local = transform.screenToLocal(point: point)
        return cropLocal.isContain(point: local)
    }
    
    mutating func move(translation: CGSize) {
        let trans = transform.screenToLocal(size: translation)
        self.cropView = nextLocal.translate(size: trans)
    }
    
    mutating func move(corner: Corner, translation: CGSize) {
        let trans = transform.screenToLocal(size: translation)
        self.cropView = nextLocal.morph(corner: corner, translation: trans)
    }
    
    mutating func endMove(translation: CGSize) {
        let trans = transform.screenToLocal(size: translation)
        let newRect = nextLocal.translate(size: trans)

        self.translate(newLocal: newRect)
        
        self.animate()
    }

    mutating func endMove(corner: Corner, translation: CGSize) {
        let trans = transform.screenToLocal(size: translation)
        let newRect = nextLocal.morph(corner: corner, translation: trans)
        
        self.update(newLocal: newRect)
        
        self.animate()
    }
    
    mutating func animate() {
        let maxCropLocal = Self.calcMaxLocalCrop(viewSize: viewSize, worldSize: nextWorld.size, inset: inset)
        
        self.cropLocal = maxCropLocal
        self.cropView = cropLocal
        self.nextLocal = cropLocal
        self.cropWorld = nextWorld
        
        worldView = Self.calcWorldView(viewSize: viewSize, localRect: cropLocal, worldRect: nextWorld)
        
        // DEBUG --------------------
        let matrix = self.debugMatrix(viewSize: viewSize)
        debugView = worldView.transform(matrix: matrix)
    }
    
    private mutating func update(newLocal: Rect) {
        nextWorld = Rect.newWorld(
            oldLocal: cropLocal,
            newLocal: newLocal,
            oldWorld: cropWorld
        )

        cropView = newLocal
        nextLocal = newLocal
        
        // DEBUG --------------------
        
        let matrix = self.debugMatrix(viewSize: viewSize)
        debugCamera = nextWorld.transform(matrix: matrix)
    }

    private mutating func translate(newLocal: Rect) {
        let dx = newLocal.center.x - cropLocal.center.x
        let dy = newLocal.center.y - cropLocal.center.y
        let trans = transform.localToWorld(size: Size(width: dx, height: dy))
        
        let x = nextWorld.center.x + trans.width
        let y = nextWorld.center.y + trans.height
        
        nextWorld.center = .init(x: x, y: y)

        cropView = newLocal
        nextLocal = newLocal
        
        // DEBUG --------------------
        
        let matrix = self.debugMatrix(viewSize: viewSize)
        debugCamera = nextWorld.transform(matrix: matrix)
    }
    
}


private extension Rect {
    
    func morph(corner: ViewPort.Corner, translation: Size) -> Rect {

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
