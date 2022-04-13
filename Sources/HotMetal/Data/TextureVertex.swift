//
//  TextureVertex.swift
//  HotMetal
//
//  Created by Nail Sharipov on 13.04.2022.
//

import CoreGraphics

public struct TextureVertex {

    public var x, y, z : Float
    public var u, v: Float
    public var r, g, b, a: Float
    
    public init(position: Vector3, uv: Vector2, color: Vector4) {
        self.x = position.x
        self.y = position.y
        self.z = position.z

        self.u = uv.x
        self.v = uv.y
        
        self.r = color.x
        self.g = color.y
        self.b = color.z
        self.a = color.w
    }
    
    public init(position: Vector3, uv: Vector2, color: CGColor) {
        self.init(position: position, uv: uv, color: Vector4(color))
    }
}
