//
//  SpriteMaterial.swift
//  MetalImageView
//
//  Created by Nail Sharipov on 11.04.2022.
//

import Metal

public final class SpriteMaterial {

    public let renderPipelineState: MTLRenderPipelineState
    public let texture: Texture
    
    public init(
        render: Render,
        vertexName: String,
        fragmentName: String,
        texture: Texture
    ) {
        self.texture = texture
        
        let pipelineDescriptor = render.defaultPipelineDescriptor()
        let fragmentProgram = render.library.makeFunction(name: fragmentName)
        let vertexProgram = render.library.makeFunction(name: vertexName)
      
        let vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].bufferIndex = Render.firstFreeVertexBufferIndex
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex2>.stride
        
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].bufferIndex = Render.firstFreeVertexBufferIndex
        vertexDescriptor.attributes[1].offset = MemoryLayout<UV>.stride
        
        pipelineDescriptor.vertexFunction = vertexProgram
        pipelineDescriptor.fragmentFunction = fragmentProgram
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        self.renderPipelineState = try! render.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
}
