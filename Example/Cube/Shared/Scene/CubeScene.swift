//
//  CubeScene.swift
//  Cube
//
//  Created by Nail Sharipov on 12.04.2022.
//

import MetalKit
import HotMetal

final class CubeScene: Scene {

    public var z: Float = 0 {
        didSet {
            node.position.z = z
            debugPrint("Cube pos: \(node.position)")
        }
    }
    
    private let node: CubNode
    private var start: Vector3 = .zero
    
    init(render: Render) {
        self.node = CubNode(render: render)
        super.init()
        self.nodes.append(node)
        self.clearColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
    }

    func onStartDrag() {
        start = node.position
    }
    
    func onContinueDrag(translation: CGSize) {
        let dx = 0.01 * Float(translation.width)
        let dy = 0.01 * Float(translation.height)
        
        node.position = .init(x: start.x + dx, y: start.y + dy, z: z)
        
        debugPrint("Cube pos: \(node.position)")
    }
 
    func onEndDrag(translation: CGSize) {
        let dx = 0.01 * Float(translation.width)
        let dy = 0.01 * Float(translation.height)
        node.position = .init(x: start.x + dx, y: start.y + dy, z: z)
        
        debugPrint("Cube pos: \(node.position)")
    }
    
}
