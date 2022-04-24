//
//  Scene.swift
//  HotMetal
//
//  Created by Nail Sharipov on 12.04.2022.
//

import CoreGraphics

public protocol Scene {

    var nodes: [Node] { get }
    var mainCamera: Camera { get }
    
    func update(time: Time)
    func draw(context: DrawContext)
    func drawableSizeWillChange(render: Render, size: CGSize, scale: CGFloat)
}

public extension Scene {

    func update(time: Time) {
        for node in nodes {
            node.update(time: time)
        }
    }
    
    func draw(context: DrawContext) {
        context.camera = mainCamera
        for node in nodes {
            node.draw(context: context, parentTransform: .identity)
        }
    }
}
