//
//  Render.swift
//  HotMetal
//
//  Created by Nail Sharipov on 11.04.2022.
//

import MetalKit
import Foundation

public final class Render: NSObject {

    public static let firstFreeVertexBufferIndex = 2
    
    public let device: MTLDevice
    public let materialLibrary: Material.Library
    public let textureLibrary: Texture.Library
    public let commandQueue: MTLCommandQueue
    public let pixelFormat: MTLPixelFormat
    public let depthAttachmentPixelFormat: MTLPixelFormat

    public var scene: Scene?
    public private (set) weak var view: MTKView?
    
    var enabledDepthStencilState: MTLDepthStencilState
    var disabledDepthStencilState: MTLDepthStencilState

    private var lastTime: TimeInterval
    private let creationTime: TimeInterval
    private let uniformBuffers: BufferManager

    public let onViewReady: ((Render) -> ())?

    public init(
        pixelFormat: MTLPixelFormat = .bgra8Unorm_srgb, //.bgra8Unorm, //.bgra8Unorm_srgb
        depthAttachmentPixelFormat: MTLPixelFormat = .depth32Float,
        onViewReady: ((Render) -> ())? = nil
    ) {
        self.pixelFormat = pixelFormat
        self.depthAttachmentPixelFormat = depthAttachmentPixelFormat
        self.onViewReady = onViewReady
        
        self.device = MTLCreateSystemDefaultDevice()!
        self.materialLibrary = Material.Library(device: self.device)
        self.textureLibrary = Texture.Library(device: self.device)

        self.commandQueue = device.makeCommandQueue()!

        self.uniformBuffers = BufferManager(device: device, length: MemoryLayout<Uniforms>.size)

        let enabledDepthDescriptor = MTLDepthStencilDescriptor()
        enabledDepthDescriptor.isDepthWriteEnabled = true
        enabledDepthDescriptor.depthCompareFunction = .less
        enabledDepthStencilState = device.makeDepthStencilState(descriptor: enabledDepthDescriptor)!

        let disabledDepthDescriptor = MTLDepthStencilDescriptor()
        disabledDepthDescriptor.isDepthWriteEnabled = false
        disabledDepthDescriptor.depthCompareFunction = .always
        disabledDepthStencilState = device.makeDepthStencilState(descriptor: disabledDepthDescriptor)!
        
        creationTime = Date.timeIntervalSinceReferenceDate
        lastTime = creationTime
        
        super.init()
        
        self.materialLibrary.render = self
    }
    
    public func attach(view: MTKView) {
        assert(self.view == nil, "View is already present")
        self.view = view
        view.device = device
        view.delegate = self

        view.colorPixelFormat = self.pixelFormat
        view.depthStencilPixelFormat = self.depthAttachmentPixelFormat
        view.framebufferOnly = true
//        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
//        view.enableSetNeedsDisplay = true
//        view.isPaused = false

        self.onViewReady?(self)
    }
    
    public func defaultPipelineDescriptor() -> MTLRenderPipelineDescriptor {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = self.pixelFormat
        descriptor.depthAttachmentPixelFormat = self.depthAttachmentPixelFormat
        return descriptor
    }

}

extension Render: MTKViewDelegate {

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        if let scene = self.scene {
            scene.camera.update(aspectRatio: Float(size.width / size.height))
            scene.drawableSizeWillChange(view, render: self, size: size)
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
            attachment?.clearColor = scene.clearColor

            let context = DrawContext(render: self, encoder: encoder)
            
            // The uniform buffers store values that are constant across the entire frame
            let uniformBuffer = uniformBuffers.getNext()
            let uniformContent = uniformBuffer.contents().bindMemory(to: Uniforms.self, capacity: 1)

            let viewMatrix = scene.camera.viewMatrix

            uniformContent.pointee.time = Float(time.totalTime)
            uniformContent.pointee.view = viewMatrix
            uniformContent.pointee.inverseView = viewMatrix.inverse
            uniformContent.pointee.viewProjection = scene.camera.projectionMatrix * viewMatrix

//            encoder.setDepthStencilState(enabledDepthStencilState)
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
