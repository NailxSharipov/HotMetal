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
    private let node = ImageNode()
    
    let clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
    
    func set(render: Render, image: CGImage) {
        let texture = render.loadTexture(image: image, mipmaps: false)
        self.imageSize = image.size
        
        node.material = SpriteMaterial(
            render: render,
            vertexName: "vertexShader",
            fragmentName: "fragmentShader",
            texture: texture
        )
    }
    
}

extension ImageScene: Renderable {
    
    func draw(context: DrawContext) {
        node.draw(context: context)
    }
    
    func drawableSizeWillChange(_ view: MTKView, render: Render, size: CGSize) {
        let viewSize = view.bounds.size
        let cropRect = CGRect(origin: .zero, size: imageSize)
        
        node.update(device: render.device, viewSize: viewSize, cropRect: cropRect)
    }

}


private extension CGImage {
    
    var size: CGSize {
        CGSize(width: width, height: height)
    }
   
}
