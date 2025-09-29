//
//  Render+MTKViewDelegate.swift
//  HotMetal
//
//  Created by Nail Sharipov on 24.04.2022.
//
import MetalKit

extension Render: MTKViewDelegate {

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        if size.width > 0 && size.height > 0 {
            pendingDrawableSize = size
        }

        if let scene = self.scene {
            self.onSizeWillChange?(size)
            scene.drawableSizeWillChange(render: self, size: size, scale: view.scale)
        } else {
            _ = self.attachSceneIfNeeded()
        }
    }

    public func draw(in view: MTKView) {
        let drawableSize = view.drawableSize
        if drawableSize.width > 0 && drawableSize.height > 0 {
            pendingDrawableSize = drawableSize
        }

        guard self.attachSceneIfNeeded() else {
            return
        }

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

            scene.encodePrepasses(render: self, time: time, descriptor: descriptor, commandBuffer: commandBuffer)
            
            self.mainPipline.render(render: self, scene: scene, time: time, descriptor: descriptor, commandBuffer: commandBuffer)
        }

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
}
