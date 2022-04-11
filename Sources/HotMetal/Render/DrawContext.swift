//
//  DrawContext.swift
//  
//
//  Created by Nail Sharipov on 11.04.2022.
//

import Metal

public final class DrawContext {
    
    let render: Render
    let encoder: MTLRenderCommandEncoder
    var currentMaterial: Material?
    
    init(render: Render, encoder: MTLRenderCommandEncoder) {
        self.render = render
        self.encoder = encoder
    }
    
}
