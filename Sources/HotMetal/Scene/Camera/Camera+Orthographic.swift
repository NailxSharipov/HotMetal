//
//  Camera+Orthographic.swift
//  HotMetal
//
//  Created by Nail Sharipov on 23.04.2022.
//

public extension Camera {
   
    init(
        position: Vector3,
        look: Vector3,
        up: Vector3,
        left: Float,
        right: Float,
        bottom: Float,
        top: Float,
        nearZ: Float = -100,
        farZ: Float = 100
    ) {
        projectionMatrix = Matrix4.makeOrtho(left: left, right: right, top: top, bottom: bottom, nearZ: nearZ, farZ: farZ)
        viewMatrix = Matrix4.makeLook(eye: position, look: look, up: up)
    }

    mutating func update(
        left: Float,
        right: Float,
        bottom: Float,
        top: Float,
        nearZ: Float = -100,
        farZ: Float = 100
    ) {
        projectionMatrix = Matrix4.makeOrtho(left: left, right: right, top: top, bottom: bottom, nearZ: nearZ, farZ: farZ)
    }
    
}
