//
//  MainScene.swift
//  VarShader
//
//  Created by Nail Sharipov on 14.04.2022.
//

import MetalKit
import HotMetal

final class MainScene: Scene {

    private let node: RootNode
    private var start: Vector3 = .zero

    var red: Float = 0
    var green: Float = 0
    var blue: Float = 0
    
    init?(render: Render) {
        guard let node = RootNode(render: render) else { return nil }
        self.node = node
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
            nearZ: -10,
            farZ: 10
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
        camera.update(projection: .ortographic(size))
    }
    
    override func update(time: Time) {
        node.color = Vector4(red, green, blue, 0)
        super.update(time: time)
    }
    
}
