//
//  Solid.metal
//  FullScreenImage
//
//  Created by Nail Sharipov on 12.04.2022.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct VertexIn {
    float3 position [[attribute(0)]];
};

struct VertexOut {
    float4 position [[position]];
};

struct FragmentOut {
    float4 color0 [[color(0)]];
};

struct Uniforms {
    float time;
    float4x4 view;
    float4x4 inverseView;
    float4x4 viewProjection;
};

struct ModelTransform {
    float4x4 modelMatrix;
    float4x4 inverseModelMatrix;
};

vertex VertexOut vertexSolid(
                             const VertexIn vIn [[ stage_in ]],
                             const device Uniforms& uniforms [[ buffer(0) ]],
                             const device ModelTransform& transform [[ buffer(1) ]]
) {
    VertexOut vOut;
    vOut.position = uniforms.viewProjection * transform.modelMatrix * float4(vIn.position, 1.0);
    
    return vOut;
}

fragment FragmentOut fragmentSolid(
                                   VertexOut interpolated [[ stage_in ]]
) {
    FragmentOut out;

    out.color0 = float4(1, 1, 0, 0.6);
        
    return out;
}
