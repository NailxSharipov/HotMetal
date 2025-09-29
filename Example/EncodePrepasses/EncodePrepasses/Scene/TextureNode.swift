//
//  TextureNode.swift
//  EncodePrepasses
//
//  Created by Nail Sharipov on 29.09.2025.
//

import MetalKit
import HotMetal

final class TextureNode: Node {

    @MainActor
    init?(render: Render) {
        let color = Vector4(CGColor(gray: 1, alpha: 1))
        let vertices: [TextureVertex] = [
            TextureVertex(position: .init(x: -0.5, y: -0.5, z: 0), color: color, uv: Vector2(x: 0, y: 1)),
            TextureVertex(position: .init(x: -0.5, y:  0.5, z: 0), color: color, uv: Vector2(x: 0, y: 0)),
            TextureVertex(position: .init(x:  0.5, y:  0.5, z: 0), color: color, uv: Vector2(x: 1, y: 0)),
            TextureVertex(position: .init(x:  0.5, y: -0.5, z: 0), color: color, uv: Vector2(x: 1, y: 1))
        ]

        let indices: [UInt16] = [0, 1, 2, 0, 2, 3]

        let vertexLength = vertices.count * MemoryLayout<TextureVertex>.stride
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
        guard let material = render.materialLibrary.register(category: .texture, blendMode: .opaque) else {
            return nil
        }
        material.isAffectDepthBuffer = false

        super.init(mesh: mesh, material: material)
    }
    
    func updateSize(_ size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        scale = Vector3(Float(size.width), Float(size.height), 1)
    }
    
    func updateTexture(_ texture: Texture) {
        material?.textures = [texture]
    }
}
