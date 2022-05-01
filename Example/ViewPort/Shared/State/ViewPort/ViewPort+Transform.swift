//
//  ViewPort+Transform.swift
//  ViewPort
//
//  Created by Nail Sharipov on 25.04.2022.
//

import HotMetal
import CoreGraphics
import simd

let minSize = Size(width: 64, height: 64)

extension ViewPort {

    struct LocalScreenTransform {
        
        private let localToScreenAbs: float3x3
        private let screenToLocalAbs: float3x3
        private let localToScreenRel: float3x3
        private let screenToLocalRel: float3x3
        
        init(viewSize: Size, angle: Float) {
            let tx = 0.5 * viewSize.width
            let ty = 0.5 * viewSize.height
            
            let s = float3x3(
                .init(  1,  0,  0),
                .init(  0, -1,  0),
                .init(  0,  0,  1)
            )

            let cs: Float = cos(angle)
            let sn: Float = sin(angle)
            
            let r = float3x3(
                .init( cs, sn,  0),
                .init(-sn, cs,  0),
                .init( 0,   0,  1)
            )

            let t = float3x3(
                .init(  1,  0,  0),
                .init(  0,  1,  0),
                .init( tx, ty,  1)
            )

            let m0 = simd_mul(t, r)
            let m1 = simd_mul(m0, s)
            
            self.localToScreenAbs = m1
            self.screenToLocalAbs = localToScreenAbs.inverse
            
            self.localToScreenRel = simd_mul(t, s)
            self.screenToLocalRel = localToScreenRel.inverse
        }
        
        func toLocalRel(point p: CGPoint) -> Vector2 {
            let v0 = Vector3(x: Float(p.x), y: Float(p.y), z: 1)
            let v1 = simd_mul(screenToLocalRel, v0)
            return Vector2(x: v1.x, y: v1.y)
        }

        func toLocalAbs(size s: CGSize) -> Size {
            let v0 = Vector3(x: Float(s.width), y: Float(s.height), z: 0)
            let v1 = simd_mul(screenToLocalAbs, v0)
            return Size(width: v1.x, height: v1.y)
        }
        
        func toLocalRel(size s: CGSize) -> Size {
            let v0 = Vector3(x: Float(s.width), y: Float(s.height), z: 0)
            let v1 = simd_mul(screenToLocalRel, v0)
            return Size(width: v1.x, height: v1.y)
        }
        
        func toScreenRel(point p: Vector2) -> Vector2 {
            let v0 = Vector3(x: p.x, y: p.y, z: 1)
            let v1 = simd_mul(localToScreenRel, v0)
            return Vector2(x: v1.x, y: v1.y)
        }
    }
    
    private struct Distance {
        let sqrDist: Float
        let corner: Corner
    }
    
    func isCorner(point: CGPoint, sqrRadius: CGFloat) -> Corner? {
        let p = transform.toLocalRel(point: point)
        
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
        let local = transform.toLocalRel(point: point)
        return cropLocal.isContain(point: local)
    }
    
    mutating func move(translation: CGSize) {
        let trans = transform.toLocalAbs(size: translation)
        self.cropView = nextLocal.translate(size: trans)
    }
    
    mutating func move(corner: Corner, translation: CGSize) {
        let trans = transform.toLocalRel(size: translation)
        print(trans)
        self.cropView = nextLocal.morph(corner: corner, translation: trans)
    }
    
    mutating func endMove(translation: CGSize) {
        let trans = transform.toLocalAbs(size: translation)
        let newRect = nextLocal.translate(size: trans)

        self.update(newLocal: newRect)
        
        self.animate()
    }

    mutating func endMove(corner: Corner, translation: CGSize) {
        let trans = transform.toLocalRel(size: translation)
        let newRect = nextLocal.morph(corner: corner, translation: trans)
        
        self.update(newLocal: newRect)
        
        self.animate()
    }
    
    mutating func animate() {
        self.orient = Orientation(outerRect: viewSize, innerRect: nextLocal.size)
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
