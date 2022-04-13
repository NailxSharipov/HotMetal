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
        camera = Camera(
            origin: [0, 0, -200],
            look: [0, 0, 1],
            up: [0, 1, 0],
            projection: .ortographic(100),
            aspectRatio: 1.0,
            zNear: -1000,
            zFar: 1000.0
        )
    }

    func onStartDrag() {
        start = node.position
    }
    
    func onContinueDrag(translation: CGSize) {
        let dx = 1 * Float(translation.width)
        let dy = 1 * Float(translation.height)
        
        node.position = .init(x: start.x + dx, y: start.y + dy, z: start.z)
        
        debugPrint("Cube pos: \(node.position)")
    }
 
    func onEndDrag(translation: CGSize) {
        let dx = 1 * Float(translation.width)
        let dy = 1 * Float(translation.height)
        node.position = .init(x: start.x + dx, y: start.y + dy, z: start.z)
        
        debugPrint("Cube pos: \(node.position)")
    }
    
    
    override func drawableSizeWillChange(_ view: MTKView, render: Render, size: CGSize) {
        camera.projection = .ortographic(Float(size.height))
    }
    
}
