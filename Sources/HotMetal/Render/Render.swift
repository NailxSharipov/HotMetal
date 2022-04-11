//
//  Render.swift
//  MetalImageView
//
//  Created by Nail Sharipov on 11.04.2022.
//

import MetalKit

public final class Render: NSObject {

    public static let firstFreeVertexBufferIndex = 0
    
    public let device: MTLDevice
    public let library: MTLLibrary
    public let commandQueue: MTLCommandQueue
    public var scene: Renderable?
    private unowned var view: MTKView!
    
    public let onAttach: (MTKView) -> ()
    public let onReady: (Render) -> ()
    
    public var delegate: MTKViewDelegate? {
        get {
            view.delegate
        }
        set {
            view.delegate = newValue
        }
    }

    public init(onAttach: @escaping (MTKView) -> () = MTKView.defaultOnAttach, onReady: @escaping (Render) -> ()) {
        self.onAttach = onAttach
        self.onReady = onReady
        self.device = MTLCreateSystemDefaultDevice()!
        self.library = device.makeDefaultLibrary()!
        self.commandQueue = device.makeCommandQueue()!
        super.init()
    }
    
    public func attach(view: MTKView) {
        view.device = device
        view.delegate = self
        self.onAttach(view)
        self.view = view
        self.onReady(self)
    }
    
    public func defaultPipelineDescriptor() -> MTLRenderPipelineDescriptor {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        descriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat
        return descriptor
    }

}

extension Render: MTKViewDelegate {

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        scene?.drawableSizeWillChange(view, size: size)
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

        if let scene = self.scene {
            let attachment = descriptor.colorAttachments[0]
            attachment?.loadAction = .clear
            attachment?.clearColor = scene.clearColor

            guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                return
            }

            scene.draw(render: self, encoder: encoder)

            encoder.endEncoding()
        }

        commandBuffer.present(drawable)
        commandBuffer.commit()
  }
}

public extension MTKView {
    
    static var defaultOnAttach: (MTKView) -> () = { view in
        view.preferredFramesPerSecond = 60
        view.framebufferOnly = false
        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.enableSetNeedsDisplay = true
        view.isPaused = false
        view.colorPixelFormat = .bgra8Unorm
    }
}
