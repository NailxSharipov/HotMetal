//
//  ScissorRectNode.swift
//  ScissorRect
//
//  Created by Nail Sharipov on 29.09.2025.
//

import MetalKit
import HotMetal

final class ScissorRectNode: Node {

    private struct SolidParams {
        var color: SIMD4<Float>
    }

    private let rectSize: CGSize
    private var fillColor = SIMD4<Float>(0.9, 0.2, 0.2, 1.0)
    private var scissorRect = MTLScissorRect(x: 0, y: 0, width: 1, height: 1)
    private var fullScreenRect = MTLScissorRect(x: 0, y: 0, width: 1, height: 1)
    
    @MainActor
    init?(render: Render, screenSize: CGSize, rectSize: CGSize = .init(width: 220, height: 180)) {
        self.rectSize = rectSize
        
        let vertices: [Vertex3] = [
            .init(x: -0.5, y: -0.5, z: 0),
            .init(x: -0.5, y:  0.5, z: 0),
            .init(x:  0.5, y:  0.5, z: 0),
            .init(x:  0.5, y: -0.5, z: 0)
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

        update(screenSize: screenSize)
    }
    
    func update(screenSize: CGSize) {
        guard screenSize.width > 0, screenSize.height > 0 else { return }
        
        scale = Vector3(Float(screenSize.width), Float(screenSize.height), 1)
        
        let width = min(rectSize.width, screenSize.width)
        let height = min(rectSize.height, screenSize.height)
        let originX = max(0, Int((screenSize.width - width) * 0.5))
        let originY = max(0, Int((screenSize.height - height) * 0.5))
        let w = max(1, Int(width))
        let h = max(1, Int(height))
        
        scissorRect = MTLScissorRect(x: originX, y: originY, width: w, height: h)
        fullScreenRect = MTLScissorRect(x: 0, y: 0, width: max(1, Int(screenSize.width)), height: max(1, Int(screenSize.height)))
    }
    
    override func draw(context: DrawContext, parentTransform: Matrix4) {
        context.encoder.setScissorRect(scissorRect)
        var params = SolidParams(color: fillColor)
        context.encoder.setFragmentBytes(&params, length: MemoryLayout<SolidParams>.stride, index: 2)
        super.draw(context: context, parentTransform: parentTransform)
        context.encoder.setScissorRect(fullScreenRect)
    }
}
