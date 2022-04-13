//
//  File.swift
//  
//
//  Created by Nail Sharipov on 12.04.2022.
//

public final class Primitive {

    public static func cube(render: Render, size: Float) -> Mesh {

        let a = 0.5 * size

        let vertices: [Vertex3] = [
            .init(x: -a, y: -a, z: -a),
            .init(x: -a, y:  a, z: -a),
            .init(x:  a, y:  a, z: -a),
            .init(x:  a, y: -a, z: -a),
            
            .init(x: -a, y: -a, z:  a),
            .init(x: -a, y:  a, z:  a),
            .init(x:  a, y:  a, z:  a),
            .init(x:  a, y: -a, z:  a)
        ]

        let indices: [UInt16] = [
            0, 1, 2, 0, 2, 3, // front
            3, 2, 7, 2, 6, 7, // right
            2, 1, 5, 2, 5, 6, // top
            4, 0, 3, 3, 7, 4, // bottom
            0, 5, 1, 0, 4, 5, // left
            4, 6, 5, 4, 7, 6  // back
        ]
        
        let vertexSize = vertices.count * MemoryLayout.size(ofValue: vertices[0])
        let vertexBuffer = render.device.makeBuffer(bytes: vertices, length: vertexSize, options: [.cpuCacheModeWriteCombined])!

        let indexSize = indices.count * MemoryLayout.size(ofValue: indices[0])
        let indexBuffer = render.device.makeBuffer(bytes: indices, length: indexSize, options: [.cpuCacheModeWriteCombined])!

        return Mesh(vertexBuffer: vertexBuffer, indexBuffer: indexBuffer, count: indices.count)
        
    }
    
    public static func square(render: Render, size: Float) -> Mesh {

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
        let vertexBuffer = render.device.makeBuffer(bytes: vertices, length: vertexSize, options: [.cpuCacheModeWriteCombined])!

        let indexSize = indices.count * MemoryLayout.size(ofValue: indices[0])
        let indexBuffer = render.device.makeBuffer(bytes: indices, length: indexSize, options: [.cpuCacheModeWriteCombined])!

        return Mesh(vertexBuffer: vertexBuffer, indexBuffer: indexBuffer, count: indices.count)
        
    }
}
