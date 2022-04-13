//
//  Camera.swift
//  
//
//  Created by Nail Sharipov on 12.04.2022.
//

public final class Camera {

    public var origin: Vector3 { didSet { needsUpdateView = true } }
    public var look: Vector3 { didSet { needsUpdateView = true } }
    public var up: Vector3 { didSet { needsUpdateView = true } }
    public var fovYDegrees: Float { didSet { buildProjection = true } }
    public var aspectRatio: Float { didSet { buildProjection = true } }
    public var zNear: Float { didSet { buildProjection = true } }
    public var zFar: Float { didSet { buildProjection = true } }

    /// If set will override the default projection matrix that is calculated from the explicit camera parameters
    public var overrideProjectionMatrix: Matrix4?

    /// If set will override the default view matrix that is calculated from the explicit camera parameters
    public var overrideViewMatrix: Matrix4?

    private var buildProjection = true
    private var needsUpdateView = true
    private var _projectionMatrix = Matrix4.identity
    private var _viewMatrix = Matrix4.identity

    public var projectionMatrix: Matrix4 {
        get {
            if let overrideProjectionMatrix = overrideProjectionMatrix {
                return overrideProjectionMatrix
            }

            if buildProjection {
                buildProjection = false
                _projectionMatrix = Math.makePerspective(
                    fovyDegrees: fovYDegrees,
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
            if let overrideViewMatrix = overrideViewMatrix {
                return overrideViewMatrix
            }

            if needsUpdateView {
                needsUpdateView = false
                _viewMatrix = Math.makeLook(eye: origin, look: look, up: up)
            }
            return _viewMatrix
        }
    }


    public init(
        origin: Vector3,
        look: Vector3,
        up: Vector3,
        fovYDegrees: Float,
        aspectRatio: Float,
        zNear: Float,
        zFar: Float
    ) {
        self.origin = origin
        self.look = look
        self.up = up
        self.fovYDegrees = fovYDegrees
        self.aspectRatio = aspectRatio
        self.zNear = zNear
        self.zFar = zFar
    }

}
