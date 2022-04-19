//
//  Primitive.swift
//  HotMetal
//
//  Created by Nail Sharipov on 12.04.2022.
//

import CoreGraphics

public final class Primitive {

    public static func cube(
        render: Render,
        size: Float,
        colors: [CGColor]
    ) -> Mesh? {

        let a = 0.5 * size

        let vertices: [ColorVertex] = [
            ColorVertex(position: .init(x: -a, y: -a, z: -a), color: colors[0]),
            ColorVertex(position: .init(x: -a, y:  a, z: -a), color: colors[1]),
            ColorVertex(position: .init(x:  a, y:  a, z: -a), color: colors[2]),
            ColorVertex(position: .init(x:  a, y: -a, z: -a), color: colors[3]),
            
            ColorVertex(position: .init(x: -a, y: -a, z:  a), color: colors[4]),
            ColorVertex(position: .init(x: -a, y:  a, z:  a), color: colors[5]),
            ColorVertex(position: .init(x:  a, y:  a, z:  a), color: colors[6]),
            ColorVertex(position: .init(x:  a, y: -a, z:  a), color: colors[7])
        ]

        let indices: [UInt16] = [
            0, 1, 2, 0, 2, 3, // front
            3, 2, 7, 2, 6, 7, // right
            4, 0, 3, 3, 7, 4, // bottom
            2, 1, 5, 2, 5, 6, // top
            0, 5, 1, 0, 4, 5, // left
            4, 6, 5, 4, 7, 6  // back
        ]
        
        let vertexSize = vertices.count * MemoryLayout.size(ofValue: vertices[0])
        guard let vertexBuffer = render.device.makeBuffer(bytes: vertices, length: vertexSize, options: [.cpuCacheModeWriteCombined]) else {
            return nil
        }

        let indexSize = indices.count * MemoryLayout.size(ofValue: indices[0])
        guard let indexBuffer = render.device.makeBuffer(bytes: indices, length: indexSize, options: [.cpuCacheModeWriteCombined]) else {
            return nil
        }

        return Mesh(vertexBuffer: vertexBuffer, indexBuffer: indexBuffer, count: indices.count)
        
    }
    
    public static func square(render: Render, size: Float) -> Mesh? {

        let a = 0.5 * size

        let vertices: [Vertex3] = [
            .init(x: -a, y: -a, z: 0),
            .init(x: -a, y:  a, z: 0),
            .init(x:  a, y:  a, z: 0),
            .init(x:  a, y: -a, z: 0)
        ]

        let indices: [UInt16] = [
            0, 1, 2, 0, 2, 3
        ]
        
        let vertexSize = vertices.count * MemoryLayout.size(ofValue: vertices[0])
        guard let vertexBuffer = render.device.makeBuffer(bytes: vertices, length: vertexSize, options: [.cpuCacheModeWriteCombined]) else {
            return nil
        }

        let indexSize = indices.count * MemoryLayout.size(ofValue: indices[0])
        guard let indexBuffer = render.device.makeBuffer(bytes: indices, length: indexSize, options: [.cpuCacheModeWriteCombined]) else {
            return nil
        }

        return Mesh(vertexBuffer: vertexBuffer, indexBuffer: indexBuffer, count: indices.count)
        
    }
}
