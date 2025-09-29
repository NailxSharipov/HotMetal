//
//  RenderToTexturePipline.swift
//  EncodePrepasses
//
//  Created by Nail Sharipov on 29.09.2025.
//

import HotMetal
import MetalKit

final class RenderToTexturePipline {

    private var targetTexture: MTLTexture?
    private var texture: Texture?
    private var depthTexture: MTLTexture?
    private var camera: XYCamera
    private let rectNode: RectNode
    private let passDescriptor = MTLRenderPassDescriptor()
    private var targetSize: CGSize
    private var isCleared = false
    
    init?(render: Render, size: CGSize) {
        guard let rectNode = RectNode(render: render) else { return nil }
        self.rectNode = rectNode
        let sanitized = RenderToTexturePipline.sanitize(size: size)
        self.targetSize = sanitized
        self.camera = XYCamera(width: Float(sanitized.width), height: Float(sanitized.height), anchor: .center)
        configurePassDescriptor()
        guard prepareTarget(render: render, size: sanitized) else { return nil }
        isCleared = false
    }
    
    func resize(render: Render, size: CGSize) {
        let sanitized = RenderToTexturePipline.sanitize(size: size)
        guard sanitized != targetSize else { return }
        targetSize = sanitized
        camera.update(width: Float(sanitized.width), height: Float(sanitized.height))
        rectNode.update(size: sanitized)
        _ = prepareTarget(render: render, size: sanitized)
        isCleared = false
    }
    
    func render(render: Render, time: Time, commandBuffer: MTLCommandBuffer) -> Texture? {
        guard let texture = texture, let targetTexture = targetTexture else {
            return nil
        }

        guard let attachment = passDescriptor.colorAttachments[0] else {
            return nil
        }
        attachment.texture = targetTexture
        if isCleared {
            attachment.loadAction = .load
        } else {
            attachment.loadAction = .clear
            attachment.clearColor = MTLClearColor(red: 0.05, green: 0.05, blue: 0.08, alpha: 1)
        }
        attachment.storeAction = .store

        if let depth = depthTexture, let depthAttachment = passDescriptor.depthAttachment {
            depthAttachment.texture = depth
            depthAttachment.loadAction = .clear
            depthAttachment.storeAction = .dontCare
            depthAttachment.clearDepth = 1
        }
        
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
            return nil
        }

        let context = DrawContext(render: render, encoder: encoder)

        rectNode.advance(deltaTime: time.updateTime)

        guard let uniformBuffer = render.uniformBuffers.getNext() else {
            encoder.endEncoding()
            return nil
        }

        let uniformContent = uniformBuffer.contents().bindMemory(to: Uniforms.self, capacity: 1)
        let cam = camera.camera
        uniformContent.pointee.time = Float(time.totalTime)
        uniformContent.pointee.view = cam.viewMatrix
        uniformContent.pointee.inverseView = cam.viewMatrix.inverse
        uniformContent.pointee.viewProjection = cam.projectionMatrix * cam.viewMatrix

        encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 0)
        encoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)

        rectNode.draw(context: context, parentTransform: .identity)

        encoder.endEncoding()

        commandBuffer.addCompletedHandler { [weak render] _ in
            render?.uniformBuffers.release(buffer: uniformBuffer)
        }

        isCleared = true

        return texture
    }
    
    func currentTexture() -> Texture? {
        texture
    }
    
    private func configurePassDescriptor() {
        if let attachment = passDescriptor.colorAttachments[0] {
            attachment.loadAction = .clear
            attachment.storeAction = .store
        }
    }
    
    private func prepareTarget(render: Render, size: CGSize) -> Bool {
        let width = max(1, Int(size.width))
        let height = max(1, Int(size.height))

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: render.pixelFormat,
            width: width,
            height: height,
            mipmapped: false
        )
        descriptor.usage = [.renderTarget, .shaderRead]
        descriptor.storageMode = .private

        guard let target = render.device.makeTexture(descriptor: descriptor) else {
            return false
        }
        target.label = "EncodePrepasses.Target"

        targetTexture = target

        if render.depthAttachmentPixelFormat != .invalid {
            let depthDescriptor = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: render.depthAttachmentPixelFormat,
                width: width,
                height: height,
                mipmapped: false
            )
            depthDescriptor.storageMode = .private
            depthDescriptor.usage = .renderTarget
            depthTexture = render.device.makeTexture(descriptor: depthDescriptor)
            depthTexture?.label = "EncodePrepasses.Depth"
        } else {
            depthTexture = nil
        }

        if let registered = render.textureLibrary.register(texture: target) {
            texture = registered
        } else {
            texture = nil
        }

        rectNode.update(size: size)
        camera.update(width: Float(size.width), height: Float(size.height))
        isCleared = false

        return texture != nil
    }
    
    private static func sanitize(size: CGSize) -> CGSize {
        CGSize(width: max(size.width, 1), height: max(size.height, 1))
    }
}
