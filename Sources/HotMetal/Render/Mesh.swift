//
//  Mesh.swift
//  MetalImageView
//
//  Created by Nail Sharipov on 10.04.2022.
//

import MetalKit

public struct Mesh {
    
    public let vertexBuffer: MTLBuffer
    public let indexBuffer: MTLBuffer
    public let count: Int
    
    public init(vertexBuffer: MTLBuffer, indexBuffer: MTLBuffer, count: Int) {
        self.vertexBuffer = vertexBuffer
        self.indexBuffer = indexBuffer
        self.count = count
    }
    
}
