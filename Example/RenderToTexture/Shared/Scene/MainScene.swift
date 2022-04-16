//
//  MainScene.swift
//  RenderToTexture
//
//  Created by Nail Sharipov on 15.04.2022.
//

import MetalKit
import HotMetal

final class MainScene: Scene {

    private let node: RootNode
    private var start: Vector3 = .zero

    var front: Float = 0
    var rear: Float = 0
    var glow: Float = 0
    
    init(render: Render) {
        self.node = RootNode(render: render)
        super.init()
        self.nodes.append(node)
        self.clearColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
        
        let size = Float(render.view?.bounds.height ?? 0)
        camera = Camera(
            origin: [0, 0, 100],
            look: [0, 0, -1],
            up: [0, 1, 0],
            projection: .ortographic(size),
            aspectRatio: 1.0,
            zNear: -1000,
            zFar: 1000
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
    
    override func update(time: Time) {
        node.data = Vector3(front, rear, glow)
        super.update(time: time)
    }
    
}
