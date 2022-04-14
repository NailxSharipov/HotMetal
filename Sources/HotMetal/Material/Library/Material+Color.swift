//
//  Material+Color.swift
//  
//
//  Created by Nail Sharipov on 13.04.2022.
//

import Metal

extension Material {

    static func color(
        render: Render,
        blendMode: BlendMode,
        vertex: Library.Resource = .framework("vertexColor"),
        fragment: Library.Resource = .framework("fragmentColor")
    ) -> MTLRenderPipelineState {

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

        vertexDescriptor.layouts[bufferIndex].stride = size

        let descriptor = render.defaultPipelineDescriptor()

        if let colorAttachment = descriptor.colorAttachments[0] {
            colorAttachment.set(blendMode: blendMode)
        }

        let vertexProgram = render.materialLibrary.load(vertex)
        let fragmentProgram = render.materialLibrary.load(fragment)
        
        descriptor.vertexFunction = vertexProgram
        descriptor.fragmentFunction = fragmentProgram
        descriptor.vertexDescriptor = vertexDescriptor
        
        let state = (try? render.device.makeRenderPipelineState(descriptor: descriptor))!

        return state
    }
    
}

