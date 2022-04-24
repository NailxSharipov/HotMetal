//
//  MainScene.swift
//  TwoTextures
//
//  Created by Nail Sharipov on 14.04.2022.
//

import MetalKit
import HotMetal

final class MainScene: Scene2d {

    private let node: RootNode

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
    
    override init?(render: Render) {
        guard let node = RootNode(render: render) else { return nil }
        self.node = node
        super.init(render: render)
        self.nodes.append(node)
    }
    
}
