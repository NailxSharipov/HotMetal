//
//  ScissorRectScene.swift
//  ScissorRect
//
//  Created by Nail Sharipov on 29.09.2025.
//

import MetalKit
import HotMetal

final class ScissorRectScene: Scene2d {

    private let node: ScissorRectNode
    
    @MainActor
    init?(render: Render, drawableSize: CGSize) {
        guard let node = ScissorRectNode(render: render, screenSize: drawableSize) else { return nil }
        self.node = node
        super.init(render: render)
        self.nodes.append(node)
    }
    
    override func drawableSizeWillChange(render: Render, size: CGSize, scale: CGFloat) {
        super.drawableSizeWillChange(render: render, size: size, scale: scale)
        node.update(screenSize: size)
    }
}
