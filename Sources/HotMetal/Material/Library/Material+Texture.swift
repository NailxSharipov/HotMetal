//
//  Material+Sprite.swift
//  HotMetal
//
//  Created by Nail Sharipov on 11.04.2022.
//

import Metal

public extension Material {

    static func texture(
        render: Render,
        blendMode: BlendMode,
        vertex: Library.Resource = .framework("vertexTexture"),
        fragment: Library.Resource = .framework("fragmentTexture")
    ) -> MTLRenderPipelineState? {
        
        let bufferIndex = Render.firstFreeVertexBufferIndex
      
        let vertexDescriptor = MTLVertexDescriptor()
        
        // position x,y,z
        var size = 0
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = bufferIndex
        vertexDescriptor.attributes[0].offset = size
        size += MemoryLayout<Vertex3>.stride
        
        // color r,g,b,a
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].bufferIndex = bufferIndex
        vertexDescriptor.attributes[1].offset = size
        size += 4 * MemoryLayout<Float>.stride
        
        // texture u,v
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].bufferIndex = bufferIndex
        vertexDescriptor.attributes[2].offset = size
        size += 2 * MemoryLayout<Float>.stride

        vertexDescriptor.layouts[bufferIndex].stride = size

        let descriptor = render.defaultPipelineDescriptor()
        if let colorAttachment = descriptor.colorAttachments[0] {
            colorAttachment.set(blendMode: blendMode)
        }

        descriptor.vertexFunction = render.materialLibrary.load(vertex)
        descriptor.fragmentFunction = render.materialLibrary.load(fragment)

        descriptor.vertexDescriptor = vertexDescriptor

        let state = try? render.device.makeRenderPipelineState(descriptor: descriptor)

        return state
    }

}
