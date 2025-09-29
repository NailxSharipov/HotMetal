//
//  DrawContext.swift
//  HotMetal
//
//  Created by Nail Sharipov on 11.04.2022.
//

import Metal

public final class DrawContext {

    public unowned let render: Render
    public let encoder: MTLRenderCommandEncoder
    public internal(set) var camera: Camera?

    private var currentMaterialId: UInt?

    public init(render: Render, encoder: MTLRenderCommandEncoder) {
        self.render = render
        self.encoder = encoder
    }

    public func set(material: Material) {
        if currentMaterialId != material.id {
            encoder.setRenderPipelineState(material.state)
            currentMaterialId = material.id
        }

        if material.isAffectDepthBuffer {
            encoder.setDepthStencilState(render.enabledDepthStencilState)
        } else {
            encoder.setDepthStencilState(render.disabledDepthStencilState)
        }

        encoder.setCullMode(material.cullMode)

        if !material.textures.isEmpty {
            for i in 0..<material.textures.count {
                // TODO validate textures ID
                let texture = material.textures[i]
                encoder.setFragmentTexture(texture.mltTexture, index: i)
                encoder.setFragmentSamplerState(texture.sampler, index: i)
            }
        }
    }

}
