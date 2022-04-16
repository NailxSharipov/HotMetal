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
    
    init(render: Render, size: Float) {
        self.node = RootNode(render: render)
        super.init()
        self.nodes.append(node)
        self.clearColor = .init(red: 0, green: 0, blue: 0, alpha: 0)

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
}
