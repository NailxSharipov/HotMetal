//
//  Material.swift
//  HotMetal
//
//  Created by Nail Sharipov on 11.04.2022.
//

import Metal

public struct Material: Hashable {

    public let id: Int
    public var cullMode: MTLCullMode = .front
    public var isAffectDepthBuffer: Bool = true
    let state: MTLRenderPipelineState

    init(id: Int, state: MTLRenderPipelineState) {
        self.id = id
        self.state = state
    }
    
    init(category: Library.Category, state: MTLRenderPipelineState) {
        self.id = category.rawValue
        self.state = state
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Material, rhs: Material) -> Bool {
        lhs.id == rhs.id
    }
    
}
