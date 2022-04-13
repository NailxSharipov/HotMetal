//
//  Material+Solid.swift
//  HotMetal
//
//  Created by Nail Sharipov on 12.04.2022.
//

import Metal

extension Material {

    static func solid(render: Render, blendMode: BlendMode) -> MTLRenderPipelineState {

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
        
        vertexDescriptor.layouts[bufferIndex].stride = MemoryLayout<Vertex3>.stride

        let descriptor = render.defaultPipelineDescriptor()
        if let colorAttachment = descriptor.colorAttachments[0] {
            colorAttachment.set(blendMode: blendMode)
        }

        let fragmentProgram = render.materialLibrary.load(.framework("fragmentSolid"))
        let vertexProgram = render.materialLibrary.load(.framework("vertexSolid"))
        
        descriptor.vertexFunction = vertexProgram
        descriptor.fragmentFunction = fragmentProgram
        descriptor.vertexDescriptor = vertexDescriptor
        
        let state = (try? render.device.makeRenderPipelineState(descriptor: descriptor))!

        return state
    }
    
}
