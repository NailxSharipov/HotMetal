//
//  Node.swift
//  MetalImageView
//
//  Created by Nail Sharipov on 11.04.2022.
//

import simd

open class Node {
    
    public var position = Vector3(0, 0, 0)
    public var orientation = Quaternion.identity
    public var scale = Vector3(1, 1, 1)

    /// If provided the transform property will return this value vs. combining the pos / scale / orientation values
    public var overrideTransform: Matrix4?
    
    /**
     Returns a matrix that is the combination of the position, orientation and scale properties.
     These are applied in scale -> rotate -> translate order.
     */
    public var transform: Matrix4 {
        if let overrideTransform = overrideTransform {
            return overrideTransform
        }
        let translate = Matrix4.translate(position)
        let s = Matrix4.scale(scale.x, scale.y, scale.z)
        return translate * Matrix4(quaternion: orientation) * s
    }

    /// If true this node and all of its descendents are not rendered
    public var isHidden = false
    
    public var mesh: Mesh?
    public var material: Material?
    public var nodes: [Node] = []
    
    public init(mesh: Mesh, material: Material) {
        self.mesh = mesh
        self.material = material
    }
    
    public init() {
        self.mesh = nil
        self.material = nil
    }

    public func draw(context: DrawContext, parentTransform: Matrix4) {
        guard !isHidden else { return }
        
        guard
            let mesh = self.mesh,
            let material = self.material
        else {
            return
        }
        
        let worldTransform = parentTransform * transform
        
        // Every model has a unique model matrix, so we pass them through to the vertex
        // shader using a buffer, just like the vertices.
        // Since the data is small we can just use setVertexBytes to let Metal give
        // us a buffer from it's buffer pool.
        var transform = ModelTransform(
            modelMatrix: worldTransform,
            inverseModelMatrix: simd_inverse(worldTransform)
        )

        context.encoder.setVertexBytes(&transform, length: MemoryLayout<ModelTransform>.size, index: 1)
        
        context.set(material: material)

        mesh.draw(context: context)
        
        for node in nodes {
            node.draw(context: context, parentTransform: worldTransform)
        }
    }
    
}

