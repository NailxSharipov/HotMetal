//
//  HeicLoader.swift
//  TwoTextures
//
//  Created by Nail Sharipov on 14.04.2022.
//

import Foundation
import ImageIO
import HotMetal

final class HeicLoader {

    struct Resource {
        let size: CGSize
        let textures: [Texture]
    }
    
    func load(render: Render, fileName: String) -> Resource? {
        guard
            let url = Bundle.main.url(forResource: fileName, withExtension: "heic"),
            let source = CGImageSource.read(url: url, device: render.device),
            let texture0 = render.textureLibrary.loadTexture(image: source.image, gammaCorrection: true),
            let texture1 = render.textureLibrary.register(texture: source.depth)
        else {
            return nil
        }
        
        let width = CGFloat(source.image.width)
        let height = CGFloat(source.image.height)
        
        return Resource(size: .init(width: width, height: height), textures: [texture0, texture1])
    }

}
