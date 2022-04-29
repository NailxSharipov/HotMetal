//
//  ViewPort+Drag.swift
//  ViewPort
//
//  Created by Nail Sharipov on 25.04.2022.
//

import HotMetal
import CoreGraphics

let minSize = CGSize(width: 64, height: 64)

extension ViewPort {

    private struct Distance {
        let sqrDist: CGFloat
        let corner: Corner
    }
    
    func isCorner(point: CGPoint, sqrRadius: CGFloat) -> Corner? {
        guard let nearest = [
            Distance(sqrDist: point.sqrDistance(cropView.topLeft), corner: .topLeft),
            Distance(sqrDist: point.sqrDistance(cropView.bottomLeft), corner: .bottomLeft),
            Distance(sqrDist: point.sqrDistance(cropView.topRight), corner: .topRight),
            Distance(sqrDist: point.sqrDistance(cropView.bottomRight), corner: .bottomRight)
        ].sorted(by: { $0.sqrDist < $1.sqrDist }).first
        else { return nil }
        
        if nearest.sqrDist < sqrRadius {
            return nearest.corner
        }
        
        return nil
    }
    
    func isInside(point: CGPoint) -> Bool {
        self.cropLocal.contains(point)
    }
    
    mutating func move(translation: CGSize) {
        self.cropView = cropNextLocal.translate(size: translation)
//        self.cropView = cropNextLocal.translate(size: CGSize(width: 0.5 * cropView.width, height: 0))
    }
    
    mutating func endMove(translation: CGSize) {
        let newRect = cropNextLocal.translate(size: translation)
        
        let dx = cropWorld.width * translation.width / cropNextLocal.width
        let dy = cropWorld.height * translation.height / cropNextLocal.height
        
        
        self.cropNextWorld = cropWorld.translate(size: CGSize(width: dx, height: dy))
        cropView = newRect
        cropNextLocal = newRect
        
        let matrix = self.debugMatrix(viewSize: viewSize)
        self.debugCameraView = cropNextWorld.transform(matrix: matrix)
    }
    
    mutating func move(corner: Corner, translation: CGSize) {
        self.cropView = cropNextLocal.morph(corner: corner, translation: translation)
    }

    mutating func endMove(corner: Corner, translation: CGSize) {
        cropView = cropNextLocal.morph(corner: corner, translation: translation)
        cropNextWorld = cropWorld.morph(corner: corner, oldRect: cropLocal, newRect: cropView)
        cropNextLocal = cropView
        
        let matrix = self.debugMatrix(viewSize: viewSize)
        self.debugCameraView = cropNextWorld.transform(matrix: matrix)
    }
    
    mutating func animate() {
        self.orient = Orientation(outerRect: viewSize, innerRect: cropNextLocal.size)

        let maxCropLocal = Self.calcMaxLocalCrop(viewSize: viewSize, imageSize: cropNextWorld.size, inset: inset)
        self.cropLocal = maxCropLocal
        self.cropView = cropLocal
        self.cropNextLocal = cropLocal
        self.cropWorld = cropNextWorld
        
        print("animate")
    }
    
}

private extension CGPoint {
    
    func sqrDistance(_ point: CGPoint) -> CGFloat {
        let dx = x - point.x
        let dy = y - point.y
        
        return dx * dx + dy * dy
    }

}

private extension CGRect {
    
    func morph(corner: ViewPort.Corner, translation: CGSize) -> CGRect {
        switch corner {
        case .topLeft:
            let aWidth = max(width - translation.width, minSize.width)
            let aHeight = max(height - translation.height, minSize.height)

            let p = bottomRight
            
            let x = p.x - aWidth
            let y = p.y - aHeight
            
            return CGRect(x: x, y: y, width: aWidth, height: aHeight)
        case .topRight:
            let aWidth = max(width + translation.width, minSize.width)
            let aHeight = max(height - translation.height, minSize.height)

            let p = bottomLeft
            
            let y = p.y - aHeight
            
            return CGRect(x: p.x, y: y, width: aWidth, height: aHeight)
        case .bottomLeft:
            let aWidth = max(width - translation.width, minSize.width)
            let aHeight = max(height + translation.height, minSize.height)

            let p = topRight
            
            let x = p.x - aWidth
            
            return CGRect(x: x, y: p.y, width: aWidth, height: aHeight)
        case .bottomRight:
            let aWidth = max(width + translation.width, minSize.width)
            let aHeight = max(height + translation.height, minSize.height)

            let p = topLeft

            return CGRect(x: p.x, y: p.y, width: aWidth, height: aHeight)
        }
    }
    
    func morph(corner: ViewPort.Corner, oldRect: CGRect, newRect: CGRect) -> CGRect {
        let sw = newRect.width / oldRect.width
        let sh = newRect.height / oldRect.height
        
        let aWidth = sw * width
        let aHeight = sh * height
        
        switch corner {
        case .topLeft:
            let p = bottomRight
            
            let x = p.x - aWidth
            let y = p.y - aHeight
            
            return CGRect(x: x, y: y, width: aWidth, height: aHeight)
        case .topRight:
            let p = bottomLeft
            
            let y = p.y - aHeight
            
            return CGRect(x: p.x, y: y, width: aWidth, height: aHeight)
        case .bottomLeft:
            let p = topRight
            
            let x = p.x - aWidth
            
            return CGRect(x: x, y: p.y, width: aWidth, height: aHeight)
        case .bottomRight:
            let p = topLeft

            return CGRect(x: p.x, y: p.y, width: aWidth, height: aHeight)
        }
        
    }
    
}
