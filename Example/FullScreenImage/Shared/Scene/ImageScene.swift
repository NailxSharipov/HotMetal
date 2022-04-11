//
//  ImageScene.swift
//  FullScreenImage
//
//  Created by Nail Sharipov on 11.04.2022.
//

import MetalKit
import HotMetal

final class ImageScene {
    
    private let meshBuilder = MeshBuilder()
    private var imageSize: CGSize = .zero
    private var material: SpriteMaterial?
    
    let clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
    
    func set(render: Render, image: CGImage) {
        let texture = render.loadTexture(image: image)
        self.imageSize = image.size
        
        self.material = SpriteMaterial(
            render: render,
            vertexName: "vertexShader",
            fragmentName: "fragmentShader",
            texture: texture
        )
    }
    
}

extension ImageScene: Renderable {
    
    func draw(render: Render, encoder: MTLRenderCommandEncoder) {
        guard let material = self.material else { return }
        guard let mesh = meshBuilder.mesh(device: render.device) else {
            return
        }

        encoder.setRenderPipelineState(material.renderPipelineState)
        encoder.setVertexBuffer(mesh.vertexBuffer, offset: 0, index: 0)
        
//        encoder.setFragmentTexture(texture, index: 0)
//        encoder.setFragmentSamplerState(sampler, index: 0)

        encoder.drawIndexedPrimitives(type: .triangle, indexCount: mesh.count, indexType: .uint16, indexBuffer: mesh.indexBuffer, indexBufferOffset: 0)
    }
    
    func drawableSizeWillChange(_ view: MTKView, size: CGSize) {
        meshBuilder.viewSize = view.bounds.size
        meshBuilder.cropRect = CGRect(origin: .zero, size: imageSize)
    }

}


private extension CGImage {
    
    var size: CGSize {
        CGSize(width: width, height: height)
    }
   
}
