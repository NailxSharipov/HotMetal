//
//  ImageScene.swift
//  Image
//
//  Created by Nail Sharipov on 13.04.2022.
//

import MetalKit
import HotMetal

final class ImageScene: Scene2d {

    private let node: ImageNode
    private var start: Vector3 = .zero
    
    @MainActor
    init?(render: Render) {
        guard let node = ImageNode(render: render) else { return nil }
        self.node = node
        super.init(render: render)
        self.nodes.append(node)
    }
    
    func onStartDrag() {
        start = node.position
    }
    
    func onDrag(translation: CGSize) {
        let dx = Float(translation.width)
        let dy = Float(translation.height)
        
        node.position = .init(x: start.x + dx, y: start.y + dy, z: start.z)
        
        debugPrint("Image pos: \(node.position)")
    }

}
