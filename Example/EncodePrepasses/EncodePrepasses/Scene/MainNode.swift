//
//  MainNode.swift
//  EncodePrepasses
//
//  Created by Nail Sharipov on 29.09.2025.
//

import MetalKit
import HotMetal

final class MainNode: Node {

    private struct SolidParams {
        var color: SIMD4<Float>
    }

    private let textureFlow: RenderToTextureFlow
    private var params = SolidParams(color: SIMD4<Float>(0.2, 0.6, 0.9, 1.0))
    
    @MainActor
    init?(render: Render, size: CGSize = .init(width: 240, height: 180)) {
        let halfWidth = Float(size.width * 0.5)
        let halfHeight = Float(size.height * 0.5)

        let vertices: [Vertex3] = [
            .init(x: -halfWidth, y: -halfHeight, z: 0),
            .init(x: -halfWidth, y:  halfHeight, z: 0),
            .init(x:  halfWidth, y:  halfHeight, z: 0),
            .init(x:  halfWidth, y: -halfHeight, z: 0)
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
    
    override func draw(context: DrawContext, parentTransform: Matrix4) {
        var params = self.params
        context.encoder.setFragmentBytes(&params, length: MemoryLayout<SolidParams>.stride, index: 2)
        super.draw(context: context, parentTransform: parentTransform)
    }
}
