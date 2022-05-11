//
//  MainScene.swift
//  ViewPort
//
//  Created by Nail Sharipov on 21.04.2022.
//

import MetalKit
import HotMetal

final class MainScene: Scene {

    var nodes: [Node] = []

    var vpCamera = ViewPortCamera()
    var mainCamera: Camera { vpCamera.camera }
    
    let node: RootNode
    
    init?(render: Render) {
        guard let node = RootNode(render: render) else { return nil }
        self.node = node
        self.nodes.append(node)
        render.view?.enableSetNeedsDisplay = true
        render.view?.isPaused = true
    }

    func drawableSizeWillChange(render: Render, size: CGSize, scale: CGFloat) {}
}
