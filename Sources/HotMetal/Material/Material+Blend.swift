//
//  Material+Blend.swift
//  HotMetal
//
//  Created by Nail Sharipov on 13.04.2022.
//

import Metal

public extension Material {

    // https://docs.unity3d.com/Manual/SL-Blend.html
    // https://metalbyexample.com/translucency-and-transparency/
    
    enum BlendMode: Int {
        case opaque
        case traditional        // SrcAlpha OneMinusSrcAlpha
        case premultiplied      // One OneMinusSrcAlpha
        case additive           // One One
        case softAdditive       // OneMinusDstColor One
        case multiplicative     // DstColor Zero
        case x2Multiplicative   // DstColor Zero
    }

}

public extension MTLRenderPipelineColorAttachmentDescriptor {
    
    func set(blendMode: Material.BlendMode) {
        switch blendMode {
        case .opaque:
            self.isBlendingEnabled = false
        case .traditional:
            self.isBlendingEnabled = true
            self.rgbBlendOperation = .add
            self.alphaBlendOperation = .add
            self.sourceRGBBlendFactor = .sourceAlpha
            self.sourceAlphaBlendFactor = .sourceAlpha
            self.destinationRGBBlendFactor = .oneMinusSourceAlpha
            self.destinationAlphaBlendFactor = .oneMinusSourceAlpha
        default:
            assertionFailure("Not implemented")
        }
    }
    
}
