//
//  RootNode.swift
//  ViewPort (iOS)
//
//  Created by Nail Sharipov on 21.04.2022.
//

import MetalKit
import HotMetal

final class RootNode: Node {

    let image = CGImage.load(name: "TwoSea")
    private let color = Vector4(CGColor(gray: 1, alpha: 1))
    private let indices: [UInt16] = [0, 1, 2, 0, 2, 3]
    
    init?(render: Render) {
        guard let image = self.image else { return nil }

        let a = 0.5 * Float(image.width)
        let b = 0.5 * Float(image.height)
        
        let vertices: [TextureVertex] = [
            TextureVertex(position: .init(x: -a, y: -b, z: 0.5), color: color, uv: Vector2(x: 0, y: 1)),
            TextureVertex(position: .init(x: -a, y:  b, z: 0.5), color: color, uv: Vector2(x: 0, y: 0)),
            TextureVertex(position: .init(x:  a, y:  b, z: 0.5), color: color, uv: Vector2(x: 1, y: 0)),
            TextureVertex(position: .init(x:  a, y: -b, z: 0.5), color: color, uv: Vector2(x: 1, y: 1))
        ]

        let vertexSize = vertices.count * MemoryLayout.size(ofValue: vertices[0])
        guard let vertexBuffer = render.device.makeBuffer(bytes: vertices, length: vertexSize, options: [.cpuCacheModeWriteCombined]) else {
            return nil
        }

        let indexSize = indices.count * MemoryLayout.size(ofValue: indices[0])
        guard let indexBuffer = render.device.makeBuffer(bytes: indices, length: indexSize, options: [.cpuCacheModeWriteCombined]) else {
            return nil
        }

        let mesh = Mesh(vertexBuffer: vertexBuffer, indexBuffer: indexBuffer, count: indices.count)
        guard
            let material = render.materialLibrary.register(category: .texture, blendMode: .opaque),
            let texture = render.textureLibrary.loadTexture(image: image)
        else {
            return nil
        }
        
        material.textures.append(texture)
        material.isAffectDepthBuffer = false
        material.cullMode = .none
        
        super.init(mesh: mesh, material: material)
    }

}

private extension CGImage {
    
    static func load(name: String) -> CGImage? {
#if os(iOS)
        return UIImage(named: name)?.cgImage
#elseif os(macOS)
        return NSImage(named: name)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
#endif
    }

}
