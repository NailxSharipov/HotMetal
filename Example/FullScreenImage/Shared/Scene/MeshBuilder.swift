//
//  MeshBuilder.swift
//  FullScreenImage
//
//  Created by Nail Sharipov on 11.04.2022.
//

import CoreGraphics
import MetalKit
import HotMetal

final class MeshBuilder {
    
    // MetalView size
    var viewSize: CGSize = .zero
    
    // CropRect part of the image
    var cropRect: CGRect = .zero

}


extension MeshBuilder {

    func mesh(device: MTLDevice) -> Mesh? {
        let xRatio = viewSize.width / cropRect.width
        let yRatio = viewSize.height / cropRect.height
        
        let wdWidth: CGFloat
        let wdHeight: CGFloat

        let scale: CGFloat
        if xRatio < yRatio {
            scale = viewSize.width / (viewSize.height * cropRect.width)
            wdWidth = 1.0
            wdHeight = scale * cropRect.height
        } else {
            scale = viewSize.height / (viewSize.width * cropRect.height)
            wdWidth = scale * cropRect.width
            wdHeight = 1.0
        }
        
        let a = Float(wdWidth) - 0.01
        let b = Float(wdHeight) - 0.01
        
        let vertices: [TVertex2] = [
            .init(vertex: .init(x: -a, y: -b), uv: .init(x: 0, y: 1)),
            .init(vertex: .init(x: -a, y:  b), uv: .init(x: 0, y: 0)),
            .init(vertex: .init(x:  a, y:  b), uv: .init(x: 1, y: 0)),
            .init(vertex: .init(x:  a, y: -b), uv: .init(x: 1, y: 1))
        ]

        let indices: [UInt16] = [0, 1, 2, 0, 2, 3]
        
        let vertexSize = vertices.count * MemoryLayout.size(ofValue: vertices[0])
        guard let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertexSize, options: [.cpuCacheModeWriteCombined]) else {
            return nil
        }

        let indexSize = indices.count * MemoryLayout.size(ofValue: indices[0])
        guard let indexBuffer = device.makeBuffer(bytes: indices, length: indexSize, options: [.cpuCacheModeWriteCombined]) else {
            return nil
        }

        return Mesh(vertexBuffer: vertexBuffer, indexBuffer: indexBuffer, count: indices.count)
    }
    
}
