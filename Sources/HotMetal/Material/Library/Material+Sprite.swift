//
//  Material+Sprite.swift
//  HotMetal
//
//  Created by Nail Sharipov on 11.04.2022.
//

import Metal

public extension Material {

    static func sprite2d(render: Render) -> Material {
        let bufferIndex = Render.firstFreeVertexBufferIndex
      
        let vertexDescriptor = MTLVertexDescriptor()
        
        // position x,y
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].bufferIndex = bufferIndex
        vertexDescriptor.attributes[0].offset = 0

        // texture u,v
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].bufferIndex = bufferIndex
        vertexDescriptor.attributes[1].offset = MemoryLayout<Vertex2>.stride

        vertexDescriptor.layouts[bufferIndex].stride = 2 * MemoryLayout<Vertex2>.stride

        let descriptor = render.defaultPipelineDescriptor()
        let vertexProgram = render.library.load(.framework("vertexSprite2d"))
        let fragmentProgram = render.library.load(.framework("fragmentSprite2d"))
        
        descriptor.vertexFunction = vertexProgram
        descriptor.fragmentFunction = fragmentProgram
        descriptor.vertexDescriptor = vertexDescriptor

        let state = (try? render.device.makeRenderPipelineState(descriptor: descriptor))!

        return Material(category: .sprite, state: state)
    }

    
}
