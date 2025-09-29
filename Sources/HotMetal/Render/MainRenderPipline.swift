//
//  RenderPipline.swift
//  HotMetal
//
//  Created by Nail Sharipov on 29.09.2025.
//

import MetalKit

final class MainRenderPipline {

    let clearColor: MTLClearColor
    
    init(clearColor: MTLClearColor) {
        self.clearColor = clearColor
    }
    
    func render(
        render: Render,
        scene: Scene,
        time: Time,
        descriptor: MTLRenderPassDescriptor,
        commandBuffer: MTLCommandBuffer
    ) {
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        
        let attachment = descriptor.colorAttachments[0]
        attachment?.loadAction = .clear
        attachment?.clearColor = self.clearColor

        let context = DrawContext(render: render, encoder: encoder)
        
        // The uniform buffers store values that are constant across the entire frame
        guard let uniformBuffer = render.uniformBuffers.getNext() else {
            return
        }
        let uniformContent = uniformBuffer.contents().bindMemory(to: Uniforms.self, capacity: 1)

        let viewMatrix = scene.mainCamera.viewMatrix

        uniformContent.pointee.time = Float(time.totalTime)
        uniformContent.pointee.view = viewMatrix
        uniformContent.pointee.inverseView = viewMatrix.inverse
        uniformContent.pointee.viewProjection = scene.mainCamera.projectionMatrix * viewMatrix

        encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 0)
        encoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)
        
        scene.draw(context: context)

        encoder.endEncoding()
        
        commandBuffer.addCompletedHandler { [weak render] _ in
            render?.uniformBuffers.release(buffer: uniformBuffer)
        }
    }
    
}
