//
//  Camera.swift
//  HotMetal
//
//  Created by Nail Sharipov on 12.04.2022.
//

public final class Camera {

    public static let defaultCamera: Camera = Camera(
        origin: [0, 0, -10],
        look: [0, 0, 1],
        up: [0, 1, 0],
        projection: .perspective(90),
        aspectRatio: 1.0,
        nearZ: 0.001,
        farZ: 1000.0
    )
    
    public enum Projection {
        case perspective(Float)
        case ortographic(Float)
    }
    
    public private (set) var position: Vector3
    public private (set) var look: Vector3
    public private (set) var up: Vector3
    public private (set) var aspectRatio: Float
    public private (set) var nearZ: Float
    public private (set) var farZ: Float
    public private (set) var projection: Projection

    public var projectionMatrix: Matrix4
    public var viewMatrix: Matrix4

    public func update(position: Vector3, look: Vector3, up: Vector3) {
        self.position = position
        self.look = look
        self.up = up
        viewMatrix = Matrix4.makeLook(eye: position, look: look, up: up)
    }
    
    public func update(position: Vector3, look: Vector3) {
        self.position = position
        self.look = look
        viewMatrix = Matrix4.makeLook(eye: position, look: look, up: up)
    }
    
    public func update(position: Vector3) {
        self.position = position
        viewMatrix = Matrix4.makeLook(eye: position, look: look, up: up)
    }
    
    public func update(look: Vector3) {
        self.look = look
        viewMatrix = Matrix4.makeLook(eye: position, look: look, up: up)
    }
    
    public func update(projection: Projection, aspectRatio: Float, nearZ: Float, farZ: Float) {
        self.projection = projection
        self.aspectRatio = aspectRatio
        self.nearZ = nearZ
        self.farZ = farZ
        
        projectionMatrix = Matrix4.makeProjection(projection: projection, aspectRatio: aspectRatio, nearZ: nearZ, farZ: farZ)
    }

    public func update(aspectRatio: Float) {
        self.aspectRatio = aspectRatio

        projectionMatrix = Matrix4.makeProjection(projection: projection, aspectRatio: aspectRatio, nearZ: nearZ, farZ: farZ)
    }
    
    public func update(projection: Projection) {
        self.projection = projection

        projectionMatrix = Matrix4.makeProjection(projection: projection, aspectRatio: aspectRatio, nearZ: nearZ, farZ: farZ)
    }
    
    public init(
        origin: Vector3,
        look: Vector3,
        up: Vector3,
        projection: Projection,
        aspectRatio: Float,
        nearZ: Float,
        farZ: Float
    ) {
        self.position = origin
        self.look = look
        self.up = up
        self.projection = projection
        self.aspectRatio = aspectRatio
        self.nearZ = nearZ
        self.farZ = farZ
        
        viewMatrix = Matrix4.makeLook(eye: position, look: look, up: up)
        projectionMatrix = Matrix4.makeProjection(projection: projection, aspectRatio: aspectRatio, nearZ: nearZ, farZ: farZ)
    }

}

private extension Matrix4 {

    @inline(__always)
    static func makeProjection(
        projection: Camera.Projection,
        aspectRatio: Float,
        nearZ: Float,
        farZ: Float
    ) -> Matrix4 {
        switch projection {
        case .perspective(let fovYDegrees):
            return Matrix4.makePerspective(
                fovyDegrees: fovYDegrees,
                aspectRatio: aspectRatio,
                nearZ: nearZ,
                farZ: farZ
            )
        case .ortographic(let size):
            return Matrix4.makeOrtho(
                size: size,
                aspectRatio: aspectRatio,
                nearZ: nearZ,
                farZ: farZ
            )
        }
    }
}
