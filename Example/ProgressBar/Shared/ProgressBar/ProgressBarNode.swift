//
//  ProgressBar+Node.swift
//  ProgressBar
//
//  Created by Nail Sharipov on 17.05.2022.
//

import MetalKit
import HotMetal

final class ProgressBarNode: Node {

    struct Line {
        let width: Float
        let color: SIMD4<Float>
    }
    
    private var varData = VarData(step: 0, ratio: 0, offset: 0, color0: .zero, color1: .zero)
    
    var speed: Float = 1
    var first: Line = .init(width: 2, color: .init(0, 0, 0, 1))
    var second: Line = .init(width: 2, color: .init(0.2, 0.2, 0.2, 1))
    
    var progress: Float = 0 {
        didSet {
            isNeedUpdateMesh = progress != oldValue
        }
    }
    
    private var isNeedUpdateMesh = true
    
    init?(render: Render) {
        guard
            let pipelineState = Material.solid(
                render: render,
                blendMode: .opaque,
                vertex: .local("vertexVarColor"),
                fragment: .local("fragmentVarColor")
            )
        else { return nil }
        let material = render.materialLibrary.register(state: pipelineState)

        super.init(mesh: nil, material: material)
    }
    
    override func draw(context: DrawContext, parentTransform: Matrix4) {
        var varData = self.varData
        context.encoder.setFragmentBytes(&varData, length: MemoryLayout<VarData>.size, index: 3)
        super.draw(context: context, parentTransform: parentTransform)
    }
    
    override func update(time: Time) {
        super.update(time: time)
        
        let step = first.width + second.width
        let delta = speed * Float(time.updateTime)
        let realOffset = varData.offset + delta
        let n = trunc(realOffset / step)
        let offset = realOffset - n * step
        
        varData = VarData(
            step: step,
            ratio: first.width / step,
            offset: offset,
            color0: first.color,
            color1: second.color
        )
    }
    
}
