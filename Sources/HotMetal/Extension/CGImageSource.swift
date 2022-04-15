//
//  File.swift
//  
//
//  Created by Nail Sharipov on 15.04.2022.
//

import ImageIO
import AVFoundation
import Metal

public extension CGImageSource {
    
    struct Source {
        public let image: CGImage
        public let depth: MTLTexture
    }
    
    static func read(url: URL, device: MTLDevice) -> Source {
        let source = CGImageSourceCreateWithURL(url as CFURL, nil)!
        
        let image = CGImageSourceCreateImageAtIndex(source, 0, nil)!
        
        let buffer = CVPixelBuffer.open(source: source)!
        
        let texture = buffer.makeTexture(device: device) // .r16Float

        return Source(image: image, depth: texture)
    }
}
