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
    let inset: Float
    private (set) var viewSize: Size

    var frameLocal: Rect = .zero
    var frameWorld: Rect = .zero

    var transform = CoordSystemTransformer()
    var activeTransaction: Transaction?

    var viewPoint: Vector2 = .zero
    var angle: Float = 0
    var scale: Float = 1
    
    init(imageSize iSize: CGSize, viewSize vSize: CGSize, inset: Float = 64) {
        imageSize = Size(size: iSize)
        viewSize = Size(size: vSize)
        self.inset = inset
    }
    
    mutating func set(viewSize vSize: CGSize) {
        guard imageSize.height > 0 else { return }
        
        frameWorld = Rect(center: .zero, size: imageSize)
        
        viewSize = Size(size: vSize)

        self.setMaxSize()
    }
    
    mutating func setMaxSize() {
        frameLocal = Self.maxFrame(viewSize: viewSize, worldSize: frameWorld.size, inset: inset)

        scale = frameWorld.width / frameLocal.width
        
        viewPoint = frameWorld.center
        
        transform = CoordSystemTransformer(viewSize: viewSize, scale: scale, angle: angle, translate: viewPoint)
    }

    static func maxFrame(viewSize: Size, worldSize: Size, inset: Float) -> Rect {
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
