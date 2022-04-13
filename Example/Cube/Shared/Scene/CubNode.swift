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
        let mesh = Primitive.cube(render: render, size: 1, colors: [
            CGColor(red: 1, green: 0, blue: 0, alpha: 1),
            CGColor(red: 1, green: 0, blue: 0, alpha: 1),
            CGColor(red: 1, green: 0, blue: 0, alpha: 1),
            CGColor(red: 1, green: 0, blue: 0, alpha: 1),
            
            CGColor(red: 1, green: 1, blue: 0, alpha: 1),
            CGColor(red: 1, green: 1, blue: 0, alpha: 1),
            CGColor(red: 1, green: 1, blue: 0, alpha: 1),
            CGColor(red: 1, green: 1, blue: 0, alpha: 1)
        ])
        let material = render.library.get(category: .color)
        
        super.init(mesh: mesh, material: material)
    }
    
    override func update(time: Time) {
        super.update(time: time)
        let angle = Math.toRadians(30.0) * Float(time.totalTime)
        self.scale = Vector3(repeating: 3)
        self.orientation = Quaternion(
            angle: angle,
            axis: [0, 1, 0]
        )
    }
    
}
