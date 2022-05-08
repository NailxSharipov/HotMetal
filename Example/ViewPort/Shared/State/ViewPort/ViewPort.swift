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
    
    var viewWorld: Rect = .zero
    var viewLocal: Rect = .zero
    
    var frameLocal: Rect = .zero
    var frameWorld: Rect = .zero


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

        viewWorld = Rect(center: .zero, size: imageSize)
        frameWorld = viewWorld

        viewLocal = Self.calcMaxLocalCrop(viewSize: viewSize, worldSize: viewWorld.size, inset: inset)
        frameLocal = viewLocal
    }
    
    mutating func set(viewSize vSize: CGSize) {
        guard imageSize.height > 0 else { return }
        
        viewSize = Size(size: vSize)

        viewLocal = Self.calcMaxLocalCrop(viewSize: viewSize, worldSize: viewWorld.size, inset: inset)
        frameLocal = viewLocal

        transform = CoordSystemTransformer(viewSize: viewSize, local: viewLocal, world: viewWorld, angle: angle)
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
