//
//  MainScene.swift
//  ViewPort
//
//  Created by Nail Sharipov on 21.04.2022.
//

import MetalKit
import HotMetal

final class MainScene: Scene {

    let node: RootNode
    
    init?(render: Render) {
        guard let node = RootNode(render: render) else { return nil }
        self.node = node
        super.init()
        self.nodes.append(node)
        
        let size = Float(render.view?.bounds.height ?? 0)
        camera = Camera(
            origin: [0, 0, -100],
            look: [0, 0, 1],
            up: [0, 1, 0],
            projection: .ortographic(size),
            aspectRatio: 1.0,
            nearZ: -10,
            farZ: 10
        )
    }
    
    override func drawableSizeWillChange(render: Render, size: CGSize) {

    }
}
