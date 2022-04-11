//
//  SpriteMaterial.swift
//  MetalImageView
//
//  Created by Nail Sharipov on 11.04.2022.
//

import Metal

public final class SpriteMaterial: Material {

    private let renderPipelineState: MTLRenderPipelineState
    private let texture: Texture
    private let cullMode: MTLCullMode
    
    public init(
        render: Render,
        vertexName: String,
        fragmentName: String,
        texture: Texture,
        cullMode: MTLCullMode = .back
    ) {
        self.texture = texture
        self.cullMode = cullMode
        
        let bufferIndex = Render.firstFreeVertexBufferIndex
        
        let pipelineDescriptor = render.defaultPipelineDescriptor()
        let fragmentProgram = render.library.makeFunction(name: fragmentName)
        let vertexProgram = render.library.makeFunction(name: vertexName)
      
        let vertexDescriptor = MTLVertexDescriptor()
        
        // position x,y
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].bufferIndex = bufferIndex
        vertexDescriptor.attributes[0].offset = 0

        // texture u,v
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].bufferIndex = bufferIndex
        vertexDescriptor.attributes[1].offset = MemoryLayout<Vertex2>.stride

        vertexDescriptor.layouts[0].stride = 2 * MemoryLayout<Vertex2>.stride
        
        pipelineDescriptor.vertexFunction = vertexProgram
        pipelineDescriptor.fragmentFunction = fragmentProgram
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        self.renderPipelineState = try! render.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    public override func install(encoder: MTLRenderCommandEncoder) {
        
        encoder.setCullMode(cullMode)
        
        encoder.setFragmentTexture(texture.mltTexture, index: 0)
        encoder.setFragmentSamplerState(texture.sampler, index: 0)
        
        encoder.setRenderPipelineState(renderPipelineState)
    }
    
}
