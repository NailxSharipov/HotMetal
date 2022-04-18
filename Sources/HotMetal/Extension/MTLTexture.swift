//
//  MTLTexture.swift
//  HotMetal
//
//  Created by Nail Sharipov on 15.04.2022.
//

import Metal
import CoreImage
import CoreGraphics

public extension MTLTexture {
    
    func image() -> CGImage? {
        guard let ciImage = CIImage(
            mtlTexture: self,
            options: [
                CIImageOption.applyOrientationProperty: true
            ]
        ) else {
            return nil
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let size = CGSize(width: width, height: height)

        let ciCtx = CIContext()
        let image = ciCtx.createCGImage(
            ciImage,
            from: .init(origin: .zero, size: size),
            format: CIFormat.RGBA8,
            colorSpace: colorSpace
        )

        return image
    }

}
