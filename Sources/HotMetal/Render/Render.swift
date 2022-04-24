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
    public let clearColor: MTLClearColor
    public let depthAttachmentPixelFormat: MTLPixelFormat

    public private (set) var scene: Scene?
    public private (set) weak var view: MTKView?
    
    public var scale: CGFloat {
        view?.scale ?? 1
    }
    
    public var screenSize: CGSize {
        guard let size = view?.bounds.size else { return .zero }
        let s = self.scale
        return CGSize(width: s * size.width, height: s * size.height)
    }
    
    var enabledDepthStencilState: MTLDepthStencilState
    var disabledDepthStencilState: MTLDepthStencilState

    var lastTime: TimeInterval
    let creationTime: TimeInterval
    let uniformBuffers: BufferManager

    public var onViewReady: ((Render) -> ())?
    public var onSizeWillChange: ((CGSize) -> ())?

    public init?(
        pixelFormat: MTLPixelFormat = .bgra8Unorm_srgb, //.bgra8Unorm, //.bgra8Unorm_srgb
        clearColor: MTLClearColor = .init(red: 0, green: 0, blue: 0, alpha: 0),
        depthAttachmentPixelFormat: MTLPixelFormat = .depth32Float,
        onViewReady: ((Render) -> ())? = nil,
        onSizeWillChange: ((CGSize) -> ())? = nil
    ) {
        self.pixelFormat = pixelFormat
        self.clearColor = clearColor
        self.depthAttachmentPixelFormat = depthAttachmentPixelFormat
        self.onViewReady = onViewReady
        self.onSizeWillChange = onSizeWillChange
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            return nil
        }
        
        self.device = device
        self.materialLibrary = Material.Library(device: self.device)
        self.textureLibrary = Texture.Library(device: self.device)

        guard let commandQueue = device.makeCommandQueue() else {
            return nil
        }
        
        self.commandQueue = commandQueue

        self.uniformBuffers = BufferManager(device: device, length: MemoryLayout<Uniforms>.size)

        let enabledDepthDescriptor = MTLDepthStencilDescriptor()
        enabledDepthDescriptor.isDepthWriteEnabled = true
        enabledDepthDescriptor.depthCompareFunction = .less
        
        guard let enabledDepthState = device.makeDepthStencilState(descriptor: enabledDepthDescriptor) else {
            return nil
        }
        enabledDepthStencilState = enabledDepthState

        let disabledDepthDescriptor = MTLDepthStencilDescriptor()
        disabledDepthDescriptor.isDepthWriteEnabled = false
        disabledDepthDescriptor.depthCompareFunction = .always
        
        guard let disabledDepthState = device.makeDepthStencilState(descriptor: disabledDepthDescriptor) else {
            return nil
        }
        disabledDepthStencilState = disabledDepthState
        
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
        view.clearColor = clearColor
//        view.enableSetNeedsDisplay = true
//        view.isPaused = false

        self.onViewReady?(self)
    }
    
    public func attach(scene: Scene) {
        self.scene = scene
        guard let view = self.view else { return }
        let scale = view.scale
        let size = CGSize(
            width: scale * view.bounds.size.width,
            height: scale * view.bounds.size.height
        )

        scene.drawableSizeWillChange(render: self, size: size, scale: scale)
    }
    
    public func defaultPipelineDescriptor() -> MTLRenderPipelineDescriptor {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = self.pixelFormat
        descriptor.depthAttachmentPixelFormat = self.depthAttachmentPixelFormat
        return descriptor
    }

}
