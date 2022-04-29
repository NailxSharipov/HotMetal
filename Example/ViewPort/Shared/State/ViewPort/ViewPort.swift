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
    
    let imageSize: CGSize
    
    private (set) var viewSize: CGSize      // full view size
    
    var toWorld: Matrix3 = .identity
    
    var cropWorld: CGRect = .zero           // crop rectangle in world coord system
    var cropNextWorld: CGRect = .zero       // crop rectangle at next step (after animation) in world coord system
    var cropLocal: CGRect = .zero           // crop rectangle in view coord system
    var cropNextLocal: CGRect = .zero       // crop rectangle at next step (after animation) in view coord system
    var cropView: CGRect = .zero            // crop rectangle at this moment even while editing in view coord system

    var debugCameraView: [CGPoint] = []
    var debugWorldView: [CGPoint] = []
    
    
    private (set) var ratio: Ratio = .free
    private (set) var inset: CGFloat
    private (set) var angle: Float = 0
    
    var orient: Orientation = .square
    
    init(imageSize: CGSize, viewSize: CGSize, inset: CGFloat = 64) {
        self.imageSize = imageSize
        self.viewSize = viewSize
        self.inset = inset
        guard imageSize.height > 0 else {
            return
        }

        self.cropWorld = CGRect(
            origin: .init(
                x: -0.5 * imageSize.width,
                y: -0.5 * imageSize.height
            ),
            size: imageSize
        )
        
        self.cropNextWorld = cropWorld
        self.cropLocal = Self.calcMaxLocalCrop(viewSize: viewSize, imageSize: cropNextWorld.size, inset: inset)
        self.cropView = cropLocal
        self.cropNextLocal = cropLocal
    }
    
    mutating func set(viewSize: CGSize) {
        self.orient = Orientation(outerRect: viewSize, innerRect: cropNextLocal.size)
        self.viewSize = viewSize
        let maxCropLocal = Self.calcMaxLocalCrop(viewSize: viewSize, imageSize: cropNextWorld.size, inset: inset)
        self.cropLocal = maxCropLocal
        self.cropView = cropLocal
        self.cropNextLocal = cropLocal
        
        let matrix = self.debugMatrix(viewSize: viewSize)
        self.debugWorldView = self.debugWorld(matrix: matrix, viewSize: viewSize)
        self.debugCameraView = cropNextWorld.transform(matrix: matrix)
        
        
        print("cropWorld: \(cropNextWorld)")
        print("cropView: \(cropView)")
    }
    
    static func calcMaxLocalCrop(viewSize: CGSize, imageSize: CGSize, inset: CGFloat) -> CGRect {
        let insetViewSize = CGSize(width: viewSize.width - 2 * inset, height: viewSize.height - 2 * inset)
        
        let orient = Orientation(outerRect: insetViewSize, innerRect: imageSize)
        
        let newRect: CGRect

        switch orient {
        case .fullSizeWidth:
            let width = insetViewSize.width
            let height = width * imageSize.height / imageSize.width
            newRect = CGRect(
                x: inset,
                y: inset + 0.5 * (insetViewSize.height - height),
                width: width,
                height: height
            )
        case .fullSizeHeight:
            let height = insetViewSize.height
            let width = height * imageSize.width / imageSize.height
            newRect = CGRect(
                x: inset + 0.5 * (insetViewSize.width - width),
                y: inset,
                width: width,
                height: height
            )
        case .square:
            newRect = CGRect(
                x: inset,
                y: inset,
                width: insetViewSize.width,
                height: insetViewSize.height
            )
        }

        return newRect
    }
    
    
    private func debugWorld(matrix: float3x3, viewSize: CGSize) -> [CGPoint] {
        let rect = CGRect(
            x: -0.5 * imageSize.width,
            y: -0.5 * imageSize.height,
            width: imageSize.width,
            height: imageSize.height
        )

        return rect.transform(matrix: matrix)
    }
    
    func debugMatrix(viewSize: CGSize) -> float3x3 {
        let cx = Float(0.5 * viewSize.width)
        let cy = Float(0.5 * viewSize.height)
        
        let s: Float = 0.5
        
        return float3x3(
            .init(  s,  0,   0),
            .init(  0,  s,   0),
            .init( cx, cy,   1)
        )
    }
    
}
