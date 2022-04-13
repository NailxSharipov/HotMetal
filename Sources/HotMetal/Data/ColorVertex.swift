//
//  ColorVertex.swift
//  HotMetal
//
//  Created by Nail Sharipov on 13.04.2022.
//

import CoreGraphics

public struct ColorVertex {

    public var x, y, z: Float
    public var r, g, b, a: Float
    
    public init(position: Vector3, color: Vector4) {
        self.x = position.x
        self.y = position.y
        self.z = position.z
        self.r = color.x
        self.g = color.y
        self.b = color.z
        self.a = color.w
    }
    
    public init(position: Vector3, color: CGColor) {
        self.x = position.x
        self.y = position.y
        self.z = position.z
        let color = Vector4(color)
        self.r = color.x
        self.g = color.y
        self.b = color.z
        self.a = color.w
    }
}
