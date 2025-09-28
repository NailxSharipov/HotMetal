//
//  ProgressBarScene.swift
//  ProgressBar
//
//  Created by Nail Sharipov on 17.05.2022.
//

import MetalKit
import HotMetal

final class ProgressBarScene: Scene2d {
    
    private let node: ProgressBarNode

    func set(progress: CGFloat) {
        node.progress = Float(progress)
    }

    func set(first: ProgressBarView.Line) {
        let color = Vector4(first.color.cgColor ?? .clear)
        node.first = ProgressBarNode.Line(width: Float(first.width), color: color)
    }
    
    func set(second: ProgressBarView.Line) {
        let color = Vector4(second.color.cgColor ?? .clear)
        node.second = ProgressBarNode.Line(width: Float(second.width), color: color)
    }
    
    func set(animationSpeed: CGFloat) {
        node.speed = Float(animationSpeed)
    }
    
    init?(render: Render) {
        guard let node = ProgressBarNode(render: render) else { return nil }
        self.node = node
        super.init(render: render)
        self.nodes.append(node)
    }

}
