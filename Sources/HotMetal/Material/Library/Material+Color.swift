//
//  Material+Color.swift
//  
//
//  Created by Nail Sharipov on 13.04.2022.
//

import Metal

extension Material {

    static func color(render: Render) -> Material {

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
//        descriptor.isAlphaToCoverageEnabled = true
        if let colorAttachment = descriptor.colorAttachments[0] {
            colorAttachment.isBlendingEnabled = true
            colorAttachment.rgbBlendOperation = .add
            colorAttachment.alphaBlendOperation = .add
            colorAttachment.sourceRGBBlendFactor = .sourceAlpha
            colorAttachment.sourceAlphaBlendFactor = .sourceAlpha
            colorAttachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
            colorAttachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
        }

        let fragmentProgram = render.library.load(.framework("fragmentColor"))
        let vertexProgram = render.library.load(.framework("vertexColor"))
        
        descriptor.vertexFunction = vertexProgram
        descriptor.fragmentFunction = fragmentProgram
        descriptor.vertexDescriptor = vertexDescriptor
        
        let state = (try? render.device.makeRenderPipelineState(descriptor: descriptor))!

        return Material(category: .solid, state: state)
    }
    
}
