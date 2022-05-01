//
//  ViewPort.swift
//  ViewPort
//
//  Created by Nail Sharipov on 21.04.2022.
//

import CoreGraphics
import HotMetal
import simd

struct ViewPort {
    
    let imageSize: Size
    
    private (set) var viewSize: Size      // full view size
    
    var cropWorld: Rect = .zero           // crop rectangle in world coord system
    var nextWorld: Rect = .zero           // crop rectangle at next step (after animation) in world coord system
    var cropLocal: Rect = .zero           // crop rectangle in view coord system
    var nextLocal: Rect = .zero           // crop rectangle at next step (after animation) in view coord system
    var cropView: Rect = .zero            // crop rectangle at this moment even while editing in view coord system
    var worldView: Rect = .zero           // screen view in world coord system

    var debugCamera: [CGPoint] = []
    var debugView: [CGPoint] = []
    var debugWorld: [CGPoint] = []

    private (set) var inset: Float
    private (set) var transform = CoordSystemTransformer()

//    var orient: Orientation = .square
    
    init(imageSize imgSize: CGSize, viewSize vSize: CGSize, ist: Float = 64) {
        imageSize = Size(size: imgSize)
        viewSize = Size(size: vSize)
        inset = ist
        guard imgSize.height > 0 else {
            return
        }

        cropWorld = Rect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        nextWorld = cropWorld

        cropLocal = Self.calcMaxLocalCrop(viewSize: viewSize, worldSize: nextWorld.size, inset: inset)
        cropView = cropLocal
        nextLocal = cropLocal
        
        worldView = Self.calcWorldView(viewSize: viewSize, localRect: cropLocal, worldRect: cropWorld)
    }
    
    mutating func set(viewSize vSize: CGSize) {
        guard imageSize.height > 0 else { return }
        
        viewSize = Size(size: vSize)

//        orient = Orientation(outerRect: viewSize, innerRect: nextLocal.size)
        
        let maxCropLocal = Self.calcMaxLocalCrop(viewSize: viewSize, worldSize: nextWorld.size, inset: inset)

        cropLocal = maxCropLocal
        cropView = cropLocal
        nextLocal = cropLocal

        transform = CoordSystemTransformer(viewSize: viewSize, local: cropLocal, world: cropWorld)
        
        worldView = Self.calcWorldView(viewSize: viewSize, localRect: cropLocal, worldRect: cropWorld)
        
        // DEBUG --------------------
        
        let matrix = self.debugMatrix(viewSize: viewSize)
        self.debugWorld = self.debugWorld(matrix: matrix)
        self.debugCamera = nextWorld.transform(matrix: matrix)
        self.debugView = worldView.transform(matrix: matrix)
    }
    
    mutating func set(angle: Float) {
        nextWorld.angle = angle
        cropWorld = nextWorld

        transform = CoordSystemTransformer(viewSize: viewSize, local: cropLocal, world: cropWorld)
        
        // DEBUG --------------------
        
        let matrix = self.debugMatrix(viewSize: viewSize)
        debugCamera = nextWorld.transform(matrix: matrix)
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
    
    static func calcWorldView(viewSize: Size, localRect: Rect, worldRect: Rect) -> Rect {
        let m = localRect.toWorld(rect: worldRect)
        let sv = SIMD3(viewSize.width, viewSize.height, 0)
        let s = simd_mul(m, sv)
        let worldViewRect = Rect(center: worldRect.center, width: s.x, height: s.y, angle: worldRect.angle)

        return worldViewRect
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
