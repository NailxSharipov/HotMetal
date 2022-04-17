//
//  ImageScene.swift
//  Image
//
//  Created by Nail Sharipov on 13.04.2022.
//

import MetalKit
import HotMetal

final class ImageScene: Scene {

    private let node: ImageNode
    private var start: Vector3 = .zero
    
    init(render: Render) {
        self.node = ImageNode(render: render)
        super.init()
        self.nodes.append(node)
        self.clearColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
        
        let size = Float(render.view?.bounds.height ?? 0)
        camera = Camera(
            origin: [0, 0, -5],
            look: [0, 0, 1],
            up: [0, 1, 0],
            projection: .ortographic(size),
            aspectRatio: 1.0,
            length: 10
        )
    }

    func onStartDrag() {
        start = node.position
    }
    
    func onDrag(translation: CGSize) {
        let dx = Float(translation.width)
        let dy = Float(translation.height)
        
        node.position = .init(x: start.x + dx, y: start.y + dy, z: start.z)
        
        debugPrint("Image pos: \(node.position)")
    }
    
    override func drawableSizeWillChange(_ view: MTKView, render: Render, size: CGSize) {
        let size = Float(size.height)
        camera.projection = .ortographic(size)
    }
    
}
