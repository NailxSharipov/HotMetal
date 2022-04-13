//
//  DrawContext.swift
//  HotMetal
//
//  Created by Nail Sharipov on 11.04.2022.
//

import Metal

public final class DrawContext {
    
    unowned let render: Render
    let encoder: MTLRenderCommandEncoder
    var camera: Camera?
    
    private var currentMaterialId: Int = -1
    
    init(render: Render, encoder: MTLRenderCommandEncoder) {
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
    }
    
}
