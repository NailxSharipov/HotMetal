//
//  Render+MTKViewDelegate.swift
//  HotMetal
//
//  Created by Nail Sharipov on 24.04.2022.
//
import MetalKit

extension Render: MTKViewDelegate {

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        guard view.window != nil else { return }
        if let onViewReady = self.onViewReady {
            onViewReady(self, size)
            self.onViewReady = nil
        } else {
            self.onSizeWillChange?(size)
            self.scene?.drawableSizeWillChange(render: self, size: size, scale: view.scale)
        }
    }

    public func draw(in view: MTKView) {
        guard let descriptor = view.currentRenderPassDescriptor else {
            return
        }

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        guard let drawable = view.currentDrawable else {
            return
        }

        let now = Date.timeIntervalSinceReferenceDate

        let time = Time(
          totalTime: Date.timeIntervalSinceReferenceDate - creationTime,
          updateTime: now - lastTime
        )
        lastTime = now
        
        if let scene = self.scene {

            scene.update(time: time)
            
            guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                return
            }
            
            let attachment = descriptor.colorAttachments[0]
            attachment?.loadAction = .clear
            attachment?.clearColor = self.clearColor

            let context = DrawContext(render: self, encoder: encoder)
            
            // The uniform buffers store values that are constant across the entire frame
            guard let uniformBuffer = uniformBuffers.getNext() else {
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
            
            commandBuffer.addCompletedHandler { [weak self] _ in
                guard let self = self else { return }
                self.uniformBuffers.release(buffer: uniformBuffer)
            }
        }

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
}
