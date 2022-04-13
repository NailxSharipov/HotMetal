//
//  ImageNode.swift
//  Image
//
//  Created by Nail Sharipov on 13.04.2022.
//

import MetalKit
import HotMetal

final class ImageNode: Node {

    private let image = CGImage.load(name: "TwoSea")
    
    init(render: Render) {

        let color = Vector4(CGColor(gray: 1, alpha: 1))
        let a = 0.5 * Float(image.width)
        let b = 0.5 * Float(image.height)
        
        let vertices: [TextureVertex] = [
            TextureVertex(position: .init(x: -a, y: -b, z: 0), color: color, uv: Vector2(x: 1, y: 1)),
            TextureVertex(position: .init(x: -a, y:  b, z: 0), color: color, uv: Vector2(x: 1, y: 0)),
            TextureVertex(position: .init(x:  a, y:  b, z: 0), color: color, uv: Vector2(x: 0, y: 0)),
            TextureVertex(position: .init(x:  a, y: -b, z: 0), color: color, uv: Vector2(x: 0, y: 1))
        ]

        let indices: [UInt16] = [0, 1, 2, 0, 2, 3]
        
        let vertexSize = vertices.count * MemoryLayout.size(ofValue: vertices[0])
        let vertexBuffer = render.device.makeBuffer(bytes: vertices, length: vertexSize, options: [.cpuCacheModeWriteCombined])!

        let indexSize = indices.count * MemoryLayout.size(ofValue: indices[0])
        let indexBuffer = render.device.makeBuffer(bytes: indices, length: indexSize, options: [.cpuCacheModeWriteCombined])!

        let mesh = Mesh(vertexBuffer: vertexBuffer, indexBuffer: indexBuffer, count: indices.count)
        let material = render.materialLibrary.register(category: .texture, blendMode: .opaque)
        let texture = render.textureLibrary.loadTexture(image: image)
        material.textures.append(texture)
        
        super.init(mesh: mesh, material: material)
    }
    
    override func update(time: Time) {
//        super.update(time: time)
//        let angle = Math.toRadians(30.0) * Float(time.totalTime)
//        self.scale = Vector3(repeating: 3)
//        self.orientation = Quaternion(
//            angle: angle,
//            axis: [0, 1, 0]
//        )
    }
    
}

private extension CGImage {
    
    static func load(name: String) -> CGImage {
#if os(iOS)
        return UIImage(named: name)!.cgImage!
#elseif os(macOS)
        return NSImage(named: name)!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
#endif
    }

}
