//
//  Texture.swift
//  HotMetal
//
//  Created by Nail Sharipov on 11.04.2022.
//

import Metal

public final class Texture: Hashable {
    
    public let id: UInt
    public let mltTexture: MTLTexture
    public let sampler: MTLSamplerState
    
    public init(id: UInt, mltTexture: MTLTexture, sampler: MTLSamplerState) {
        self.id = id
        self.mltTexture = mltTexture
        self.sampler = sampler
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Texture, rhs: Texture) -> Bool {
        lhs.id == rhs.id
    }
}
