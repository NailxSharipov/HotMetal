//
//  ViewPort+Modify.swift
//  ViewPort
//
//  Created by Nail Sharipov on 25.04.2022.
//

extension ViewPort {

    var isRotationPossible: Bool {
        activeTransaction == nil
    }

    mutating func set(angle: Float) {
        guard activeTransaction == nil else { return }
        self.angle = angle

        let newWorld = transform.localToWorld(rect: frameLocal)
        let clip = self.rotateClip(world: newWorld, angle: angle)
        if case let .overlap(rect) = clip {
            frameWorld = rect
        } else {
            frameWorld = newWorld
        }

        self.setMaxSize()
    }
}
