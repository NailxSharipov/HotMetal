//
//  MainScene.swift
//  NoiseEffect
//
//  Created by Nail Sharipov on 12.05.2022.
//

import MetalKit
import HotMetal

final class MainScene: Scene2d {
    
    private let node: RootNode

    var size: Float = 100 {
        didSet {
            node.varData.size = size
        }
    }
    
    @MainActor
    init?(render: Render) {
        guard let node = RootNode(render: render) else { return nil }
        self.node = node
        super.init(render: render)
        self.nodes.append(node)
    }

}
