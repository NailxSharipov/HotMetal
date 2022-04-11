//
//  Material.swift
//  MetalImageView
//
//  Created by Nail Sharipov on 11.04.2022.
//

import Metal

open class Material: Equatable {

    let id = UUID()
    
    func install(encoder: MTLRenderCommandEncoder) {
        assertionFailure("Not implemented")
    }
    
    public static func == (lhs: Material, rhs: Material) -> Bool {
        lhs.id == rhs.id
    }
    
}
