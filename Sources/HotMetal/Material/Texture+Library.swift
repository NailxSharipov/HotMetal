//
//  Texture+Library.swift
//  HotMetal
//
//  Created by Nail Sharipov on 14.04.2022.
//

import MetalKit

public extension Texture {

    final class Library {

        private var nextId: UInt = 0
        private var store: [UInt: Texture] = [:]
        private let device: MTLDevice
        
        init(device: MTLDevice) {
            self.device = device
        }
        
    }
}

public extension Texture.Library {

    func get(id: UInt) -> Texture? {
        store[id]
    }

    func loadTexture(
        image: CGImage,
        samplerDescriptor: MTLSamplerDescriptor = .linear,
        mipmaps: Bool = true,
        gammaCorrection: Bool = true
    ) -> Texture? {
        let loader = MTKTextureLoader(device: device)
        
        guard let mltTexture = try? loader.newTexture(
            cgImage: image,
            options: [
                .generateMipmaps: mipmaps,
                MTKTextureLoader.Option.SRGB: gammaCorrection
            ]
        ) else {
            return nil
        }
        
        guard let sampler = self.device.makeSamplerState(descriptor: samplerDescriptor) else {
            return nil
        }
        
        let id = nextId
        nextId += 1
        
        return Texture(id: id, mltTexture: mltTexture, sampler: sampler)
    }

    func loadTexture(
        name: String,
        samplerDescriptor: MTLSamplerDescriptor = .linear,
        mipmaps: Bool = true
    ) -> Texture? {
        let loader = MTKTextureLoader(device: device)
        
        guard let mltTexture = try? loader.newTexture(
            name: name,
            scaleFactor: 1.0,
            bundle: nil,
            options: [
                .generateMipmaps: mipmaps,
                MTKTextureLoader.Option.SRGB: false
            ]
        ) else {
            return nil
        }
        
        guard let sampler = self.device.makeSamplerState(descriptor: samplerDescriptor) else {
            return nil
        }
        
        let id = nextId
        nextId += 1
        
        return Texture(id: id, mltTexture: mltTexture, sampler: sampler)
    }
    
    func register(texture: MTLTexture, samplerDescriptor: MTLSamplerDescriptor = .linear) -> Texture? {
        let id = nextId
        nextId += 1

        guard let sampler = self.device.makeSamplerState(descriptor: samplerDescriptor) else {
            return nil
        }
        let material = Texture(id: id, mltTexture: texture, sampler: sampler)
        
        store[id] = material
        
        return material
    }
    
}

public extension MTLSamplerDescriptor {
    
    static var linear: MTLSamplerDescriptor = {
        let descriptor = MTLSamplerDescriptor()
        descriptor.normalizedCoordinates = true
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        descriptor.mipFilter = .linear
        return descriptor
    }()
    
}
