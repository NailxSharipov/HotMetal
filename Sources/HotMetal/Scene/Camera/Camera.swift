//
//  Camera.swift
//  HotMetal
//
//  Created by Nail Sharipov on 12.04.2022.
//

public struct Camera {

    var projectionMatrix: Matrix4
    
    var viewMatrix: Matrix4
    
    init(projectionMatrix: Matrix4, viewMatrix: Matrix4) {
        self.projectionMatrix = projectionMatrix
        self.viewMatrix = viewMatrix
    }
    
    mutating func update(position: Vector3, look: Vector3, up: Vector3) {
        viewMatrix = Matrix4.makeLook(eye: position, look: look, up: up)
    }
}
