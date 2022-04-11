//
//  Renderable.swift
//  MetalImageView
//
//  Created by Nail Sharipov on 11.04.2022.
//

import MetalKit

public protocol Renderable {

    var clearColor: MTLClearColor { get }
    
    func draw(context: DrawContext)
    
    func drawableSizeWillChange(_ view: MTKView, render: Render, size: CGSize)
    
}
