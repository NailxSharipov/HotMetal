//
//  MainScene.swift
//  EncodePrepasses
//
//  Created by Nail Sharipov on 29.09.2025.
//

import MetalKit
import HotMetal

final class MainScene: Scene2d {

    private let node: MainNode
    
    @MainActor
    init?(render: Render, drawableSize: CGSize) {
        guard let node = MainNode(render: render) else { return nil }
        self.node = node
        super.init(render: render)
        self.nodes.append(node)
    }
    
    override func drawableSizeWillChange(render: Render, size: CGSize, scale: CGFloat) {
        super.drawableSizeWillChange(render: render, size: size, scale: scale)
    }
}
