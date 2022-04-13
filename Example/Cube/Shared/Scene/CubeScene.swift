//
//  CubeScene.swift
//  Cube
//
//  Created by Nail Sharipov on 12.04.2022.
//

import MetalKit
import HotMetal

final class CubeScene: Scene {

    private let node: CubNode
    private var start: Vector3 = .zero
    
    init(render: Render) {
        self.node = CubNode(render: render)
        super.init()
        self.nodes.append(node)
        self.clearColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
        camera = Camera(
            origin: [0, 0, -5],
            look: [0, 0, 1],
            up: [0, 1, 0],
            projection: .perspective(90),
            aspectRatio: 1.0,
            zNear: 0.001,
            zFar: 1000.0
        )
    }

    func onStartDrag() {
        start = node.position
    }
    
    func onContinueDrag(translation: CGSize) {
        let dx = 0.01 * Float(translation.width)
        let dy = 0.01 * Float(translation.height)
        
        node.position = .init(x: start.x + dx, y: start.y + dy, z: start.z)
        
        debugPrint("Cube pos: \(node.position)")
    }
 
    func onEndDrag(translation: CGSize) {
        let dx = 0.01 * Float(translation.width)
        let dy = 0.01 * Float(translation.height)
        node.position = .init(x: start.x + dx, y: start.y + dy, z: start.z)
        
        debugPrint("Cube pos: \(node.position)")
    }
    
    
    override func drawableSizeWillChange(_ view: MTKView, render: Render, size: CGSize) {
//        camera.projection = .ortographic(Float(size.height))
    }
    
}
