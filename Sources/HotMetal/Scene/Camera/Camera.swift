//
//  Camera.swift
//  HotMetal
//
//  Created by Nail Sharipov on 12.04.2022.
//

public struct Camera {

    public static let empty = Camera(projectionMatrix: .identity, viewMatrix: .identity)
    
    public var projectionMatrix: Matrix4
    
    public var viewMatrix: Matrix4
    
    public init(projectionMatrix: Matrix4, viewMatrix: Matrix4) {
        self.projectionMatrix = projectionMatrix
        self.viewMatrix = viewMatrix
    }
    
    public mutating func update(position: Vector3, look: Vector3, up: Vector3) {
        viewMatrix = Matrix4.makeLook(eye: position, look: look, up: up)
    }
}
