//
//  Scene.swift
//  HotMetal
//
//  Created by Nail Sharipov on 12.04.2022.
//

import Metal
import MetalKit

open class Scene {
    
    public var clearColor: MTLClearColor = .init(red: 0, green: 0, blue: 0, alpha: 0.0)
    public var nodes: [Node] = []
    public var camera: Camera = Camera(
        origin: [0, 0, -10],
        look: [0, 0, 1],
        up: [0, 1, 0],
        projection: .perspective(90),
        aspectRatio: 1.0,
        zNear: 0.001,
        zFar: 1000.0
    )

    public init() { }
    
    open func update(time: Time) {
        for node in nodes {
            node.update(time: time)
        }
    }
    
    public func draw(context: DrawContext) {
        context.camera = camera
        for node in nodes {
            node.draw(context: context, parentTransform: .identity)
        }
    }
    
    open func drawableSizeWillChange(_ view: MTKView, render: Render, size: CGSize) {

    }
    
}
