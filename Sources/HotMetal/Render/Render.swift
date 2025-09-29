//
//  Render.swift
//  HotMetal
//
//  Created by Nail Sharipov on 11.04.2022.
//

import Foundation
import MetalKit

public final class Render: NSObject {

    public static let firstFreeVertexBufferIndex = 2

    public let device: MTLDevice
    public let materialLibrary: Material.Library
    public let textureLibrary: Texture.Library
    public let commandQueue: MTLCommandQueue
    public let pixelFormat: MTLPixelFormat
    let mainPipline: MainRenderPipline
    public let depthAttachmentPixelFormat: MTLPixelFormat

    public private(set) var scene: Scene?
    public private(set) weak var view: MTKView?
    var pendingDrawableSize: CGSize?
    private var isAttachScheduled = false

    public var scale: CGFloat {
        view?.scale ?? 1
    }

    public var screenSize: CGSize {
        if let pendingDrawableSize {
            return pendingDrawableSize
        }

        guard let size = view?.bounds.size else { return .zero }
        let s = self.scale
        return CGSize(width: s * size.width, height: s * size.height)
    }

    public let enabledDepthStencilState: MTLDepthStencilState
    public let disabledDepthStencilState: MTLDepthStencilState

    var lastTime: TimeInterval
    let creationTime: TimeInterval
    public let uniformBuffers: BufferManager

    public var onAttachScene: ((Render, CGSize) -> Scene?)?
    public var onSizeWillChange: ((CGSize) -> Void)?

    public init?(
        pixelFormat: MTLPixelFormat = .bgra8Unorm_srgb,  //.bgra8Unorm, //.bgra8Unorm_srgb
        clearColor: MTLClearColor = .init(red: 0, green: 0, blue: 0, alpha: 0),
        depthAttachmentPixelFormat: MTLPixelFormat = .depth32Float,
        onSizeWillChange: ((CGSize) -> Void)? = nil
    ) {
        self.pixelFormat = pixelFormat
        self.mainPipline = MainRenderPipline(clearColor: clearColor)
        self.depthAttachmentPixelFormat = depthAttachmentPixelFormat
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

        self.uniformBuffers = BufferManager(
            device: device,
            length: MemoryLayout<Uniforms>.size
        )

        let enabledDepthDescriptor = MTLDepthStencilDescriptor()
        enabledDepthDescriptor.isDepthWriteEnabled = true
        enabledDepthDescriptor.depthCompareFunction = .less

        guard
            let enabledDepthState = device.makeDepthStencilState(
                descriptor: enabledDepthDescriptor
            )
        else {
            return nil
        }
        enabledDepthStencilState = enabledDepthState

        let disabledDepthDescriptor = MTLDepthStencilDescriptor()
        disabledDepthDescriptor.isDepthWriteEnabled = false
        disabledDepthDescriptor.depthCompareFunction = .always

        guard
            let disabledDepthState = device.makeDepthStencilState(
                descriptor: disabledDepthDescriptor
            )
        else {
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
        view.clearColor = self.mainPipline.clearColor
        view.enableSetNeedsDisplay = false
        view.isPaused = false
#if os(macOS)
        view.enableSetNeedsDisplay = true
        view.isPaused = false
        view.preferredFramesPerSecond = 60
        view.drawableSize = view.bounds.size
#endif
    }

    public func attach(scene: Scene) {
        self.scene = scene
        guard let view = self.view else { return }
        let scale = view.scale
        let size =
            pendingDrawableSize
            ?? CGSize(
                width: scale * view.bounds.size.width,
                height: scale * view.bounds.size.height
            )

        view.drawableSize = size

        scene.drawableSizeWillChange(render: self, size: size, scale: scale)
    }

    public func defaultPipelineDescriptor() -> MTLRenderPipelineDescriptor {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = self.pixelFormat
        descriptor.depthAttachmentPixelFormat = self.depthAttachmentPixelFormat
        return descriptor
    }

    public func redraw() {
        guard let view = view else { return }
        assert(view.enableSetNeedsDisplay)
#if os(macOS)
        view.setNeedsDisplay(view.bounds)
#else
        view.setNeedsDisplay()
#endif
    }

    @discardableResult
    func attachSceneIfNeeded() -> Bool {
        guard scene == nil else {
            return true
        }

        guard let view = view, view.window != nil else {
            scheduleDeferredAttach()
            return false
        }

        if let scene = self.onAttachScene?(self,
                                           pendingDrawableSize
                                                ?? CGSize(
                                                    width: view.scale * view.bounds.size.width,
                                                    height: view.scale * view.bounds.size.height
                                                )) {
            self.attach(scene: scene)

            let size = pendingDrawableSize
                ?? CGSize(
                    width: view.bounds.size.width * view.scale,
                    height: view.bounds.size.height * view.scale
                )

            view.drawableSize = size
#if os(macOS)
            view.setNeedsDisplay(CGRect(origin: .zero, size: view.bounds.size))
#else
            view.setNeedsDisplay()
#endif
            return true
        } else {
            return false
        }
    }

    private func scheduleDeferredAttach() {
        guard !isAttachScheduled else { return }
        isAttachScheduled = true
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isAttachScheduled = false
            _ = self.attachSceneIfNeeded()
        }
    }
}
