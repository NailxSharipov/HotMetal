//
//  OffScreenScene.swift
//  RenderToTexture
//
//  Created by Nail Sharipov on 15.04.2022.
//

import MetalKit
import HotMetal

final class OffScreenScene: Scene2d {

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
    
    init?(render: Render, width: Int, height: Int) {
        guard let node = RootNode(render: render) else { return nil }
        self.node = node
        super.init(render: render)
        xyCamera.update(width: Float(width), height: Float(height), anchor: .center)
        self.nodes.append(node)
    }
}
