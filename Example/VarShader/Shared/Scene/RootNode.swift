//
//  RootNode.swift
//  VarShader
//
//  Created by Nail Sharipov on 14.04.2022.
//

import MetalKit
import HotMetal

final class RootNode: Node {

    public var color = Vector4(0, 0, 0, 0)
    private let image = CGImage.load(name: "TwoSea")
    
    init?(render: Render) {
        guard let image = self.image else { return nil }
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
        guard let vertexBuffer = render.device.makeBuffer(bytes: vertices, length: vertexSize, options: [.cpuCacheModeWriteCombined]) else {
            return nil
        }

        let indexSize = indices.count * MemoryLayout.size(ofValue: indices[0])
        guard let indexBuffer = render.device.makeBuffer(bytes: indices, length: indexSize, options: [.cpuCacheModeWriteCombined]) else {
            return nil
        }

        let mesh = Mesh(vertexBuffer: vertexBuffer, indexBuffer: indexBuffer, count: indices.count)
        
        guard
            let piplineState = Material.texture(
                render: render,
                blendMode: .opaque,
                vertex: .local("vertexVarColor"),
                fragment: .local("fragmentVarColor")
            ),
            let texture = render.textureLibrary.loadTexture(image: image)
        else { return nil }
        let material = render.materialLibrary.register(state: piplineState)
//        material.cullMode = .back
        
        material.textures.append(texture)
        
        super.init(mesh: mesh, material: material)
    }
    
    override func draw(context: DrawContext, parentTransform: Matrix4) {
        var clr = self.color
        context.encoder.setVertexBytes(&clr, length: MemoryLayout<Vector4>.size, index: 3)
        super.draw(context: context, parentTransform: parentTransform)
    }
    
    override func update(time: Time) {
        super.update(time: time)
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
