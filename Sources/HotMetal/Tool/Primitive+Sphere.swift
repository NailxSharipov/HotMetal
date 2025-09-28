//
//  File.swift
//  
//
//  Created by Nail Sharipov on 29.08.2022.
//

import CoreGraphics

public extension Primitive {

    static func tetrahedron(
        render: Render,
        radius: Float,
        colors: [CGColor]
    ) -> Mesh? {

//        let w2: Float = a * (1 / 3).squareRoot()
//        let w1: Float = w2 / 2
//        let q: Float = a * (2 / 3).squareRoot()
//        let o: Float = a * (1 / 24).squareRoot()

        let data = Self.tetrahedronTrinagles(radius: radius).mesh
        
        let vertices: [ColorVertex] = [
            ColorVertex(position: data.vertices[0], color: colors[0]),
            ColorVertex(position: data.vertices[1], color: colors[1]),
            ColorVertex(position: data.vertices[2], color: colors[2]),
            ColorVertex(position: data.vertices[3], color: colors[3])
        ]

        let vertexSize = vertices.count * MemoryLayout.size(ofValue: vertices[0])
        guard let vertexBuffer = render.device.makeBuffer(bytes: vertices, length: vertexSize, options: [.cpuCacheModeWriteCombined]) else {
            return nil
        }

        let indexSize = data.indices.count * MemoryLayout.size(ofValue: data.indices[0])
        guard let indexBuffer = render.device.makeBuffer(bytes: data.indices, length: indexSize, options: [.cpuCacheModeWriteCombined]) else {
            return nil
        }

        return Mesh(vertexBuffer: vertexBuffer, indexBuffer: indexBuffer, count: data.indices.count)
        
    }
    
    static func sphere(
        render: Render,
        radius r: Float,
        color: CGColor
    ) -> Mesh? {
        return nil
        
    }

    private static func tetrahedronTrinagles(radius r: Float) -> [Tringle] {
        let a: Float = (8/3).squareRoot()

        let w2: Float = a * (1 / 3).squareRoot()
        let w1: Float = w2 / 2
        let q: Float = a * (2 / 3).squareRoot()
        let o: Float = a * (1 / 24).squareRoot()

        let p0 = Vector3(x: -0.5 * a, y: -o, z: -w1)
        let p1 = Vector3(x:  0.5 * a, y: -o, z: -w1)
        let p2 = Vector3(x:        0, y: -o, z:  w2)
        let p3 = Vector3(x:        0, y:  q, z:   0)
        
        let v0 = Tringle.Vertex(index: 0, pos: p0)
        let v1 = Tringle.Vertex(index: 1, pos: p1)
        let v2 = Tringle.Vertex(index: 2, pos: p2)
        let v3 = Tringle.Vertex(index: 3, pos: p3)

        return [
            Tringle(vertices: [v0, v1, v2]),
            Tringle(vertices: [v3, v0, v1]),
            Tringle(vertices: [v3, v1, v2]),
            Tringle(vertices: [v3, v2, v0])
        ]
    }
    
}

private struct Tringle {
    
    struct Vertex {
        let index: UInt16
        let pos: Vector3
    }

    let a: Vertex
    let b: Vertex
    let c: Vertex
    
    init(vertices: [Vertex]) {
        a = vertices[0]
        b = vertices[1]
        c = vertices[2]
    }
    
}

private struct MeshData {
    let indices: [UInt16]
    let vertices: [Vector3]
}

extension Array where Element == Tringle {

    var mesh: MeshData {
        let n = self.count
        var indices = [UInt16]()
        var vertices = [Vector3](repeating: .zero, count: n)
        
        for trinagle in self {
            indices.append(trinagle.a.index)
            indices.append(trinagle.b.index)
            indices.append(trinagle.c.index)
            vertices[Int(trinagle.a.index)] = trinagle.a.pos
            vertices[Int(trinagle.b.index)] = trinagle.b.pos
            vertices[Int(trinagle.c.index)] = trinagle.c.pos
        }
        
        return MeshData(indices: indices, vertices: vertices)
    }
    
    
}
