//
//  Material.swift
//  HotMetal
//
//  Created by Nail Sharipov on 11.04.2022.
//

import Metal

public final class Material: Hashable {
    
    public let id: UInt
    public var cullMode: MTLCullMode = .back
    public var isAffectDepthBuffer: Bool = true
    public var textures: [Texture] = []
    
    public let state: MTLRenderPipelineState

    init(id: UInt, state: MTLRenderPipelineState) {
        self.id = id
        self.state = state
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Material, rhs: Material) -> Bool {
        lhs.id == rhs.id
    }
    
}
