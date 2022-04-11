//
//  TVertex2.swift
//  
//
//  Created by Nail Sharipov on 11.04.2022.
//

public struct TVertex2 {

    public let x: Float
    public let y: Float
    public let u: Float
    public let v: Float
    
    
    public init(vertex: Vertex2, uv: Vertex2) {
        x = vertex.x
        y = vertex.y
        u = uv.x
        v = uv.y
    }
}
