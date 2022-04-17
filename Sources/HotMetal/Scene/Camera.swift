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
        zNear: 0.001,
        zFar: 1000.0
    )

    public enum Projection {
        case perspective(Float)
        case ortographic(Float)
    }
    
    public var origin: Vector3 { didSet { needsUpdateView = true } }
    public var look: Vector3 { didSet { needsUpdateView = true } }
    public var up: Vector3 { didSet { needsUpdateView = true } }
    public var aspectRatio: Float { didSet { buildProjection = true } }
    public var zNear: Float { didSet { buildProjection = true } }
    public var zFar: Float { didSet { buildProjection = true } }
    public var projection: Projection { didSet { buildProjection = true } }

    private var buildProjection = true
    private var needsUpdateView = true
    private var _projectionMatrix = Matrix4.identity
    private var _viewMatrix = Matrix4.identity

    public var projectionMatrix: Matrix4 {
        get {
            guard buildProjection else {
                return _projectionMatrix
            }
            buildProjection = false

            switch projection {
            case .perspective(let fovYDegrees):
                _projectionMatrix = Matrix4.makePerspective(
                    fovyDegrees: fovYDegrees,
                    aspectRatio: aspectRatio,
                    nearZ: zNear,
                    farZ: zFar
                )
            case .ortographic(let size):
                _projectionMatrix = Matrix4.makeOrtho(
                    size: size,
                    aspectRatio: aspectRatio,
                    nearZ: zNear,
                    farZ: zFar
                )
            }
            
            return _projectionMatrix
        }
    }

    public var viewMatrix: Matrix4 {
        get {
            guard needsUpdateView else {
                return _viewMatrix
            }
            needsUpdateView = false
            
            _viewMatrix = Matrix4.makeLook(eye: origin, look: look, up: up)

            return _viewMatrix
        }
    }


    public init(
        origin: Vector3,
        look: Vector3,
        up: Vector3,
        projection: Projection,
        aspectRatio: Float,
        zNear: Float,
        zFar: Float
    ) {
        self.origin = origin
        self.look = look
        self.up = up
        self.projection = projection
        self.aspectRatio = aspectRatio
        self.zNear = zNear
        self.zFar = zFar
    }

}
