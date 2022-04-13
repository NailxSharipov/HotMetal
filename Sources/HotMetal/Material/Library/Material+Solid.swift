//
//  Material+Solid.swift
//  HotMetal
//
//  Created by Nail Sharipov on 12.04.2022.
//

import Metal

extension Material {

    static func solid(render: Render) -> Material {

        let bufferIndex = Render.firstFreeVertexBufferIndex
        
        let vertexDescriptor = MTLVertexDescriptor()
        
        // position x,y,z
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = bufferIndex
        vertexDescriptor.attributes[0].offset = 0

        vertexDescriptor.layouts[bufferIndex].stride = MemoryLayout<Vertex3>.stride

        let descriptor = render.defaultPipelineDescriptor()
        descriptor.isAlphaToCoverageEnabled = true
        if let colorAttachment = descriptor.colorAttachments[0] {
            colorAttachment.isBlendingEnabled = true
            colorAttachment.rgbBlendOperation = .add
            colorAttachment.alphaBlendOperation = .add
            colorAttachment.sourceRGBBlendFactor = .sourceAlpha
            colorAttachment.sourceAlphaBlendFactor = .sourceAlpha
            colorAttachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
            colorAttachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
        }

        let fragmentProgram = render.library.load(.framework("fragmentSolid"))
        let vertexProgram = render.library.load(.framework("vertexSolid"))
        
        descriptor.vertexFunction = vertexProgram
        descriptor.fragmentFunction = fragmentProgram
        descriptor.vertexDescriptor = vertexDescriptor
        
        let state = (try? render.device.makeRenderPipelineState(descriptor: descriptor))!

        return Material(category: .solid, state: state)
    }
    
}
