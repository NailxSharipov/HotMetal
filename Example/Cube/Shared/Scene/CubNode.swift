//
//  CubNode.swift
//  Cube
//
//  Created by Nail Sharipov on 12.04.2022.
//

import MetalKit
import HotMetal

final class CubNode: Node {

    init(render: Render) {
        let mesh = Primitive.cube(render: render, size: 1)
        let material = render.library.get(category: .solid)
        
        super.init(mesh: mesh, material: material)
    }
    
}
