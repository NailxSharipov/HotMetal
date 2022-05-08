//
//  ViewPort+Modify.swift
//  ViewPort
//
//  Created by Nail Sharipov on 25.04.2022.
//

import SwiftUI
import HotMetal
import CoreGraphics
import simd

extension ViewPort {

    
    // rotate
    
    mutating func set(angle: Float) {
        guard modeState == .idle else { return }
        self.angle = angle

        let newWorld = transform.localToWorld(rect: frameLocal)
        let clip = self.scaleClip(world: newWorld)
        if case let .overlap(rect) = clip {
            frameWorld = rect
        } else {
            frameWorld = newWorld
        }
        
//        transform.update(worldPos: <#T##Vector2#>)
        
//        let maxCropLocal = Self.calcMaxLocalCrop(viewSize: viewSize, worldSize: frameWorld.size, inset: inset)
//
//        cropLocal = maxCropLocal
//        cropLocal = cropLocal
//        nextLocal = cropLocal
//
//        transform = CoordSystemTransformer(viewSize: viewSize, local: cropLocal, world: cropWorld, angle: angle)
    }
}
