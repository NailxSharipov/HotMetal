//
//  Node.swift
//  MetalImageView
//
//  Created by Nail Sharipov on 11.04.2022.
//

open class Node {
    
    public var mesh: Mesh?
    public var material: Material?
    
    public init(mesh: Mesh, material: Material) {
        self.mesh = mesh
        self.material = material
    }
    
    public init() {
        self.mesh = nil
        self.material = nil
    }

    public func draw(context: DrawContext) {
        guard
            let mesh = self.mesh,
            let material = self.material
        else {
            return
        }
        
        if context.currentMaterial != material {
            material.install(encoder: context.encoder)
            context.currentMaterial = material
        }

        mesh.draw(context: context)
    }
    
}

