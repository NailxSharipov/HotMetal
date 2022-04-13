//
//  TextureVertex.swift
//  HotMetal
//
//  Created by Nail Sharipov on 13.04.2022.
//

import CoreGraphics

public struct TextureVertex {

    public var x, y, z: Float
    public var r, g, b, a: Float
    public var u, v: Float
    
    public init(position: Vector3, color: Vector4, uv: Vector2) {
        self.x = position.x
        self.y = position.y
        self.z = position.z
        
        self.r = color.x
        self.g = color.y
        self.b = color.z
        self.a = color.w
        
        self.u = uv.x
        self.v = uv.y
    }
    
    public init(position: Vector3, color: CGColor, uv: Vector2) {
        self.init(position: position, color: Vector4(color), uv: uv)
    }
}
