//
//  RenderToTextureFlow.swift
//  EncodePrepasses
//
//  Created by Nail Sharipov on 29.09.2025.
//

import HotMetal
import Metal

struct RenderToTextureFlow {

    let state: MTLRenderPipelineState
    
    init?(render: Render, width: Int, height: Int) {
        let desc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm_srgb,
            width: width,
            height: height,
            mipmapped: false
        )
        desc.usage = [.shaderRead, .renderTarget]

        guard
            let metalTexture = render.device.makeTexture(descriptor: desc),
            let texture = render.textureLibrary.register(texture: metalTexture),
            let state = Self.makePiplineState(
                device: render.device,
                render: render,
                pixelFormat: metalTexture.pixelFormat
            )
        else { return nil }

        self.state = state
    }
    
    private static func makePiplineState(
        device: MTLDevice,
        render: Render,
        pixelFormat: MTLPixelFormat
    )
        -> MTLRenderPipelineState?
    {
        let desc = MTLRenderPipelineDescriptor()
        desc.colorAttachments[0].pixelFormat = pixelFormat
        desc.colorAttachments[0].isBlendingEnabled = false

        desc.vertexFunction = render.materialLibrary.load(.local("vertexSolid"))
        desc.fragmentFunction = render.materialLibrary.load(
            .local("fragmentSolid")
        )

        return try? device.makeRenderPipelineState(descriptor: desc)
    }
}
