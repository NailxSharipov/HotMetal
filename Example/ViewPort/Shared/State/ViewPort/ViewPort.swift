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
    
    enum ModeState {
        case corner
        case body
        case idle
    }
    
    let imageSize: Size
    
    private (set) var viewSize: Size      // full view size
    
    var cropWorld: Rect = .zero           // crop rectangle in world coord system
    {
        didSet {
            nextWorld = cropWorld
        }
    }
    var nextWorld: Rect = .zero           // crop rectangle at next step (after animation) in world coord system
    var cropLocal: Rect = .zero           // crop rectangle in view coord system
    var nextLocal: Rect = .zero           // crop rectangle at next step (after animation) in view coord system
    var cropView: Rect = .zero            // crop rectangle at this moment even while editing in view coord system

    var debugCamera: [CGPoint] = []
    var debugView: [CGPoint] = []
    var debugWorld: [CGPoint] = []

    private (set) var inset: Float
    var transform = CoordSystemTransformer()
    var angle: Float = 0
    
    var modeState: ModeState = .idle
    
    init(imageSize iSize: CGSize, viewSize vSize: CGSize, inset: Float = 64) {
        imageSize = Size(size: iSize)
        viewSize = Size(size: vSize)
        self.inset = inset
        
        guard imageSize.height > 0 else {
            return
        }

        cropWorld = Rect(center: .zero, size: imageSize)
        nextWorld = cropWorld

        cropLocal = Self.calcMaxLocalCrop(viewSize: viewSize, worldSize: nextWorld.size, inset: inset)
        cropView = cropLocal
        nextLocal = cropLocal
    }
    
    mutating func set(viewSize vSize: CGSize) {
        guard imageSize.height > 0 else { return }
        
        viewSize = Size(size: vSize)

        let maxCropLocal = Self.calcMaxLocalCrop(viewSize: viewSize, worldSize: nextWorld.size, inset: inset)

        cropLocal = maxCropLocal
        cropView = cropLocal
        nextLocal = cropLocal

        transform = CoordSystemTransformer(viewSize: viewSize, local: cropLocal, world: cropWorld, angle: angle)
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
}
