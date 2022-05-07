//
//  RootNode.swift
//  RenderToTexture
//
//  Created by Nail Sharipov on 15.04.2022.
//

import MetalKit
import HotMetal

final class RootNode: Node {

    public var data = Vector3(0, 0, 0)
    private let imageLoader = HeicLoader()
    
    init?(render: Render) {
        guard let resource = imageLoader.load(render: render, fileName: "Tiger", gammaCorrection: true) else {
            return nil
        }
        
        let color = Vector4(CGColor(gray: 1, alpha: 1))
        let a = 0.5 * Float(resource.size.width)
        let b = 0.5 * Float(resource.size.height)
        
        let vertices: [TextureVertex] = [
            TextureVertex(position: .init(x: -a, y: -b, z: 0), color: color, uv: Vector2(x: 0, y: 1)),
            TextureVertex(position: .init(x: -a, y:  b, z: 0), color: color, uv: Vector2(x: 0, y: 0)),
            TextureVertex(position: .init(x:  a, y:  b, z: 0), color: color, uv: Vector2(x: 1, y: 0)),
            TextureVertex(position: .init(x:  a, y: -b, z: 0), color: color, uv: Vector2(x: 1, y: 1))
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
        
        guard let pipelineState = Material.texture(
            render: render,
            blendMode: .opaque,
            vertex: .local("vertexDepthFilter"),
            fragment: .local("fragmentDepthFilter")
        ) else {
            return nil
        }
        let material = render.materialLibrary.register(state: pipelineState)
        material.isAffectDepthBuffer = false

        material.textures.append(resource.textures[0])
        material.textures.append(resource.textures[1])
        
        super.init(mesh: mesh, material: material)
    }
    
    override func draw(context: DrawContext, parentTransform: Matrix4) {
        context.encoder.setFragmentBytes(&data, length: MemoryLayout<Vector3>.size, index: 3)
        super.draw(context: context, parentTransform: parentTransform)
    }
    
    override func update(time: Time) {
        super.update(time: time)
    }
    
}
