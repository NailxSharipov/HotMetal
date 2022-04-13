//
//  Mesh.swift
//  HotMetal
//
//  Created by Nail Sharipov on 10.04.2022.
//

import MetalKit

public final class Mesh {
    
    public let vertexBuffer: MTLBuffer
    public let indexBuffer: MTLBuffer
    public let count: Int
    
    public init(vertexBuffer: MTLBuffer, indexBuffer: MTLBuffer, count: Int) {
        self.vertexBuffer = vertexBuffer
        self.indexBuffer = indexBuffer
        self.count = count
    }
    
    func draw(context: DrawContext) {
        context.encoder.setVertexBuffer(vertexBuffer, offset: 0, index: Render.firstFreeVertexBufferIndex)
        context.encoder.drawIndexedPrimitives(type: .triangle, indexCount: count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
    }
    
}
