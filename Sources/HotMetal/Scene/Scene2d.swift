//
//  Scene2d.swift
//  HotMetal
//
//  Created by Nail Sharipov on 24.04.2022.
//

import MetalKit

open class Scene2d: Scene {

    public var nodes: [Node] = []
    public var xyCamera: XYCamera

    public var mainCamera: Camera {
        xyCamera.camera
    }

    public init?(render: Render, anchor: XYCamera.Anchor = .center) {
        let size = render.screenSize
        let height = Float(size.height)
        let width = Float(size.width)
        xyCamera = XYCamera(width: width, height: height, anchor: anchor)
    }

    open func drawableSizeWillChange(render: Render, size: CGSize, scale: CGFloat) {
        xyCamera.update(width: Float(size.width), height: Float(size.height))
    }
    
    open func encodePrepasses(render: Render, commandBuffer: MTLCommandBuffer) {}

}
