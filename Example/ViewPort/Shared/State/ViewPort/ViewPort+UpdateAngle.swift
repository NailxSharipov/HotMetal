//
//  ViewPort+Modify.swift
//  ViewPort
//
//  Created by Nail Sharipov on 25.04.2022.
//

import SwiftUI
import HotMetal
import simd

extension ViewPort {

    var isRotationPossible: Bool {
        activeTransaction == nil
    }
    
    // rotate
    
    mutating func set(angle: Float) {
        guard activeTransaction == nil else { return }
        self.angle = angle

        let newWorld = transform.localToWorld(rect: frameLocal)
        let clip = self.scaleClip(world: newWorld)
        if case let .overlap(rect) = clip {
            frameWorld = rect
        } else {
            frameWorld = newWorld
        }

        self.setMaxSize()
    }
}
