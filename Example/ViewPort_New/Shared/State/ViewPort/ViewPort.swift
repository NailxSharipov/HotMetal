//
//  ViewPort.swift
//  ViewPort
//
//  Created by Nail Sharipov on 21.04.2022.
//

import CoreGraphics
import HotMetal
import simd

struct ViewPort: Equatable {
    
    let imageSize: Size
    
    private (set) var viewSize: Size      // full view size
    
    var toWorld: Matrix3 = .identity
    
    var cropWorld: Rect = .zero           // crop rectangle in world coord system
    var cropNextWorld: Rect = .zero       // crop rectangle at next step (after animation) in world coord system
    var cropLocal: Rect = .zero           // crop rectangle in view coord system
    var cropNextLocal: Rect = .zero       // crop rectangle at next step (after animation) in view coord system
    var cropView: Rect = .zero            // crop rectangle at this moment even while editing in view coord system

    var debugCameraView: [CGPoint] = []
    var debugWorldView: [CGPoint] = []
    
    private (set) var ratio: Ratio = .free
    private (set) var inset: Float
    
    var orient: Orientation = .square
    
    init(imageSize: CGSize, viewSize: CGSize, inset: Float = 64) {
        self.imageSize = Size(size: imageSize)
        self.viewSize = Size(size: viewSize)
        self.inset = inset
        guard imageSize.height > 0 else {
            return
        }

        self.cropWorld = Rect(size: imageSize)
        self.cropNextWorld = cropWorld

        self.cropLocal = Self.calcMaxLocalCrop(viewSize: self.viewSize, worldSize: cropNextWorld.size, inset: inset)
        self.cropView = cropLocal
        self.cropNextLocal = cropLocal
    }
    
    mutating func set(viewSize: CGSize) {
        self.viewSize = Size(size: viewSize)
        self.orient = Orientation(outerRect: self.viewSize, innerRect: cropNextLocal.size)
        
        let maxCropLocal = Self.calcMaxLocalCrop(viewSize: self.viewSize, worldSize: cropNextWorld.size, inset: inset)
        debugPrint("vectors: \(maxCropLocal.points)")
        self.cropLocal = maxCropLocal
        self.cropView = cropLocal
        self.cropNextLocal = cropLocal
        
        // DEBUG --------------------
        
        let matrix = self.debugMatrix(viewSize: self.viewSize)
        self.debugWorldView = self.debugWorld(matrix: matrix)
        self.debugCameraView = cropNextWorld.transform(matrix: matrix)
    }
    
    static func calcMaxLocalCrop(viewSize: Size, worldSize: Size, inset: Float) -> Rect {
        let insetViewSize = Size(width: viewSize.width - 2 * inset, height: viewSize.height - 2 * inset)
        
        let orient = Orientation(outerRect: insetViewSize, innerRect: worldSize)
        
        let width: Float
        let height: Float

        switch orient {
        case .fullSizeWidth:
            width = insetViewSize.width
            height = width * worldSize.height / worldSize.width
        case .fullSizeHeight:
            height = insetViewSize.height
            width = height * worldSize.width / worldSize.height
        case .square:
            width = insetViewSize.width
            height = insetViewSize.height
        }

        return Rect(
            center: .zero,
            width: width,
            height: height
        )
    }
    
    func toLocal(screen: CGPoint) -> Vector2 {
        let x = Float(screen.x) - 0.5 * viewSize.width
        let y = 0.5 * viewSize.height - Float(screen.y)
        
        return Vector2(x: x, y: y)
    }
    
    func toLocal(size: CGSize) -> Size {
        Size(width: Float(size.width), height: -Float(size.height))
    }
    
    private func debugWorld(matrix: float3x3) -> [CGPoint] {
        let rect = Rect(
            x: 0,
            y: 0,
            width: imageSize.width,
            height: imageSize.height
        )

        return rect.transform(matrix: matrix)
    }
    
    func debugMatrix(viewSize: Size) -> float3x3 {
        let cx = 0.5 * viewSize.width
        let cy = 0.5 * viewSize.height
        
        let s: Float = 0.5
        
        return float3x3(
            .init(  s,  0,   0),
            .init(  0, -s,   0),
            .init( cx, cy,   1)
        )
    }
    
}
