//
//  OffScreenScene.swift
//  RenderToTexture
//
//  Created by Nail Sharipov on 15.04.2022.
//

import MetalKit
import HotMetal

final class OffScreenScene: Scene {

    private let node: RootNode
    private var start: Vector3 = .zero

    var front: Float = 0 {
        didSet {
            node.data = Vector3(front, rear, glow)
        }
    }
    var rear: Float = 0 {
        didSet {
            node.data = Vector3(front, rear, glow)
        }
    }
    var glow: Float = 0 {
        didSet {
            node.data = Vector3(front, rear, glow)
        }
    }
    
    init(render: Render, width: Int, height: Int) {
        self.node = RootNode(render: render)
        super.init()
        self.nodes.append(node)
        self.clearColor = .init(red: 0, green: 0, blue: 0, alpha: 0)

        camera = Camera(
            origin: [0, 0, -5],
            look: [0, 0, 1],
            up: [0, 1, 0],
            projection: .ortographic(Float(height)),
            aspectRatio: Float(width) / Float(height),
            nearZ: -10,
            farZ: 10
        )

        // invert to image coordinate system
        camera.viewMatrix = camera.viewMatrix * Matrix4.scale(1, -1, 1)
    }
}
