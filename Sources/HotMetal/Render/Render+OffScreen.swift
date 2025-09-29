//
//  Render+OffScreen.swift
//  HotMetal
//
//  Created by Nail Sharipov on 15.04.2022.
//

import MetalKit

public extension Render {

    func doShot(width: Int, height: Int) -> MTLTexture? {
        let targetDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: self.pixelFormat,
            width: width,
            height: height,
            mipmapped: false
        )
        targetDescriptor.textureType = .type2D
        targetDescriptor.usage = [.renderTarget, .shaderRead]
        
        let target = device.makeTexture(descriptor: targetDescriptor)
        
        let descriptor = MTLRenderPassDescriptor()
        
        if let colorAttachment = descriptor.colorAttachments[0] {
            colorAttachment.texture = target
            colorAttachment.loadAction = .clear
            colorAttachment.clearColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
            colorAttachment.storeAction = .store
        }
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return nil
        }
        
        let uniformBuffers = BufferManager(device: device, length: MemoryLayout<Uniforms>.size)
        
        guard let scene = self.scene else {
            return nil
        }
            
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return nil
        }
        
        if let attachment = descriptor.colorAttachments[0] {
            attachment.loadAction = .clear
            attachment.clearColor = self.mainPipline.clearColor
        }

        let context = DrawContext(render: self, encoder: encoder)
        
        // The uniform buffers store values that are constant across the entire frame
        guard let uniformBuffer = uniformBuffers.getNext() else {
            return nil
        }
        let uniformContent = uniformBuffer.contents().bindMemory(to: Uniforms.self, capacity: 1)

        let viewMatrix = scene.mainCamera.viewMatrix

        uniformContent.pointee.time = Float(0)
        uniformContent.pointee.view = viewMatrix
        uniformContent.pointee.inverseView = viewMatrix.inverse
        uniformContent.pointee.viewProjection = scene.mainCamera.projectionMatrix * viewMatrix

        encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 0)
        encoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)
        
        scene.draw(context: context)

        encoder.endEncoding()
        
        commandBuffer.addCompletedHandler { _ in
            uniformBuffers.release(buffer: uniformBuffer)
        }

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        return target
    }
    
}
