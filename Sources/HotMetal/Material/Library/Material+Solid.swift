//
//  Material+Solid.swift
//  HotMetal
//
//  Created by Nail Sharipov on 12.04.2022.
//

import Metal

extension Material {

    static func solid(
        render: Render,
        blendMode: BlendMode,
        vertex: Library.Resource = .framework("vertexSolid"),
        fragment: Library.Resource = .framework("fragmentSolid")
    ) -> MTLRenderPipelineState {

        let bufferIndex = Render.firstFreeVertexBufferIndex
        
        let vertexDescriptor = MTLVertexDescriptor()
        
        // position x,y,z
        var size = 0
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = bufferIndex
        vertexDescriptor.attributes[0].offset = size
        size += MemoryLayout<Vertex3>.stride
        
        vertexDescriptor.layouts[bufferIndex].stride = size

        let descriptor = render.defaultPipelineDescriptor()
        
        if let colorAttachment = descriptor.colorAttachments[0] {
            colorAttachment.set(blendMode: blendMode)
        }

        descriptor.vertexFunction = render.materialLibrary.load(vertex)
        descriptor.fragmentFunction = render.materialLibrary.load(fragment)

        descriptor.vertexDescriptor = vertexDescriptor
        
        let state = (try? render.device.makeRenderPipelineState(descriptor: descriptor))!

        return state
    }
    
}
