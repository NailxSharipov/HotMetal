//
//  CubeScene.swift
//  Cube
//
//  Created by Nail Sharipov on 12.04.2022.
//

import MetalKit
import HotMetal

final class CubeScene: Scene {

    init(render: Render) {
        super.init()
        self.nodes.append(CubNode(render: render))
    }

    
}
