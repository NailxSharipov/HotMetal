//
//  SphereScene.swift
//  Sphere
//
//  Created by Nail Sharipov on 29.08.2022.
//

import MetalKit
import HotMetal

final class SphereScene: Scene {

    var nodes = [Node]()
    
    var mainCamera: Camera

    public var z: Float = 0 {
        didSet {
            node.position.z = z
            debugPrint("Sphere pos: \(node.position)")
        }
    }
    
    private let node: SphereNode
    private var start: Vector3 = .zero
    
    @MainActor
    init?(render: Render) {
        guard let node = SphereNode(render: render) else { return nil }
        let width = render.view?.bounds.width ?? 1
        let height = render.view?.bounds.height ?? 1
        let aspectRatio = Float(width / height)
        self.mainCamera = Camera(aspectRatio: aspectRatio)
        self.node = node
        self.nodes.append(node)
    }

    func onStartDrag() {
        start = node.position
    }
    
    func onContinueDrag(translation: CGSize) {
        let dx = 0.01 * Float(translation.width)
        let dy = 0.01 * Float(translation.height)
        
        node.position = .init(x: start.x + dx, y: start.y + dy, z: z)
        
        debugPrint("Sphere pos: \(node.position)")
    }
 
    func onEndDrag(translation: CGSize) {
        let dx = 0.01 * Float(translation.width)
        let dy = 0.01 * Float(translation.height)
        node.position = .init(x: start.x + dx, y: start.y + dy, z: z)
        
        debugPrint("Sphere pos: \(node.position)")
    }
    
    func drawableSizeWillChange(render: Render, size: CGSize, scale: CGFloat) {
        let width = Float(size.width)
        let height = Float(size.height)
        let aspectRatio = width / height
        self.mainCamera.update(aspectRatio: aspectRatio)
    }
    
}
