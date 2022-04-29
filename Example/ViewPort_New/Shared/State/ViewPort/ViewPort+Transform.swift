//
//  ViewPort+Transform.swift
//  ViewPort
//
//  Created by Nail Sharipov on 25.04.2022.
//

import HotMetal
import CoreGraphics

let minSize = Size(width: 64, height: 64)

extension ViewPort {

    private struct Distance {
        let sqrDist: Float
        let corner: Corner
    }
    
    func isCorner(point: CGPoint, sqrRadius: CGFloat) -> Corner? {
        let p = toLocal(screen: point)
        
        let points = cropView.points
        
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
        let local = toLocal(screen: point)
        return cropLocal.isContain(point: local)
    }
    
    mutating func move(translation: CGSize) {
        let trans = toLocal(size: translation)
        self.cropView = cropNextLocal.translate(size: trans)
    }
    
    mutating func move(corner: Corner, translation: CGSize) {
        let trans = toLocal(size: translation)
        self.cropView = cropNextLocal.morph(corner: corner, translation: trans)
    }
    
    mutating func endMove(translation: CGSize) {
        let trans = toLocal(size: translation)
        let newRect = cropNextLocal.translate(size: trans)

        self.update(newLocal: newRect)
        
        self.animate()
    }

    mutating func endMove(corner: Corner, translation: CGSize) {
        let trans = toLocal(size: translation)
        let newRect = cropNextLocal.morph(corner: corner, translation: trans)
        
        self.update(newLocal: newRect)
        
        self.animate()
    }
    
    mutating func animate() {
        self.orient = Orientation(outerRect: viewSize, innerRect: cropNextLocal.size)
        let maxCropLocal = Self.calcMaxLocalCrop(viewSize: viewSize, worldSize: cropNextWorld.size, inset: inset)
        
        self.cropLocal = maxCropLocal
        self.cropView = cropLocal
        self.cropNextLocal = cropLocal
        self.cropWorld = cropNextWorld
    }
    
    mutating func update(newLocal: Rect) {
        cropNextWorld = Rect.newWorld(
            oldLocal: cropLocal,
            newLocal: newLocal,
            oldWorld: cropWorld
        )

        cropView = newLocal
        cropNextLocal = newLocal
        
        // DEBUG --------------------
        
        let matrix = self.debugMatrix(viewSize: viewSize)
        self.debugCameraView = cropNextWorld.transform(matrix: matrix)
    }
    
    mutating func set(angle: Float) {
        cropNextWorld.angle = angle
        cropWorld = cropNextWorld

        // DEBUG --------------------
        
        let matrix = self.debugMatrix(viewSize: viewSize)
        self.debugCameraView = cropNextWorld.transform(matrix: matrix)
    }
    
}

private extension CGPoint {
    
    func sqrDistance(_ point: CGPoint) -> CGFloat {
        let dx = x - point.x
        let dy = y - point.y
        
        return dx * dx + dy * dy
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
