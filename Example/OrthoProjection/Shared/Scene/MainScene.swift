//
//  MainScene.swift
//  OrthoProjection
//
//  Created by Nail Sharipov on 23.04.2022.
//

import MetalKit
import HotMetal

final class MainScene: Scene {

    var mainCamera: Camera { camera }
    
    var nodes: [Node] = []
    private let crate: Node
    
    private var camera: Camera {
        self.xyCamera.camera
    }
    private var xyCamera: XYCamera
    
    private var start: Vector3 = .zero
    private var width: Float
    private var height: Float
    
    init?(render: Render, anchor: XYCamera.Anchor) {
        guard
            let mainNode = SpriteNode(render: render, name: "CoordSystem"),
            let crate = SpriteNode(render: render, name: "Crate", scale: 0.2)
        else { return nil }
        mainNode.material?.isAffectDepthBuffer = false
        crate.material?.isAffectDepthBuffer = false

        self.crate = crate
        self.nodes.append(mainNode)
        self.nodes.append(crate)
        
        self.height = Float(render.view?.bounds.height ?? 0)
        self.width = Float(render.view?.bounds.width ?? 0)

        xyCamera = XYCamera(
            position: Vector2.zero,
            width: width,
            height: height,
            anchor: anchor
        )
    }

    func drawableSizeWillChange(render: Render, size: CGSize, scale: CGFloat) {
        self.width = Float(size.width)
        self.height = Float(size.height)
        xyCamera.update(width: width, height: height)
    }
    
    func onStartDrag() {
        start = crate.position
    }
    
    func rotate(angle: Float) {
        xyCamera.update(angle: angle)
    }
    
    func onDrag(translation: CGSize) {
        let dx = Float(translation.width)
        let dy = Float(translation.height)
        
        crate.position = .init(x: start.x + dx, y: start.y + dy, z: start.z)

        debugPrint("pos: \(crate.position)")
    }
    
    func update(anchor: XYCamera.Anchor) {
        xyCamera.update(width: width, height: height, anchor: anchor)
    }

}
