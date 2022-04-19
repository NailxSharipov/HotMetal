//
//  CGImageSource.swift
//  HotMetal
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
    
    static func read(url: URL, device: MTLDevice) -> Source? {
        guard let imgSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }

        return imgSource.source(device: device)
    }
    
    func source(device: MTLDevice) -> Source? {
        guard let image = CGImageSourceCreateImageAtIndex(self, 0, nil) else {
            return nil
        }
        
        guard let buffer = CVPixelBuffer.open(source: self) else {
            return nil
        }
        
        // .r16Float
        guard let texture = buffer.makeTexture(device: device) else {
            return nil
        }

        return Source(image: image, depth: texture)
    }
}
