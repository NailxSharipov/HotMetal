//
//  RectNode.swift
//  EncodePrepasses
//
//  Created by Nail Sharipov on 29.09.2025.
//

import MetalKit
import HotMetal

final class RectNode: Node {

    private struct SolidParams {
        var color: SIMD4<Float>
    }

    private var params = SolidParams(color: SIMD4<Float>(0.9, 0.4, 0.2, 1.0))
    
    @MainActor
    init?(render: Render) {
        let vertices: [Vertex3] = [
            .init(x: -0.1, y: -0.1, z: 0),
            .init(x: -0.1, y:  0.1, z: 0),
            .init(x:  0.1, y:  0.1, z: 0),
            .init(x:  0.1, y: -0.1, z: 0)
        ]

        let indices: [UInt16] = [0, 1, 2, 0, 2, 3]

        let vertexLength = vertices.count * MemoryLayout<Vertex3>.stride
        guard let vertexBuffer = render.device.makeBuffer(
            bytes: vertices,
            length: vertexLength,
            options: [.cpuCacheModeWriteCombined]
        ) else {
            return nil
        }

        let indexLength = indices.count * MemoryLayout<UInt16>.stride
        guard let indexBuffer = render.device.makeBuffer(
            bytes: indices,
            length: indexLength,
            options: [.cpuCacheModeWriteCombined]
        ) else {
            return nil
        }

        let mesh = Mesh(vertexBuffer: vertexBuffer, indexBuffer: indexBuffer, count: indices.count)
        guard let material = render.materialLibrary.register(category: .solid, blendMode: .opaque) else {
            return nil
        }
        material.isAffectDepthBuffer = false

        super.init(mesh: mesh, material: material)
    }
    
    func update(size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        scale = Vector3(Float(size.width), Float(size.height), 1)
    }
        
    override func draw(context: DrawContext, parentTransform: Matrix4) {
        var params = self.params
        context.encoder.setFragmentBytes(&params, length: MemoryLayout<SolidParams>.stride, index: 2)
        super.draw(context: context, parentTransform: parentTransform)
    }
}
