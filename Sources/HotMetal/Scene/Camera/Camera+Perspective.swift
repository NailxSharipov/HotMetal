//
//  Camera+Perspective.swift
//  HotMetal
//
//  Created by Nail Sharipov on 23.04.2022.
//

public extension Camera {
    
    init(
        position: Vector3 = Vector3(0, 0, -10),
        look: Vector3 = Vector3(0, 0, 1),
        up: Vector3 = .up,
        fovyDegrees fovy: Float = 0.5 * .pi,
        aspectRatio: Float,
        nearZ: Float = 0.001,
        farZ: Float = 1000
    ) {
        projectionMatrix = Matrix4.makePerspective(fovyDegrees: fovy, aspectRatio: aspectRatio, nearZ: nearZ, farZ: farZ)
        viewMatrix = Matrix4.makeLook(eye: position, look: look, up: up)
    }
    
    mutating func update(fovyDegrees fovy: Float = 0.5 * .pi, aspectRatio: Float, nearZ: Float = 0.001, farZ: Float = 1000) {
        projectionMatrix = Matrix4.makePerspective(fovyDegrees: fovy, aspectRatio: aspectRatio, nearZ: nearZ, farZ: farZ)
    }
    
}
