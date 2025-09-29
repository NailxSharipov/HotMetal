//
//  RectNode.swift
//  EncodePrepasses
//
//  Created by Nail Sharipov on 29.09.2025.
//

import MetalKit
import HotMetal
import Foundation
import simd

final class RectNode: Node {

    private struct SolidParams {
        var color: SIMD4<Float>
    }

    private var params = SolidParams(color: SIMD4<Float>(0.9, 0.4, 0.2, 0.9))

    private var origin = SIMD2<Float>(0, 0)
    private var velocity = SIMD2<Float>(120, 80)
    private var bounds = SIMD2<Float>(0, 0)
    
    @MainActor
    init?(render: Render) {
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
    }
    
    func update(size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let w = Float(size.width) * 0.01
        let h = Float(size.height) * 0.01
        bounds = SIMD2<Float>(Float(size.width) * 0.5 - w, Float(size.height) * 0.5 - h)
        scale = Vector3(w, h, 1)
        origin = SIMD2<Float>(
            x: min(max(origin.x, -bounds.x), bounds.x),
            y: min(max(origin.y, -bounds.y), bounds.y)
        )
        position = Vector3(origin.x, origin.y, 0)
    }

    func advance(deltaTime: TimeInterval) {
        let dt = Float(deltaTime)
        guard dt > 0 else { return }
        let newOrigin = origin + velocity * dt
        origin = SIMD2<Float>(
            x: bounce(value: newOrigin.x, limit: bounds.x, velocityComponent: &velocity.x),
            y: bounce(value: newOrigin.y, limit: bounds.y, velocityComponent: &velocity.y)
        )
        position = Vector3(origin.x, origin.y, 0)
    }

    private func bounce(value: Float, limit: Float, velocityComponent: inout Float) -> Float {
        guard limit > 0 else { return 0 }
        var v = value
        let lim = limit
        if v > lim {
            v = lim
            velocityComponent = -abs(velocityComponent)
        } else if v < -lim {
            v = -lim
            velocityComponent = abs(velocityComponent)
        }
        return v
    }

    override func draw(context: DrawContext, parentTransform: Matrix4) {
        var params = self.params
        context.encoder.setFragmentBytes(&params, length: MemoryLayout<SolidParams>.stride, index: 2)
        super.draw(context: context, parentTransform: parentTransform)
    }
}
