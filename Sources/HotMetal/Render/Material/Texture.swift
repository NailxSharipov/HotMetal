//
//  Texture.swift
//  MetalImageView
//
//  Created by Nail Sharipov on 11.04.2022.
//

import Metal

public final class Texture {
    
    public let mltTexture: MTLTexture
    public let sampler: MTLSamplerState

    public init(mltTexture: MTLTexture, sampler: MTLSamplerState) {
        self.mltTexture = mltTexture
        self.sampler = sampler
    }
}
