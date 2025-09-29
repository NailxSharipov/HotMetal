//
//  FillRectScene.swift
//  FillRect
//
//  Created by Nail Sharipov on 29.09.2025.
//

import MetalKit
import HotMetal

final class FillRectScene: Scene2d {

    private let node: FillRectNode
    
    @MainActor
    init?(render: Render, drawableSize: CGSize) {
        guard let node = FillRectNode(render: render) else { return nil }
        self.node = node
        super.init(render: render)
        self.nodes.append(node)
    }
    
    override func drawableSizeWillChange(render: Render, size: CGSize, scale: CGFloat) {
        super.drawableSizeWillChange(render: render, size: size, scale: scale)
    }
}
