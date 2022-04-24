//
//  MainScene.swift
//  VarShader
//
//  Created by Nail Sharipov on 14.04.2022.
//

import MetalKit
import HotMetal

final class MainScene: Scene2d {
    
    private let node: RootNode

    var red: Float = 0 {
        didSet {
            node.color = Vector4(red, green, blue, 0)
        }
    }
    var green: Float = 0 {
        didSet {
            node.color = Vector4(red, green, blue, 0)
        }
    }
    var blue: Float = 0 {
        didSet {
            node.color = Vector4(red, green, blue, 0)
        }
    }
    
    override init?(render: Render) {
        guard let node = RootNode(render: render) else { return nil }
        self.node = node
        super.init(render: render)
        self.nodes.append(node)
    }
    
}
