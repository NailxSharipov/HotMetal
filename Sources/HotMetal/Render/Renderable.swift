//
//  Renderable.swift
//  MetalImageView
//
//  Created by Nail Sharipov on 11.04.2022.
//

import MetalKit

public protocol Renderable {

    var clearColor: MTLClearColor { get }
    
    func draw(render: Render, encoder: MTLRenderCommandEncoder)
    
    func drawableSizeWillChange(_ view: MTKView, size: CGSize)
    
}
