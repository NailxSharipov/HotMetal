//
//  MainScene.swift
//  EncodePrepasses
//
//  Created by Nail Sharipov on 29.09.2025.
//

import MetalKit
import HotMetal

final class MainScene: Scene2d {

    private let textureNode: TextureNode
    private let texturePipline: RenderToTexturePipline
    
    @MainActor
    init?(render: Render, drawableSize: CGSize) {
        guard
            let textureNode = TextureNode(render: render),
            let texturePipline = RenderToTexturePipline(render: render, size: MainScene.sanitize(size: drawableSize))
        else {
            return nil
        }
        self.textureNode = textureNode
        self.texturePipline = texturePipline
        super.init(render: render)
        self.nodes.append(textureNode)

        let initialSize = MainScene.sanitize(size: drawableSize)
        textureNode.updateSize(initialSize)
        if let texture = texturePipline.currentTexture() {
            textureNode.updateTexture(texture)
        }
    }
    
    override func drawableSizeWillChange(render: Render, size: CGSize, scale: CGFloat) {
        super.drawableSizeWillChange(render: render, size: size, scale: scale)
        let safeSize = MainScene.sanitize(size: size)
        textureNode.updateSize(safeSize)
        texturePipline.resize(render: render, size: safeSize)
    }
    
    override func encodePrepasses(render: Render, time: Time, descriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {
        if let texture = texturePipline.render(render: render, time: time, commandBuffer: commandBuffer) {
            textureNode.updateTexture(texture)
        }
    }
    
    private static func sanitize(size: CGSize) -> CGSize {
        if size.width <= 0 || size.height <= 0 {
            return CGSize(width: 256, height: 256)
        }
        return size
    }
}
